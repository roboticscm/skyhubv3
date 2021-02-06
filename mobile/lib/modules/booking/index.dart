import 'dart:async';
import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/the_app.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/util/number.dart';
import 'package:skyone_mobile/widgets/dropdown.dart';
import 'package:skyone_mobile/widgets/filter_field.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';
import 'package:skyone_mobile/widgets/simple_date_picker.dart';

import 'controller.dart';
import 'model.dart';
import 'selection.dart';

class Booking extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final BookingController _bookingController = Get.put(BookingController());
  final RxString _rxFullNameError = RxString('');
  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  final RxString _rxPhoneError = RxString();
  String _phoneNumber;

  final RxString _rxEmailError = RxString();
  final TextEditingController _emailController = TextEditingController();

  final RxString _rxGender = RxString();
  final RxInt _rxBirthYear = RxInt();
  final RxInt _rxBirthMonth = RxInt();
  final RxInt _rxBirthDay = RxInt();

  String phoneNumber;
  String phoneIsoCode;

  Booking() {
    FlutterLibphonenumber().init();
    _fullNameController.addListener(() {
      if (_fullNameController.text.isEmpty) {
        _rxFullNameError.value = 'BOOKING.ERROR.FULL_NAME_MUST_NOT_EMPTY'.t();
      } else {
        _rxFullNameError.value = null;
      }
    });

    _phoneController.addListener(() async {
      final rawNumber = _phoneController.text;
      try {
        if (rawNumber.isEmpty) {
          _rxPhoneError.value = '';
        } else if (!rawNumber.startsWith('+') && rawNumber.length > 2) {
          final formattedNumber = await FlutterLibphonenumber().parse('+84${rawNumber.substring(1)}');
          _phoneNumber = formattedNumber['national_number'] as String;
          _rxPhoneError.value = '';
        } else {
          final formattedNumber = await FlutterLibphonenumber().parse(rawNumber);
          _phoneNumber = formattedNumber['national_number'] as String;
          _rxPhoneError.value = '';
        }
      } catch (_) {
        _rxPhoneError.value = 'BOOKING.ERROR.INVALID_PHONE_NUMBER'.t();
      }
    });

    _emailController.addListener(() {
      if (_emailController.text.isEmpty || EmailValidator.validate(_emailController.text)) {
        _rxEmailError.value = '';
      } else {
        _rxEmailError.value = 'BOOKING.ERROR.INVALID_EMAIL'.t();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    _bookingController.loadServices();
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
        title: Text('${'HOME.LABEL.BOOKING'.t()} (${'BOOKING.LABEL.STEP_1'.t()}/4)'),
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Text(
                  '${'BOOKING.LABEL.BOOKING'.t()}/',
                ),
                Text(
                  '${'BOOKING.LABEL.SELECT_DOCTOR_OR_DATE'.t()}/',
                  style: TextStyle(color: _themeController.getGrayTextColor()),
                ),
                Text(
                  '${'BOOKING.LABEL.SELECT_DOCTOR'.t()}/',
                  style: TextStyle(color: _themeController.getGrayTextColor()),
                ),
                Text('BOOKING.LABEL.SELECT_DATE'.t(), style: TextStyle(color: _themeController.getGrayTextColor())),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[..._buildGroupContent(context)],
      ),
      bottomNavigationBar: TheApp.buildBottomTab(),
    );
  }

  List<Widget> _buildGroupContent(BuildContext context) {
    final List<Widget> list = [];

    list.add(_buildGroupHeader(
        title: 'BOOKING.LABEL.PROFILE'.t(),
        icon: const Icon(
          FontAwesomeIcons.user,
          size: 16,
        )));
    list.add(SliverList(delegate: SliverChildListDelegate([_buildProfile()])));

    list.add(_buildGroupHeader(
      minHeight: 95.0,
        maxHeight: 95.0,
        title: 'BOOKING.LABEL.SERVICES'.t(),
        child: Padding(
          padding: const EdgeInsets.only(left: defaultPaddingValue, right: defaultPaddingValue),
          child: FilterField(
            onSearch: (String value) {
              _bookingController.loadServices(search: value);
            },
          ),
        ),
        icon: const Icon(FontAwesomeIcons.stethoscope, size: 16)));
    list.add(SliverList(delegate: SliverChildListDelegate([_buildServices(context)])));

    return list;
  }

  SliverPersistentHeader _buildGroupHeader({@required String title, Widget icon, Widget child, double minHeight=25.0, double maxHeight=55.0 }) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: minHeight,
        maxHeight: maxHeight,
        child: Container(
            decoration: BoxDecoration(
                color: _themeController.getSecondaryColor(),
                border: const Border(
                    bottom: BorderSide(
                  color: Colors.blueGrey,
                ))),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (icon != null) icon,
                      if (icon != null)
                        const SizedBox(
                          width: 10,
                        ),
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: _themeController.getButtonFontSize()),
                      ),

                    ],
                  ),
                  if (child != null) child,
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    return Padding(
      padding: defaultPadding,
      child: Obx(
        () => Column(
          children: [..._buildServicesContent(context)],
        ),
      ),
    );
  }

  List<Widget> _buildServicesContent(BuildContext context) {
    return _bookingController.rxServices?.value?.map((s) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return Selection(
                  serviceId: s.id as int,
                  serviceName: s.name as String,
                  price: s.price as num,
                );
              }));
            },
            child: Container(
              margin: const EdgeInsets.only(top: defaultPaddingValue),
              decoration: BoxDecoration(
                color: _getServiceColor(s.id as int),
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                border: Border.all(color: defaultBorderColor),
              ),
              child: ListTile(
                leading: const Icon(Icons.event),
                title: Text(s.name as String),
                subtitle: const Text('desc...'),
                trailing: Text(Number.formatCurrency(s.price)),
              ),
            ),
          );
        })?.toList() ??
        [SCircularProgressIndicator.buildSmallCenter()];
  }

  Color _getServiceColor(int serviceId) {
    return _themeController.getSelectionColor();
  }

  Widget _buildProfile() {
    return Padding(
      padding: defaultPadding,
      child: Column(
        children: [
          // Full name
          Obx(
            () => TextField(
              autocorrect: false,
              decoration: InputDecoration(
                errorText: (_rxFullNameError.value ?? '').isEmpty ? null : _rxFullNameError.value,
                labelText: '${'BOOKING.LABEL.FULL_NAME'.t()}*',
              ),
              controller: _fullNameController,
            ),
          ),
          // Gender
          Dropdown(
            title: '${'BOOKING.LABEL.GENDER'.t()}*',
            data: [
              {'id': null, 'value': 'DATA.LABEL.SELECT'.t()},
              {'id': 'M', 'value': 'DATA.LABEL.MALE'.t()},
              {'id': 'F', 'value': 'DATA.LABEL.FEMALE'.t()},
            ],
            rxStringId: _rxGender,
            isRequire: true,
            errorText: 'BOOKING.LABEL.PLEASE_SELECT_A_GENDER'.t(),
          ),
          // Birthday
          SimpleDatePicker(
            selectedYear: _rxBirthYear,
            selectedMonth: _rxBirthMonth,
            selectedDay: _rxBirthDay,
          ),
          //Phone
          Obx(() => TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  errorText: (_rxPhoneError.value ?? '').isEmpty ? null : _rxPhoneError.value,
                  labelText: 'BOOKING.LABEL.PHONE'.t(),
                ),
              )),

          // Email
          Obx(
            () => TextField(
              autocorrect: false,
              decoration: InputDecoration(
                errorText: (_rxEmailError.value ?? '').isEmpty ? null : _rxEmailError.value,
                labelText: 'BOOKING.LABEL.EMAIL'.t(),
              ),
              controller: _emailController,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RaisedButton(
                onPressed: () {
                  _reset();
                },
                child: Text('COMMON.BUTTON.RESET'.t()),
              ),
              const SizedBox(
                width: 10,
              ),
              Obx(
                () => RaisedButton(
                  onPressed: !_validate()
                      ? null
                      : () {
                          _saveOrUpdate();
                        },
                  child: Text('COMMON.BUTTON.SAVE'.t()),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _reset() {
    // TODO
    print('_reset');
  }

  void _saveOrUpdate() {
    // TODO
    print('_saveOrUpdate');
    print('Fullname: ${_fullNameController.text}');
    print('Gender ${_rxGender.value}');
    print('Birthday ${_getDateStr()}');
    print('Phone: $_phoneNumber');
    print('Email: ${_emailController.text}');
  }

  String _getDateStr() {
    if (_rxBirthYear.value != null) {
      return '${_rxBirthDay?.value ?? 'dd'}/${_rxBirthMonth?.value ?? 'MM'}/${_rxBirthYear.value}';
    } else {
      return null;
    }
  }

  bool _validate() {
    final isValidFullName = _rxFullNameError.value == null;
    final isValidGender = _rxGender.value != null;
    final isValidBirthYear = _rxBirthYear.value != null;
    final isValidPhone = (_rxPhoneError.value ?? '').isEmpty;
    final isValidEmail = (_rxEmailError.value ?? '').isEmpty;

    print('isValidFullName $isValidFullName');
    print('isValidGender $isValidGender');
    print('isValidBirthYear $isValidBirthYear');
    print('isValidPhone $isValidPhone');
    print('isValidEmail $isValidEmail');

    return isValidFullName && isValidGender && isValidBirthYear && isValidPhone && isValidEmail;
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}
