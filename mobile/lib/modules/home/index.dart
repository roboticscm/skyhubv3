import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/modules/booking/index.dart';
import 'package:skyone_mobile/modules/home/model.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/util/http.dart';
import 'package:skyone_mobile/util/string_util.dart';
import 'package:skyone_mobile/widgets/full_rounded_button.dart';

class HomePage extends StatelessWidget {
  final ThemeController _themeController = Get.put(ThemeController());
  final marginTop = 30.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: defaultPadding,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildEvent(context),
            SizedBox(
              height: marginTop,
            ),
            FullRoundedButton(
                title: "HOME.BUTTON.BOOKING".t(),
                icon: SvgPicture.asset(
                  'assets/calendar.svg',
                  height: 24,
                  color: _themeController.getPrimaryBodyTextColor(),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> Booking() ));
                }),
            SizedBox(
              height: marginTop + 20,
            ),
            FullRoundedButton(title: "HOME.BUTTON.MEDICAL_RECORD".t(), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildEvent(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.3;

    return Container(
      height: height,
      child: GetX(
        init: EventController(),
        builder: (EventController eventController) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                  child: _buildEventImage(eventController)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Html(
                    data: '<div>${eventController.rxEvent.value?.title ?? ''}</div>',
                    style: {
                      "div": Style(
                        color: Colors.deepPurple,
                        textAlign: TextAlign.center,
                        fontSize: const FontSize(20.0),
                      )
                    },
                  ),
                  Html(
                    data: '<div>${eventController.rxEvent.value?.description ?? ''}</div>',
                    style: {
                      "div": Style(
                        color: Colors.deepPurple,
                        textAlign: TextAlign.center,
                        fontSize: const FontSize(16.0),
                      )
                    },
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventImage(EventController eventController) {
    if (eventController.rxEvent.value?.imageUrl != null) {
      return FadeInImage.memoryNetwork(
          fit: BoxFit.fill, placeholder: transparentImage, image: eventController.rxEvent.value?.imageUrl);
    } else {
      return Image.asset('assets/logo.png');
    }
  }
}

class EventController extends GetxController {
  final Rx<Event> rxEvent = Rx<Event>();

  EventController() {
    Http.get(StringUtil.toSnackCase('eventGetAds')).then((res) {
      rxEvent.value = Event.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    });
  }
}
