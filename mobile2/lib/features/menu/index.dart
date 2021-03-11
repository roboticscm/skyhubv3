import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/features/menu/controller.dart';
import 'package:skyone/features/role/list/index.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/pt/proto/menu/menu_message.pb.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/widgets/circular_progress.dart';
import 'package:skyone/widgets/default_drawer.dart';
import 'package:skyone/extensions/string.dart';
import 'package:skyone/widgets/search_bar.dart';

class MenuTabContent extends StatelessWidget {
  final MenuController _menuController = Get.put(MenuController());
  final ThemeController _themeController = Get.find();
  final _searchController = TextEditingController();
  final Map<String, Widget> _pageInstances = {};

  MenuTabContent() {
    _menuController.findDepartment(branchId: LoginInfo.branchId);
    _searchController.addListener(() {
      _menuController.findDepartment(
          branchId: LoginInfo.branchId, textSearch: _searchController.text);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DefaultDrawer(),
      appBar: _buildAppBar(context),
      body: Padding(
        padding: DEFAULT_PADDING,
        child: _buildMenu(context),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Obx(() {
      if (_menuController.rxDepartment.length > 0) {
        return RefreshIndicator(
          onRefresh: () {
            return _menuController.findDepartment(
                branchId: LoginInfo.branchId, textSearch: _searchController.text);
          },
          child: ListView.separated(
              itemBuilder: (context, index) {
                return Obx(() => _buildDepartment(context, (_menuController.rxDepartment[index]).id.toInt(),
                    (_menuController.rxDepartment[index]).name, _menuController.rxMenu[index]));
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: _menuController.rxDepartment.length),
        );
      } else {
        return CircularProgress.smallCenter();
      }
    });
  }

  Widget _buildDepartmentHeader(String departmentName, int itemCount) {
    if (itemCount < 1) {
      return Container();
    } else {
      return Container(
          padding: DEFAULT_PADDING,
          alignment: AlignmentDirectional.centerStart,
          child: Text("$departmentName ($itemCount)"));
    }
  }

  Widget _buildDepartment(BuildContext context, int depId, String departmentName, List<Menu> menuList) {
    return Column(
      children: [
        _buildDepartmentHeader(departmentName, menuList.length),
        GridView.count(
          shrinkWrap: true,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          childAspectRatio: 2,
          crossAxisCount: calcNumOfGridColumn(context),
          children: <Widget>[for (var menu in menuList) _buildMenuItem(context, depId, menu)],
        ),
      ],
    );
  }

  Widget _getWidgetInstance(int depId, String codeKey, String menuName, String menuPath) {
    if (codeKey.toUpperCase() == "ROLE") {
      return RoleListPage(
        title: "SYS.MENU.${menuName.toUpperCase()}".t,
        depId: depId,
        menuPath: menuPath,
      );
    }

    return null;
  }

  void _showMenuDetail(BuildContext context, int depId, String codeKey, String menuName, String menuPath) {
    final widget = _getWidgetInstance(depId, codeKey, menuName, menuPath);
    if (widget != null) {
      _pageInstances[codeKey] = widget;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return _pageInstances[codeKey];
      }));
    } else {
      Get.snackbar('', "SYS.MSG.PLEASE_INIT_PAGE_INSTANCE".t);

    }
  }

  Widget _buildMenuItem(BuildContext context, int depId, Menu menu) {
    return Card(
        child: Center(
      child: InkWell(
        onTap: () {
          _showMenuDetail(context, depId, menu.code, menu.name, menu.path);
        },
        child: FittedBox(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.topEnd,
              children: <Widget>[
                Container(
                  width: 55,
                  height: 55,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 5, right: 5),
                  decoration: BoxDecoration(
                      color: _themeController.themeData.value.primaryColor, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.menu),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.only(left: 3, top: 0, right: 3, bottom: 0),
                  decoration: BoxDecoration(
                      color: _themeController.themeData.value.textSelectionColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text("1"),
                )
              ],
            ),
            Container(margin: const EdgeInsets.only(top: 4), child: Text(menu.name)),
          ]),
        ),
      ),
    ));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: SearchBar(
        controller: _searchController,
      ),
    );
  }
}
