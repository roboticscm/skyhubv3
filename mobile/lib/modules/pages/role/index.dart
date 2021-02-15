import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/modules/pages/role/controller.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/default_drawer.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';
import 'package:skyone_mobile/widgets/search_bar.dart';
import 'package:skyone_mobile/extension/string.dart';

class RolePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final _roleController = Get.put(RoleController());
  final String title;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  RolePage({@required this.title}) {
    _roleController.find();
    _searchController.addListener(() {
      _roleController.find(textSearch: _searchController.text.trim());
    });

    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
        _roleController.findMore(textSearch: _searchController.text.trim());
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(onRefresh: () {
      return _roleController.refresh(textSearch: _searchController.text.trim());
    }, child: Obx(() {
      if (_roleController.list.isEmpty) {
        return SCircularProgressIndicator.buildSmallCenter();
      } else {
        return ListView.separated(
            controller: _scrollController,
            itemBuilder: (BuildContext context, int index) {
              if (index < _roleController.list.length) {
                return _buildListItem(_roleController.list[index]);
              } else if (!_roleController.endOfData()) {
                return SCircularProgressIndicator.buildSmallCenter();
              } else if (_roleController.isRefreshing.value) {
                return Container();
              } else {
                return Padding(
                  padding: defaultPadding,
                  child: Text('SYS.LABEL.END_OF_DATA'.t()),
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemCount: _roleController.list.length + 1);
      }
    }));
  }

  Widget _buildListItem(Role item) {
    return ListTile(
      title: Text(item.name ?? ''),
    );
  }
}
