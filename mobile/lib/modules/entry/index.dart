import 'dart:convert';

import 'package:skyone_mobile/extension/string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:skyone_mobile/modules/entry/model.dart';
import 'package:skyone_mobile/the_app_controller.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/global_param.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';

class EntryPage extends StatelessWidget {
  final EntryController _entryController = Get.find();
  final ThemeController _themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              'assets/logo.png',
              height: 100,
            ),
            Text('COMMON.LABEL.PLEASE_SELECT_ONE'.t()),
            Flexible(
              child: Obx(() {
                if (_entryController.customers.value?.isEmpty ?? false) {
                  return SCircularProgressIndicator.buildSmallest();
                } else {
                  return ListView.builder(
                      itemCount: _entryController.customers.value?.length ?? 0,
                      itemBuilder: (_, index) {
                        return InkWell(
                          onTap: () {
                            final TheAppController theAppController = Get.find();
                            theAppController.changeStatus(LoginWithCustomerStatus(
                                companyId: _entryController.customers.value[index].skyoneCompanyId as int,
                                nodeId: _entryController.customers.value[index].skyoneNode as int));
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: defaultPadding,
                                child: _buildLogo(_entryController.customers.value[index].logo as String),
                              ),
                              Container(
                                padding: defaultPadding,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${_entryController.customers.value[index].name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                    Text('${_entryController.customers.value[index].description}', style: const TextStyle(fontStyle: FontStyle.italic),),
                                    if (_entryController.customers.value[index].address != null)
                                      Text('${_entryController.customers.value[index].address}'),
                                    if (_entryController.customers.value[index].phone != null ||
                                        _entryController.customers.value[index].email != null)
                                      Text(_formatPhoneAndEmail(_entryController.customers.value[index].phone as String,
                                          _entryController.customers.value[index].email as String), style: TextStyle(color: _themeController.getPrimaryColor()),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo (String data) {
    if(data != null && data.isNotEmpty) {
      return Image.memory(base64Decode(data), width: 50, height: 50,);
    } else {
      return const Icon(Icons.home, size:50,);
    }

  }

  String _formatPhoneAndEmail(String phone, String email) {
    if ((phone == null || phone.isEmpty) && (email == null || email.isEmpty)) {
      return '';
    } else if ((phone != null && phone.isNotEmpty) && (email == null || email.isEmpty)) {
      return phone;
    } else if ((email != null && email.isNotEmpty) && (phone == null || phone.isEmpty)) {
      return email;
    } else {
      return '$phone - $email';
    }
  }
}

class EntryController extends GetxController {
  final RxList customers = RxList();

  EntryController() {
    http
        .get('http://172.16.30.17:3000/api/customers', headers: {
          'Content-Type': 'application/json',
        })
        .timeout(Duration(seconds: GlobalParam.connectionTimeout))
        .then((res) {
          final List listCustomers =
              jsonDecode(res.body).map((it) => Customer.fromJson(it as Map<String, dynamic>)).toList() as List;

          customers.value = listCustomers;
        });
  }

  bool isDefaultCustomer() {
    return true;
  }
}
