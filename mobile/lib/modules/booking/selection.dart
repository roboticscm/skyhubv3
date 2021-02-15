import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/modules/booking/select_date.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/full_rounded_button.dart';

import 'select_doctor.dart';

class Selection extends StatelessWidget {
  final int serviceId;
  final String serviceName;
  final num price;
  final ThemeController _themeController = Get.find();

  Selection({this.serviceId, this.serviceName, this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(
                'COMMON.BUTTON.CANCEL'.t(),
                style: TextStyle(color: _themeController.getErrorTextColor()),
              ))
        ],
        title: Text('${'BOOKING.LABEL.SELECTION'.t()} (${'BOOKING.LABEL.STEP_2'.t()}/4)'),
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Text(
                  '${'BOOKING.LABEL.BOOKING'.t()}/',
                  style: TextStyle(color: _themeController.getDisabledColor()),
                ),
                Text(
                  '${'BOOKING.LABEL.SELECT_DOCTOR_OR_DATE'.t()}/',
                ),
                Text(
                  '${'BOOKING.LABEL.SELECT_DOCTOR'.t()}/',
                  style: TextStyle(color: _themeController.getDisabledColor()),
                ),
                Text('BOOKING.LABEL.SELECT_DATE'.t(), style: TextStyle(color: _themeController.getDisabledColor())),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: defaultPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FullRoundedButton(
              title: 'BOOKING.BUTTON.SELECT_DOCTOR'.t(),
              icon: Icon(
                FontAwesomeIcons.userMd,
                color: _themeController.getPrimaryBodyTextColor(),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SelectDoctor(serviceId: serviceId, serviceName: serviceName, price: price)));
              },
            ),
            const SizedBox(
              height: defaultPaddingValue,
            ),
            FullRoundedButton(
              title: 'BOOKING.BUTTON.SELECT_EXAMINATION_DATE'.t(),
              icon: Icon(
                FontAwesomeIcons.calendar,
                color: _themeController.getPrimaryBodyTextColor(),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SelectDate(serviceId: serviceId, serviceName: serviceName, price: price)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
