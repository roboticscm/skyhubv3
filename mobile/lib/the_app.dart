import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/modules/calendar/index.dart';
import 'package:skyone_mobile/modules/entry/index.dart';
import 'package:skyone_mobile/modules/home/index.dart';
import 'package:skyone_mobile/modules/login/index.dart';
import 'package:skyone_mobile/modules/message/index.dart';
import 'package:skyone_mobile/modules/profile/index.dart';
import 'package:skyone_mobile/modules/menu/index.dart';
import 'package:skyone_mobile/modules/splash/index.dart';
import 'package:skyone_mobile/the_app_controller.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/app.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/widgets/default_drawer.dart';
import 'package:skyone_mobile/widgets/stab_bar.dart';
import 'package:skyone_mobile/widgets/tab_bar_item.dart';
import 'package:skyone_mobile/pt/proto/auth/auth_service.pbgrpc.dart';
import 'package:skyone_mobile/grpc//helper.dart';
import 'package:skyone_mobile/grpc//service_url.dart';
import 'package:skyone_mobile/pt/google/protobuf/empty.pb.dart' as protobuf;

class TheApp extends StatelessWidget {
  final TheAppController _theAppController = Get.put(TheAppController());
  final ThemeController _themeController = Get.find();
  static final NotifyController _notifyController = Get.put(NotifyController());
  static final RxInt _selectedIndex$ = RxInt(0);

  @override
  Widget build(BuildContext context) {
//    Future.delayed(Duration(seconds: 5)).then((value) {
//      _notifyController.messageNotify$.value = 999;
//    });

    final textColor = _themeController.getPrimaryBodyTextColor();

    final homeIcon = Icon(
      FontAwesomeIcons.home,
      color: textColor,
    );
    final scheduleIcon = Icon(
      FontAwesomeIcons.home,
      color: textColor,
    );
    final calendarIcon = SvgPicture.asset(
      'assets/calendar.svg',
      height: 24,
      width: 24,
      color: textColor,
    );
    final messageIcon = SvgPicture.asset(
      'assets/message.svg',
      height: 24,
      width: 24,
      color: textColor,
    );
    final profileIcon = Icon(
      FontAwesomeIcons.user,
      color: textColor,
    );

    return Obx(() => Scaffold(
          drawer: DefaultDrawer(),
          appBar: _theAppController.showAppBar.value ? AppBar(title: const Text(App.appName),) : null,
          body: Center(child: _buildPage(context, _theAppController.appStatusContainer.value.status)),
          bottomNavigationBar:
              (_theAppController.appStatusContainer.value.status is LoggedInStatus) ? buildBottomTab() : null,
        ));
  }

  static Widget buildBottomTab() {
    return STabBar(
      height: 65,
      children: [
        TabBarItem(
          index: 0,
          iconData: Icons.home,
          title: 'HOME.TAB.HOME'.t(),
          notifyNumber$: _notifyController.messageNotify$,
          selectedIndex$: _selectedIndex$,
        ),
        TabBarItem(
          index: 1,
          iconData: Icons.menu,
          title: 'HOME.TAB.MENU'.t(),
          notifyNumber$: _notifyController.scheduleNotify$,
          selectedIndex$: _selectedIndex$,
        ),
        TabBarItem(
          index: 2,
          assetSvg: 'assets/calendar.svg',
          title: 'HOME.TAB.CALENDAR'.t(),
          notifyNumber$: _notifyController.scheduleNotify$,
          selectedIndex$: _selectedIndex$,
        ),
        TabBarItem(
          index: 3,
          assetSvg: 'assets/message.svg',
          title: 'HOME.TAB.MESSAGE'.t(),
          notifyNumber$: _notifyController.scheduleNotify$,
          selectedIndex$: _selectedIndex$,
        ),
        TabBarItem(
          index: 4,
          iconData: FontAwesomeIcons.user,
          title: 'HOME.TAB.PROFILE'.t(),
          notifyNumber$: _notifyController.scheduleNotify$,
          selectedIndex$: _selectedIndex$,
        ),
      ],
    );
  }

  Widget _buildPage(BuildContext context, appStatus) {
    if (appStatus is SplashStatus) {
      return SplashPage();
    } else if (appStatus is EntryStatus) {
      return EntryPage();
    } else if (appStatus is LoginStatus) {
      return const LoginPage();
    } else if (appStatus is LoginWithCustomerStatus) {
      return LoginPage(
        companyId: appStatus.companyId,
        nodeId: appStatus.nodeId,
      );
    } else {
      if (_selectedIndex$.value == 0) {
        return HomePage();
      } else if (_selectedIndex$.value == 1) {
        return MenuPage();
      } else if (_selectedIndex$.value == 2) {
        return CalendarPage();
      } else if (_selectedIndex$.value == 3) {
        return MessagePage();
      } else if (_selectedIndex$.value == 4) {
        return ProfilePage();
      }
    }
  }



  static void logout(BuildContext context) async {
    final channel = createChannel(ServiceURL.core);
    final client = AuthServiceClient(channel);
    final request = protobuf.Empty();
    await authCall(client.logoutHandler, request);
    channel.shutdown();
    forceLogout(context);
  }

  static void forceLogout(BuildContext context) async {
    App.storage.remove("REMEMBER_LOGIN");
    App.storage.remove("ACCESS_TOKEN");
    App.storage.remove("REFRESH_TOKEN");
    Navigator.pop(context);
    Get.find<TheAppController>().changeStatus(LoginStatus());

    await googleSignIn.signOut();
    await facebookSignIn.logOut();
//    await zaloSignIn.logOut();
  }

  BottomNavigationBarItem _buildItemBar(String title, Widget wIcon, int numberNotify) {
    return BottomNavigationBarItem(
      icon: SizedBox(
        width: 45,
        height: 40,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            wIcon,
            if (numberNotify >= 1)
              Positioned(
                right: 0,
                top: 5,
                child: Container(
                  height: 20,
                  width: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _themeController.getBadgeColor(),
                      borderRadius: BorderRadius.circular(defaultBorderRadius)),
                  child: Text(
                    '$numberNotify',
                    style: TextStyle(fontSize: 13, color: _themeController.getBadgeTextColor()),
                  ),
                ),
              )
          ],
        ),
      ),
      title: Text(title),
    );
  }
}

class NotifyController extends GetxController {
  final RxInt messageNotify$ = RxInt(0);
  final RxInt scheduleNotify$ = RxInt(0);
}
