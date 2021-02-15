import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grpc/grpc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skyone_mobile/modules/home/index.dart';
import 'package:skyone_mobile/modules/login/repo.dart';
import 'package:skyone_mobile/modules/login/validation.dart';
import 'package:skyone_mobile/pt/proto/auth/auth_service.pb.dart';
import 'package:skyone_mobile/the_app_controller.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/app.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/util/global_param.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/util/locale_resource.dart';
import 'package:skyone_mobile/util/server.dart';
import 'package:skyone_mobile/widgets/full_rounded_button.dart';
import 'package:skyone_mobile/widgets/scheckbox.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';
import 'package:async/async.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/widgets/sflat_button.dart';
import 'package:http/http.dart' as http;
import 'package:skyone_mobile/modules/entry/index.dart';

class LoginPage extends StatefulWidget {
  final int companyId;
  final int nodeId;
  const LoginPage({this.companyId, this.nodeId});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final EntryController _entryController = Get.put(EntryController());
  final _loginSubject = BehaviorSubject<String>();
  final _loginValidation = LoginValidation();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscureText = true;
  var _isCanceled = false;
  var _isLoggingIn = false;
  var _rememberLogin = App.storage.getBool('REMEMBER_LOGIN') ?? false;
  CancelableCompleter _loginCompleter;
  var _hitCount = 0;
  final ThemeController _themeController = Get.find();

  @override
  void initState() {
    _usernameController.addListener(() {
      _loginValidation.usernameSink.add(_usernameController.text.trim());
    });

    _passwordController.addListener(() {
      _loginValidation.passwordSink.add(_passwordController.text.trim());
    });

//    zaloSignIn.init();
    super.initState();
  }

  @override
  void dispose() {
    _loginSubject.close();
    _loginValidation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: _loginSubject.stream,
        builder: (context, snapshot) {
          if (_checkRememberLogin() && !snapshot.hasData) {
            return FutureBuilder(
                future: _checkValidToken(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final theAppController = Get.find<TheAppController>();
                    theAppController.changeStatus(LoggedInStatus());

                    return HomePage();
                  } else {
                    return _buildLoginPage(context);
                  }
                });
          } else if (snapshot.hasData && snapshot.data == 'loggedIn') {
            final theAppController = Get.find<TheAppController>();
            theAppController.changeStatus(LoggedInStatus());
            LoginRepo.initData(GlobalParam.userId);
            return HomePage();
          } else if (snapshot.hasData && snapshot.data == 'loggingIn') {
            return _buildLoginPage(context, isLoggingIn: _isLoggingIn);
          } else {
            return _buildLoginPage(context);
          }
        });
  }

  bool _checkRememberLogin() {
    return App.storage.getBool('REMEMBER_LOGIN') ?? false;
  }

  Future<bool> _checkValidToken() async {
    GlobalParam.accessToken = App.storage.getString("ACCESS_TOKEN");
    GlobalParam.userId = App.storage.getInt("USER_ID");
    final res = await LoginRepo.isValidToken(GlobalParam.accessToken);
    await LoginRepo.initData(GlobalParam.userId);
    return res.item1;
  }

  void _checkLogin(BuildContext context) {
    print('CompanyID ${widget.companyId}');
    print('Node ID ${widget.nodeId}');
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (!_isCanceled) {
      _loginSubject.add('loggingIn');
      _isLoggingIn = true;
      _loginCompleter = CancelableCompleter(onCancel: () {
        _isCanceled = true;
        _isLoggingIn = false;
      });

      _loginCompleter.complete(LoginRepo.login(username: username, password: password));
      _loginCompleter.operation.value.then((res) {
        if (res.item1 != null) {
          final loginResponse = res.item1 as LoginResponse;
          _saveLoggedState(loginResponse.userId.toInt(), loginResponse.accessToken.toString(), loginResponse.refreshToken.toString() );
        } else if (res.item2 != null) {
          final grpcError = res.item2 as GrpcError;
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(LR.l10n(grpcError.message)),
          ));
          _clearRememberingLogin();
          _loginSubject.add(grpcError.message);
        }
      });

      _loginCompleter.operation.value.whenComplete(() {
        _isLoggingIn = false;
        _isCanceled = false;
      });
    } else if (_loginCompleter != null) {
      _clearRememberingLogin();
      _isLoggingIn = false;
      _loginSubject.add("loggingIn");
      _loginCompleter.operation.cancel();
    }
    _isCanceled = !_isCanceled;
  }

  void _saveLoggedState(int userId, String accessToken, String refreshToken) {
    _saveToken(userId, accessToken, refreshToken);
    if (_rememberLogin) {
      _saveRememberingLogin();
    }
    _loginSubject.add("loggedIn");
  }

  Widget _buildLoginPage(BuildContext context, {bool isLoggingIn = false}) {
    final textColor = _themeController.getPrimaryBodyTextColor();
    return Column(
      children: [
        if (!_entryController.isDefaultCustomer())
        Container(
          height: 30,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          color: _themeController.getPrimaryColor(),
          child: FlatButton(
            onPressed: (){
              final TheAppController theAppController = Get.find();
              theAppController.changeStatus(EntryStatus());
            },
            child: Icon(Icons.arrow_back, color: _themeController.getPrimaryBodyTextColor(),),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(50),
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FlatButton(
                  onPressed: () {
                    if (++_hitCount == 3) {
                      ServerConfig.showConfigDialog(context);
                      _hitCount = 0;
                    }
                  },
                  child: Image.asset(
                    "assets/logo.png",
                    height: 120,
                    fit: BoxFit.fill,
                  ),
                ),
                StreamBuilder<String>(
                    stream: _loginValidation.usernameStream,
                    builder: (context, snapshot) {
                      return TextField(
                        autocorrect: false,
                        decoration: InputDecoration(
                          errorText: snapshot.data,
                          labelText: LR.l10n('SYS.LABEL.USERNAME'),
                        ),
                        controller: _usernameController,
                      );
                    }),
                StreamBuilder<String>(
                    stream: _loginValidation.passwordStream,
                    builder: (context, snapshot) {
                      return TextField(
                        autocorrect: false,
                        decoration: InputDecoration(
                            errorText: snapshot.data,
                            labelText: LR.l10n('SYS.LABEL.PASSWORD'),
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: const Icon(Icons.remove_red_eye),
                            )),
                        controller: _passwordController,
                        obscureText: _obscureText,
                      );
                    }),
                SCheckbox(
                    onChanged: (bool value) {
                      _rememberLogin = value;
                    },
                    checked: _rememberLogin,
                    text: LR.l10n('SYS.LABEL.REMEMBER')),
                StreamBuilder<Object>(
                    stream: _loginValidation.loginStream,
                    builder: (context, snapshot) {
                      return FullRoundedButton(
                        onPressed: snapshot.data == true
                            ? () {
                                _checkLogin(context);
                              }
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLoggingIn) SCircularProgressIndicator.buildSmallest(),
                            if (isLoggingIn)
                              const SizedBox(
                                width: 10,
                              ),
                            if (isLoggingIn) Text(LR.l10n('SYS.BUTTON.CANCEL_LOGIN'), style: TextStyle(color: textColor),),
                            if (!isLoggingIn) Text(LR.l10n('SYS.BUTTON.LOGIN'), style: TextStyle(color: textColor),),
                          ],
                        ),
                      );
                    }),
                FlatButton(
                  onPressed: () {},
                  child: Text(LR.l10n('SYS.BUTTON.FORGOT_PASSWORD') + '?'),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FullRoundedButton(
                    onPressed: () {
                      _showActionSheet();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(child: Text("SYS.BUTTON.OTHER_LOGIN_METHOD".t(), style: TextStyle(color: textColor),)),
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
            )),
          ),
        ),
      ],
    );
  }

  void _saveRememberingLogin() async {
    await App.storage.setBool('REMEMBER_LOGIN', true);
  }

  void _clearRememberingLogin() async {
    await App.storage.remove('REMEMBER_LOGIN');
  }

  void _saveToken(int userId, String accessToken, String refreshToken) async {
    GlobalParam.accessToken = accessToken;
    GlobalParam.refreshToken = refreshToken;
    GlobalParam.userId = userId;
    await App.storage.setInt('USER_ID', userId);
    await App.storage.setString('ACCESS_TOKEN', accessToken);
    await App.storage.setString('REFRESH_TOKEN', refreshToken);
  }

  void _showActionSheet() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            width: double.infinity,
            height: 60,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SFlatButton(
                    text: 'SYS.BUTTON.GOOGLE'.t(),
                    icon: const Icon(
                      FontAwesomeIcons.google,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        final GoogleSignInAccount res = await googleSignIn.signIn();
                        if (res.email != null) {
//                          final Tuple2<LoginResponse, dynamic> verifiedRes =
//                              await LoginRepo.signInWithOauth2(id: res.email);
//                          if (verifiedRes.item1 != null) {
//                            _saveLoggedState(verifiedRes.item1.userId, verifiedRes.item1.token);
//                          }
                        }
                      } catch (error) {
                        log(error);
                      }
                    },
                  ),
                  SFlatButton(
                    text: 'SYS.BUTTON.FACEBOOK'.t(),
                    icon: const Icon(
                      FontAwesomeIcons.facebook,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await facebookSignIn.logIn(['email']);
                      final token = result.accessToken.token;
                      final graphResponse = await http.get(
                          'https://graph.facebook.com/v2.12/me?fields=picture,name,first_name,last_name,email&access_token=$token');
                      final profile = json.decode(graphResponse.body);
                      if (profile['email'] != null) {
//                        final Tuple2<LoginResponse, dynamic> verifiedRes =
//                        await LoginRepo.signInWithOauth2(id: profile['email'] as String);
//                        if (verifiedRes.item1 != null) {
//                          _saveLoggedState(verifiedRes.item1.userId, verifiedRes.item1.token);
//                        }
                      }
                    },
                  ),
                  SFlatButton(
                    text: 'SYS.BUTTON.ZALO'.t(),
                    icon: Image.asset('assets/zalo.jpeg', width: 26, height: 26),
                    onPressed: () async {
                      Navigator.pop(context);
//                      final res = await zaloSignIn.logIn();
//                      log(await zaloSignIn.isAuthenticated());
                    },
                  ),
                  SFlatButton(
                    text: 'SYS.BUTTON.APPLE'.t(),
                    icon: const Icon(
                      FontAwesomeIcons.apple,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
