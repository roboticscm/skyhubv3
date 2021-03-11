import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/features/calendar/index.dart';
import 'package:skyone/features/home/index.dart';
import 'package:skyone/features/menu/index.dart';
import 'package:skyone/features/message/index.dart';
import 'package:skyone/features/qrcode/index.dart';
import 'package:skyone/features/qrcode/viewer/index.dart';
import 'package:skyone/system/layout/controller.dart';
import 'package:skyone/system/local_notify/controller.dart';
import 'package:skyone/system/login/controller.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/widgets/default_drawer.dart';
import 'package:skyone/widgets/double_circular_notched_rectangle.dart';
import 'package:skyone/widgets/stab_bar.dart';
import 'package:skyone/widgets/tab_bar_item.dart';
import 'package:skyone/extensions/string.dart';

class LayoutPage extends StatelessWidget {
  static const HOME_INDEX = 0;
  static const MENU_INDEX = 1;
  static const CALENDER_INDEX = 2;
  static const MESSAGE_INDEX = 3;
  static const QRCODE_INDEX = 4;
  static const MORE_INDEX = 5;

  final _layoutController = Get.put(LayoutController());
  static final ThemeController _themeController = Get.find();

  static final _localNotifyListenerController =
      Get.put(LocalNotifyListenerController());

  HomeTabContent _homeTabContent;
  MenuTabContent _menuTabContent;
  CalendarTabContent _calendarTabContent;
  MessageTabContent _messageTabContent;
  QrCodeTabContent _qrCodeTabContent;

  LayoutPage() {
    //TODO Demo local notify
    Future.delayed(Duration(seconds: 5)).then((value) =>
        _localNotifyListenerController.changeNotify(MESSAGE_INDEX, 9));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GetBuilder(
            init: _layoutController,
            id: 'selectedBottomTabIndex',
            builder: (LayoutController layoutController) {
              return Scaffold(
                appBar: layoutController
                        .showAppBar[layoutController.selectedBottomTabIndex]
                    ? buildDefaultAppBar()
                    : _emptyAppBar(),
                drawer: DefaultDrawer(),
                body: _buildLayoutBody(layoutController),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
                floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 32),
                      child: FloatingActionButton(
                        child: Opacity(
                          opacity: _layoutController.selectedBottomTabIndex ==
                                  HOME_INDEX
                              ? 1
                              : 0.8,
                          child: Icon(
                            Icons.home,
                          ),
                        ),
                        onPressed: () {
                          _layoutController.changeBottomTabIndex(HOME_INDEX);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 41),
                      child: FloatingActionButton(
                        child: Opacity(
                          opacity: _layoutController.selectedBottomTabIndex ==
                                  QRCODE_INDEX
                              ? 1
                              : 0.8,
                          child: Icon(
                            Icons.qr_code,
                          ),
                        ),
                        onPressed: () async {
                          Get.to(QrCodeViewer());
                        },
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: buildBottomTab(),
              );
            }));
  }

  PreferredSize _emptyAppBar() {
    return PreferredSize(child: Container(), preferredSize: Size(0, 0));
  }

  static AppBar buildDefaultAppBar() {
    return AppBar(
      title: Text('Default App'),
    );
  }

  Widget _buildLayoutBody(LayoutController layoutController) {
    if (layoutController.selectedBottomTabIndex == HOME_INDEX) {
      return _homeTabContent ??= HomeTabContent();
    } else if (layoutController.selectedBottomTabIndex == MENU_INDEX) {
      return _menuTabContent ??= MenuTabContent();
    } else if (layoutController.selectedBottomTabIndex == CALENDER_INDEX) {
      return _calendarTabContent ??= CalendarTabContent();
    } else if (layoutController.selectedBottomTabIndex == MESSAGE_INDEX) {
      return _messageTabContent ??= MessageTabContent();
    } else if (layoutController.selectedBottomTabIndex == QRCODE_INDEX) {
      return _qrCodeTabContent ??= QrCodeTabContent();
    } else if (layoutController.selectedBottomTabIndex == MORE_INDEX) {
      return Center(
        child: Text('SYS.LABEL.UNRECONSTRUCTED'.t),
      );
    }
  }

  static Widget buildBottomTab() {
    return BottomAppBar(
      shape: DoubleCircularNotchedRectangle(),
      notchMargin: 5,
      color: _themeController.getPrimaryColor(),
      child: GetBuilder(
          init: _localNotifyListenerController,
          id: 'bottomNotifyValue',
          builder: (LocalNotifyListenerController notifyController) {
            return STabBar(
              height: 65,
              leftChildren: [
                TabBarItem(
                  index: 1,
                  assetSvg: 'assets/menu.svg',
                  title: 'SYS.LABEL.MENU'.t,
                  notifyValue: notifyController.bottomNotifyValues[1],
                ),
                TabBarItem(
                  index: 2,
                  assetSvg: 'assets/calendar.svg',
                  title: 'SYS.LABEL.CALENDAR'.t,
                  notifyValue: notifyController.bottomNotifyValues[2],
                ),
                TabBarItem(
                  index: 3,
                  assetSvg: 'assets/message.svg',
                  title: 'SYS.LABEL.MESSAGE'.t,
                  notifyValue: notifyController.bottomNotifyValues[3],
                ),
              ],
              rightChildren: [
                TabBarItem(
                  index: 5,
//                  width: 30,
                  iconData: Icons.more_vert,
                ),
              ],
            );
          }),
    );
  }
}
