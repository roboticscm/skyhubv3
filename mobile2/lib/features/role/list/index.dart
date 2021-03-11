import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/features/role/list/controller.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/pt/proto/role/role_message.pb.dart';
import 'package:skyone/system/db_notify_listener/controller.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/widgets/circular_progress.dart';
import 'package:skyone/widgets/default_drawer.dart';
import 'package:skyone/widgets/search_bar.dart';
import 'package:skyone/extensions/string.dart';

class RoleListPage extends StatelessWidget {
  final String menuPath;
  final int depId;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final _roleListController = Get.put(RoleListController());
  final String title;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final ThemeController _themeController = Get.find();
  final DbNotifyListenerController _dbNotifyListenerController = Get.find();
  RoleListPage({@required this.title, this.menuPath, this.depId}) {
    _roleListController.init();
    _searchController.addListener(() {
      _roleListController.textSearch$.value = _searchController.text.trim();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent ) {
        _roleListController.findMore(textSearch: _searchController.text.trim());
      }
    });

    final stream = _dbNotifyListenerController.register();
    if (stream != null) {
      stream.listen((value) {
        if ((value as NotifyListener).table == "role") {
          _roleListController.refresh(textSearch: _searchController.text.trim());
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
          if (_roleListController.isInitializing$.value) {
            return Center(
              child: CircularProgress.smallCenter(),
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
          return _roleListController.refresh(textSearch: _searchController.text.trim());
        },
        child: ListView.separated(
            controller: _scrollController,
            itemBuilder: (BuildContext context, int index) {
              if (index < _roleListController.list$.length) {
                return _buildListItem(context, _roleListController.list$[index]);
              } else if (!_roleListController.endOfData() && !_roleListController.isRefreshing) {
                return CircularProgress.smallest();
              } else if (_roleListController.isRefreshing) {
                return Container();
              } else {
                return Padding(
                  padding: DEFAULT_PADDING,
                  child: Text("${_roleListController.fullCount} ${'SYS.LABEL.RECORDS'.t}"),
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemCount: _roleListController.list$.length + 1)));
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
//    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
//      return RoleForm(
//        module: module,
//        isUpdateMode: edit,
//        selectedData: selectedData,
//        depId: depId,
//        menuPath: menuPath,
//      );
//    })).then((value) {
//      if (value != null) {
//        final obj = value as Role;
//        if (obj.id.toInt() != 0) {
//          _roleController.updateItem(obj);
//        } else {
//          _roleController.refresh(textSearch: _searchController.text.trim());
//        }
//      }
//    });
  }
}
