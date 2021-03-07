import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skyone/extensions/string.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/system/login/controller.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/widgets/rx_button.dart';
import 'package:skyone/widgets/rx_checkbox.dart';
import 'package:skyone/widgets/rx_text_field.dart';

class LoginPage extends StatelessWidget {
  final LoginController _loginController = Get.find();
  final ThemeController _themeController = Get.find();
  final _loginButtonController =
      newController(RxButtonController(), tag: "login.loginButton");

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: _buildBody()));
  }

  Widget _buildBody() {
    final textColor = _themeController.getPrimaryBodyTextColor();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: MaterialButton(
                    onPressed: () {},
                    child: Image.asset(
                      "assets/logo.png",
                      height: 120,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                RxTextField(
                  required: true,
                  label: 'SYS.LABEL.USERNAME'.t,
                  rxController: _loginController.rxUsername,
                ),
                RxTextField(
                  required: true,
                  label: 'SYS.LABEL.PASSWORD'.t,
                  rxController: _loginController.rxPassword,
                  obscureText: true,
                ),
                RxCheckbox(
                    onChanged: (bool value) {
                      _loginController.rememberLogin = value;
                    },
                    label: 'SYS.LABEL.REMEMBER'.t),
                Obx(
                  () => RxButton(
                    onPressed: !_loginController.formValid
                        ? null
                        : () async {
                            _loginButtonController.setLoading(true);
                            final errorMessage = await _loginController.login();
                            if (errorMessage != null) {
                              Get.snackbar('SYS.MSG.AUTH_ERROR', errorMessage,
                                  snackPosition: SnackPosition.BOTTOM);
                            }
                            _loginButtonController.setLoading(false);
                          },
                    label: 'SYS.BUTTON.LOGIN'.t,
                    icon: Icon(Icons.login),
                    isPrimary: true,
                    rxController: _loginButtonController,
                  ),
                ),
                MaterialButton(
                  onPressed: () {},
                  child: Text('SYS.BUTTON.FORGOT_PASSWORD'.t + '?'),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showActionSheet();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                            child: Text(
                          "SYS.BUTTON.OTHER_LOGIN_METHOD".t,
                          style: TextStyle(color: textColor),
                        )),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: textColor,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showActionSheet() {
    showModalBottomSheet(
        context: Get.context,
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RxButton(
                      label: 'SYS.BUTTON.GOOGLE'.t,
                      icon: Icon(
                        FontAwesomeIcons.google,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    RxButton(
                      label: 'SYS.BUTTON.FACEBOOK'.t,
                      icon: Icon(
                        FontAwesomeIcons.facebook,
                        color: Colors.blue,
                      ),
                      onPressed: () async {},
                    ),
                    RxButton(
                      label: 'SYS.BUTTON.ZALO'.t,
                      icon: Image.asset('assets/zalo.jpeg',
                          width: 26, height: 26),
                      onPressed: () {},
                    ),
                    RxButton(
                      label: 'SYS.BUTTON.APPLE'.t,
                      icon: Icon(
                        FontAwesomeIcons.apple,
                      ),
                      onPressed: () async {},
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
