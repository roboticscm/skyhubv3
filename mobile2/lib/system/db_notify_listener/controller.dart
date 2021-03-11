import 'dart:convert';

import 'package:get/get.dart';
import 'package:grpc/grpc.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/pt/google/protobuf/empty.pb.dart';
import 'package:skyone/pt/proto/notify/notify_service.pbgrpc.dart';
import 'package:skyone/system/grpc/helper.dart';
import 'package:skyone/system/grpc/service_url.dart';

class DbNotifyListenerController extends GetxController {
  Stream register() {
    final channel = createChannel(ServiceURL.core);
    final client = NotifyServiceClient(channel);
    final request = Empty();
    try {
      final metadata = {'authorization': 'Bearer ${LoginInfo.accessToken}'};
      final s = client.databaseListenerHandler(request, options: CallOptions(metadata: metadata));
      final maps = s.map((value) {
        final js = jsonDecode(value.json) as Map<String, dynamic>;
        return NotifyListener.fromJson(js);
      });
      return maps;
    } catch (e) {
      log(e);
      channel.shutdown();
    }
    return null;
  }
}

class NotifyListener<T> {
  final String action;
  final String table;
  final T data;

  NotifyListener({this.action, this.table, this.data});

  factory NotifyListener.fromJson(Map<String, dynamic> json) {
    return NotifyListener(
      action: json["action"] as String,
      table: json["table"] as String,
      data: json["data"] as T,
    );
  }
}