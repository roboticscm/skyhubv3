import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:skyone/extensions/string.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/system/db_notify_listener/controller.dart';
import 'package:skyone/system/login/controller.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/widgets/rx_button.dart';

class QrCodeViewer extends StatefulWidget {
  @override
  _QrCodeViewerState createState() => _QrCodeViewerState();
}

class _QrCodeViewerState extends State<QrCodeViewer> {
  final ThemeController _themeController = Get.find();
  final LoginController _loginController = Get.find();
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  final DbNotifyListenerController _dbNotifyListenerController = Get.find();
  Barcode _result;
  QRViewController _controller;

  @override
  void initState() {
    super.initState();
    try {
      final stream = _dbNotifyListenerController.register();
      if (stream != null) {
        stream.listen((value) {
          if ((value as NotifyListener).table == "auth_token") {
            if((value as NotifyListener).data["authenticated"]) {
              Get.back(result: true);
            }
          }
        });
      }
    } catch (e) {
      log(e);
    }

  }
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller.pauseCamera();
    } else if (Platform.isIOS) {
      _controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SYS.LABEL.QR_CODE_SCANNER'.t),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                QRView(
                  overlay: QrScannerOverlayShape(),
                  key: _qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                SizedBox(
                  height: 200,
//                  width: double.infinity,
                  child: Center(
                      child: Text(
                    _result == null ? 'SYS.LABEL.MOVE_CAMERA_TO_THE_QR_CODE'.t : 'SYS.LABEL.DONE'.t,
                    style: TextStyle(color: _themeController.getPrimaryBodyTextColor()),
                  )),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RxButton(
                        onPressed: () {
                          _controller.resumeCamera();
                          setState(() {
                            _result = null;
                          });
                        },
                        label: 'SYS.BUTTON.NEW'.t,
                        icon: Icon(Icons.add),
                      ),
                      RxButton(
                        onPressed: () {},
                        label: 'SYS.BUTTON.IMAGE'.t,
                        icon: Icon(Icons.image),
                      ),
                      RxButton(
                        onPressed: () {},
                        label: 'SYS.BUTTON.MY_QR_CODE'.t,
                        icon: Icon(Icons.qr_code),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_result != null && _result.code.startsWith('[AUTH]'))
                        RxButton(
                          onPressed: () async {
                            try {
                              await _loginController.updateAuthToken(int.tryParse(_result.code.replaceFirst("[AUTH]", "")));
                            } catch (e) {
                              Get.snackbar('SYS.LABEL.REMOTE_LOGIN', e.toString());
                            }

                          },
                          label: 'SYS.BUTTON.LOGIN'.t,
                          icon: Icon(Icons.login),
                          isPrimary: true,
                        ),
                      if (_result != null && !_result.code.startsWith('[AUTH]'))
                        Expanded(
                          child: Center(
                              child: Text(_result.code??'',
                            overflow: TextOverflow.ellipsis,
                          )),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _result = scanData;
        controller.pauseCamera();
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
