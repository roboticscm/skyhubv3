import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/features/booking/controller.dart';
import 'package:skyone_mobile/features/booking/select_date.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/filter_field.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';

class SelectDoctor extends StatelessWidget {
  final int serviceId;
  final String serviceName;
  final num price;
  final ThemeController _themeController = Get.find();
  final BookingController _bookingController = Get.find();

  SelectDoctor({this.serviceId, this.serviceName, this.price});

  @override
  Widget build(BuildContext context) {
    _bookingController.loadDoctors(serviceId: serviceId);
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
        title: Text('${'BOOKING.LABEL.SELECT_DOCTOR'.t()} (${'BOOKING.LABEL.STEP_3'.t()}/4)'),
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Text('${'BOOKING.LABEL.BOOKING'.t()}/', style: TextStyle(color: _themeController.getDisabledColor()),),
                Text('${'BOOKING.LABEL.SELECT_DOCTOR_OR_DATE'.t()}/', style:  TextStyle(color: _themeController.getDisabledColor()),),
                Text('${'BOOKING.LABEL.SELECT_DOCTOR'.t()}/',),
                Text('BOOKING.LABEL.SELECT_DATE'.t(), style: TextStyle(color: _themeController.getDisabledColor())),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        padding: defaultPadding,
        child: Column(
          children: [
            FilterField(
              onSearch: (String newValue) {
                _bookingController.loadDoctors(serviceId: serviceId, search: newValue);
              },
            ),
            Obx(
              () {
                if ((_bookingController.rxDoctors?.value?.length ?? 0) == 0) {
                  return SCircularProgressIndicator.buildSmallCenter();
                } else {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: _bookingController.rxDoctors?.value?.length ?? 0,
                        itemBuilder: (_, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_)=>SelectDate(
                                price: price,
                                serviceId: serviceId,
                                serviceName: serviceName,
                                doctorId: _bookingController.rxDoctors?.value[index].id as int,
                                doctorName: '${_bookingController.rxDoctors?.value[index].title}. ${_bookingController.rxDoctors?.value[index].fullName}',
                              )));
                            },
                            child: Container(
                              padding: defaultPadding,
                              margin: const EdgeInsets.only(bottom: defaultPaddingValue),
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(40),
                                borderRadius: BorderRadius.circular(defaultBorderRadius),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: Image.asset('assets/test.jpg', width: 80, height: 80, fit: BoxFit.fill,),
                                      ),
                                      const SizedBox(width: defaultPaddingValue,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${_bookingController.rxDoctors?.value[index].title}. ${_bookingController.rxDoctors?.value[index].fullName}', style: const TextStyle(fontWeight: FontWeight.bold),),
                                          Text(_bookingController.rxDoctors?.value[index].department as String),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('BOOKING.LABEL.EXAM_SCHEDULE'.t(), style: const TextStyle(fontWeight: FontWeight.bold),),
                                    ...(_bookingController.rxDoctors?.value[index].schedule as String).split(',').map((e) => Text(e)).toList()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
