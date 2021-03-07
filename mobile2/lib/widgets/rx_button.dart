import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/widgets/circular_progress.dart';

class RxButton extends StatelessWidget {
  final Function() onPressed;
  final RxButtonController rxController;
  final Widget icon;
  final String label;
  final bool isIconTop;
  final bool isPrimary;
  final EdgeInsets padding;
  const RxButton(
      {this.onPressed,
      this.icon,
      this.rxController,
      this.label,
      this.isPrimary = false,
      this.padding = const EdgeInsets.only(
          left: DEFAULT_PADDING_VALUE, right: DEFAULT_PADDING_VALUE),
      this.isIconTop = true})
      : assert(label != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isPrimary
          ? null
          : () {
              if (onPressed != null) {
                onPressed();
              }
            },
      child: rxController == null
          ? _buildBody(null)
          : GetBuilder(
              id: 'loadingButton',
              init: rxController,
              global: false,
              builder: (RxButtonController ctl) {
                return _buildBody(ctl);
              }),
    );
  }

  Widget _buildBody(RxButtonController ctl) {
    if (isIconTop) {
      return Column(
        children: [..._buildWidgetList(ctl)],
      );
    } else {
      return Row(
        children: [..._buildWidgetList(ctl)],
      );
    }
  }

  List<Widget> _buildWidgetList(RxButtonController ctl) {
    return [
      if (!isPrimary && (ctl != null && ctl.isLoading))
        CircularProgress.smallest(),
      if (icon != null && !isPrimary && (ctl == null || !ctl.isLoading)) icon,
      if (label != null && !isPrimary) Text(label),
      if (isPrimary)
        ElevatedButton(
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ctl != null && ctl.isLoading) CircularProgress.smallest(),
                if (icon != null && (ctl == null || !ctl.isLoading)) icon,
                if (label != null)
                  Padding(
                    padding: const EdgeInsets.only(left: DEFAULT_PADDING_VALUE),
                    child: Text(label),
                  ),
              ],
            ),
          ),
          onPressed: (ctl != null && ctl.isLoading) ? null : onPressed,
        ),
    ];
  }
}

class RxButtonController extends GetxController {
  bool _loading = false;
  bool get isLoading => _loading;


  void setLoading(bool newValue) {
    _loading = newValue;
    update(['loadingButton']);
  }
}
