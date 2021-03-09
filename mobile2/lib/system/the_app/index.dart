import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/global/variable.dart';
import 'package:skyone/pt/proto/auth/auth_service.pbgrpc.dart';
import 'package:skyone/system/grpc/helper.dart';
import 'package:skyone/system/grpc/service_url.dart';
import 'package:skyone/system/i18n/delegate.dart';
import 'package:skyone/system/layout/index.dart';
import 'package:skyone/system/login/index.dart';
import 'package:skyone/system/the_app/controller.dart';
import 'package:skyone/system/the_app/error.dart';
import 'package:skyone/system/the_app/loading/error.dart';
import 'package:skyone/system/the_app/loading/index.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/pt/google/protobuf/empty.pb.dart';
import 'package:skyone/widgets/circular_progress.dart';

class TheApp extends StatelessWidget {
  static final TheAppController _theAppController = Get.find();
  final ThemeController _themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var locale = Get.deviceLocale;
    if (AppInfo.locale != null) {
      var split = AppInfo.locale.split("-");
      if (split.length > 1) {
        locale = Locale(AppInfo.locale.split("-")[0], AppInfo.locale.split("-")[1]);
      }
    }
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_NAME,
      theme: _themeController.themeData.value,
      localizationsDelegates: [
        I18nDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      locale: locale,
      home: GetBuilder(
        init: _theAppController,
        id: 'appStatus',
        builder: (TheAppController controller) {
          if (controller.appStatus == AppStatus.login) {
            return LoginPage();
          } else if (controller.appStatus == AppStatus.loading) {
            return LoadingPage();
          } else if (controller.appStatus == AppStatus.loaded) {
            return LayoutPage();
          } else if (controller.appStatus == AppStatus.initError) {
            return InitErrorPage();
          } else if (controller.appStatus == AppStatus.loadingError) {
            return LoadingErrorPage();
          }

          return Scaffold(
            body: CircularProgress.smallCenter(),
          );
        },
      ),
      getPages: [],
    );
  }

  static void logout() async {
    final channel = createChannel(ServiceURL.core);
    final client = AuthServiceClient(channel);
    final request = Empty();
    await authCall(client.logoutHandler, request);
    channel.shutdown();
    forceLogout();
  }

  static void forceLogout() async {
    storage.remove(KEY_REMEMBER_LOGIN);
    storage.remove(KEY_ACCESS_TOKEN);
    storage.remove(KEY_REFRESH_TOKEN);

    // Navigator.of(context).pop();
    // Navigator.of(context).popUntil((route) => route.isFirst);
    _theAppController.changeAppStatus(AppStatus.login);
    // await googleSignIn.signOut();
    // await facebookSignIn.logOut();
//    await zaloSignIn.logOut();
  }
}
