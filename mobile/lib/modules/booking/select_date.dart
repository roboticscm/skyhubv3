import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/modules/booking/controller.dart';
import 'package:skyone_mobile/modules/booking/select_doctor.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/date.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/util/number.dart';
import 'package:skyone_mobile/widgets/calendar.dart';
import 'package:skyone_mobile/widgets/full_rounded_button.dart';
import 'package:skyone_mobile/widgets/simple_time_picker.dart';

import 'model.dart';

class SelectDate extends StatelessWidget {
  final int serviceId;
  final int doctorId;
  final String serviceName;
  final String doctorName;
  final num price;
  final ThemeController _themeController = Get.find();
  final BookingController _bookingController = Get.find();
  final RxBool _rxSaveLoading = RxBool(false);
  final RxInt _rxSelectedHour = RxInt();
  final RxInt _rxSelectedMinute = RxInt();
  final TextEditingController _noteController = TextEditingController();
  DateTime _bookingDate;

  SelectDate({this.serviceId, this.doctorId, this.serviceName, this.doctorName, this.price});

  @override
  Widget build(BuildContext context) {
    _bookingController.loadDoctors(serviceId: serviceId);
    return SafeArea(
      child: Scaffold(
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
          title: Text('${'BOOKING.LABEL.SELECT_DATE'.t()} (${'COMMON.LABEL.FINAL_STEP'.t()})'),
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
                    style: TextStyle(color: _themeController.getDisabledColor()),
                  ),
                  Text(
                    '${'BOOKING.LABEL.SELECT_DOCTOR'.t()}/',
                    style: TextStyle(color: _themeController.getDisabledColor()),
                  ),
                  Text('BOOKING.LABEL.SELECT_DATE'.t()),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          padding: defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Calendar(
                onChanged: (DateTime newValue) {
                  _bookingDate = newValue;
                  _rxSelectedHour.value = _rxSelectedHour.value;
                },
              )),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Text('${'COMMON.LABEL.TIME'.t()}:'),
                    const SizedBox(
                      width: defaultPaddingValue,
                    ),
                    SimpleTimePicker(
                      selectedHour: _rxSelectedHour,
                      selectedMinute: _rxSelectedMinute,
                    ),
                  ],
                ),
              ),

              if (doctorId == null)
                FullRoundedButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SelectDoctor(serviceId: serviceId, serviceName: serviceName, price: price)));
                }, title: 'COMMON.BUTTON.NEXT'.t(),),
              if (doctorId != null)
                Text(
                  '${'COMMON.LABEL.SUMMARY'.t()}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (doctorId != null)
                Container(
                  padding: defaultPadding,
                  margin: const EdgeInsets.only(top: defaultPaddingValue, bottom: defaultPaddingValue),
                  decoration: BoxDecoration(
                      border: Border.all(color: _themeController.getDisabledColor()),
                      borderRadius: BorderRadius.circular(defaultBorderRadius)),
                  child: Column(
                    children: [
                      Html(data: '${'BOOKING.LABEL.SERVICE'.t()}: <b>$serviceName</b>'),
                      Html(data: '${'BOOKING.LABEL.PRICE'.t()}: <b>${Number.formatCurrency(price)}</b>'),
                      Html(data: '${'BOOKING.LABEL.DOCTOR'.t()}: <b>$doctorName</b>'),
                      Obx(() => Html(data: '${'BOOKING.LABEL.SCHEDULE'.t()}: <b>${_getSchedule()}</b>')),
                    ],
                  ),
                ),
              if (doctorId != null)
                FullRoundedButton(
                  rxLoading: _rxSaveLoading,
                  title: 'BOOKING.BUTTON.BOOK'.t(),
                  onPressed: () async {
                    _rxSaveLoading.value = true;
                    await _bookingController
                        .book(Booking(serviceId: serviceId, doctorId: doctorId, note: _noteController.text.trim()));
                    _rxSaveLoading.value = false;
                    Navigator.popUntil(context, (route) {
                      return route.isFirst;
                    });
                  },
                  icon: Icon(
                    FontAwesomeIcons.cartPlus,
                    color: _themeController.getPrimaryBodyTextColor(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSchedule() {
    return '${_rxSelectedHour?.value ?? 'HH'}:${_rxSelectedMinute?.value ?? 'MM'} - ${Date.getDmyStr(_bookingDate)}';
  }
}
