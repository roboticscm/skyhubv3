import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/features/menu/controller.dart';
import 'package:skyone_mobile/features/pages/role/list/index.dart';
import 'package:skyone_mobile/pt/proto/menu/menu_message.pb.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/util/global_param.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/default_drawer.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';
import 'package:skyone_mobile/widgets/search_bar.dart';
import 'package:skyone_mobile/extension/string.dart';

class MenuPage extends StatelessWidget {
  final MenuController _menuController = Get.put(MenuController());
  final LoginInfoController _loginInfoController = Get.find();
  final ThemeController _themeController = Get.find();
  final _searchController = TextEditingController();
  final Map<String, Widget> _pageInstances = {};

  MenuPage() {
    _menuController.findDepartment(branchId: _loginInfoController.branchId.value.toInt());
    _searchController.addListener(() {
      _menuController.findDepartment(
          branchId: _loginInfoController.branchId.value.toInt(), textSearch: _searchController.text);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DefaultDrawer(),
      appBar: _buildAppBar(context),
      body: Padding(
        padding: defaultPadding,
        child: _buildMenu(context),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Obx(() {
      if (_menuController.rxDepartment.value != null) {
        return RefreshIndicator(
          onRefresh: () {
            return _menuController.findDepartment(
                branchId: _loginInfoController.branchId.value.toInt(), textSearch: _searchController.text);
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
        return SCircularProgressIndicator.buildSmallCenter();
      }
    });
  }

  Widget _buildDepartmentHeader(String departmentName, int itemCount) {
    if (itemCount < 1) {
      return Container();
    } else {
      return Container(
          padding: defaultPadding,
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
      return RolePage(
        title: "SYS.MENU.${menuName.toUpperCase()}".t(),
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
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("SYS.MSG.PLEASE_INIT_PAGE_INSTANCE".t()),
      ));
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
