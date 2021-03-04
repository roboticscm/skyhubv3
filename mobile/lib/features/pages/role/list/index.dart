import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/features/notify_listener/controller.dart';
import 'package:skyone_mobile/features/pages/role/form/index.dart';
import 'package:skyone_mobile/features/pages/role/list/controller.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/default_drawer.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';
import 'package:skyone_mobile/widgets/search_bar.dart';
import 'package:skyone_mobile/extension/string.dart';

class RolePage extends StatelessWidget {
  final String menuPath;
  final int depId;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final _roleController = Get.put(RoleController());
  final String title;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final ThemeController _themeController = Get.find();
  final NotifyListenerController _notifyListenerController = Get.find();
  RolePage({@required this.title, this.menuPath, this.depId}) {
    _roleController.init();
    _searchController.addListener(() {
      _roleController.textSearch$.value = _searchController.text.trim();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent ) {
        _roleController.findMore(textSearch: _searchController.text.trim());
      }
    });

    final res = _notifyListenerController.register();
    if (res.item1 != null) {
      res.item1.listen((value) {
        if ((value as NotifyListener).table == "role") {
          _roleController.refresh(textSearch: _searchController.text.trim());
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: _themeController.getPrimaryColor(),
          child: IconButton(
            onPressed: () {
              _showForm(context, module: title, edit: false);
            },
            icon: const Icon(Icons.add),
          ),
        ),
        key: _drawerKey,
        drawer: DefaultDrawer(),
        appBar: AppBar(
          leadingWidth: 70,
          automaticallyImplyLeading: false,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 35,
                height: 30,
                child: IconButton(
                    onPressed: () {
                      _drawerKey.currentState.openDrawer();
                    },
                    padding: const EdgeInsets.only(left: 10, top: 0),
                    icon: const Icon(Icons.menu)),
              ),
              SizedBox(
                width: 35,
                height: 30,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    padding: const EdgeInsets.only(left: 20, top: 0),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                    )),
              ),
            ],
          ),
          title: Row(
            children: [
              Text(title),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SearchBar(
                    controller: _searchController,
                  ),
                ),
              )
            ],
          ),
        ),
        body: Obx(() {
          if (_roleController.isInitializing$.value) {
            return Center(
              child: SCircularProgressIndicator.buildSmallCenter(),
            );
          } else {
            return _buildList(context);
          }
        }),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() => RefreshIndicator(
        onRefresh: () {
          return _roleController.refresh(textSearch: _searchController.text.trim());
        },
        child: ListView.separated(
            controller: _scrollController,
            itemBuilder: (BuildContext context, int index) {
              if (index < _roleController.list$.length) {
                return _buildListItem(context, _roleController.list$[index]);
              } else if (!_roleController.endOfData() && !_roleController.isRefreshing) {
                return SCircularProgressIndicator.buildSmallest();
              } else if (_roleController.isRefreshing) {
                return Container();
              } else {
                return Padding(
                  padding: defaultPadding,
                  child: Text("${_roleController.fullCount} ${'SYS.LABEL.RECORDS'.t()}"),
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemCount: _roleController.list$.length + 1)));
  }

  Widget _buildListItem(BuildContext context, Role item) {
    return InkWell(
      onTap: () {
        _showForm(context, module: title, edit: true, selectedData: item);
      },
      child: ListTile(
        title: Text(item.name ?? ''),
      ),
    );
  }

  void _showForm(BuildContext context, {String module, bool edit, Role selectedData}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return RoleForm(
        module: module,
        isUpdateMode: edit,
        selectedData: selectedData,
        depId: depId,
        menuPath: menuPath,
      );
    })).then((value) {
      if (value != null) {
        final obj = value as Role;
        if (obj.id.toInt() != 0) {
          _roleController.updateItem(obj);
        } else {
          _roleController.refresh(textSearch: _searchController.text.trim());
        }
      }
    });
  }
}
