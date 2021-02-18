import 'dart:convert';

import 'package:get/get.dart';
import 'package:grpc/grpc.dart';
import 'package:skyone_mobile/grpc/helper.dart';
import 'package:skyone_mobile/grpc/service_url.dart';
import 'package:skyone_mobile/pt/google/protobuf/empty.pb.dart';
import 'package:skyone_mobile/pt/proto/notify/notify_service.pb.dart';
import 'package:skyone_mobile/pt/proto/notify/notify_service.pbgrpc.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/util/global_param.dart';
import 'package:tuple/tuple.dart';

class NotifyListenerController extends GetxController {
  Tuple2<Stream, ClientChannel>register() {
    final channel = createChannel(ServiceURL.core);
    final client = NotifyServiceClient(channel);
    final request = Empty();
    try {
      final metadata = {'authorization': 'Bearer ${GlobalParam.accessToken}'};
      final s = client.databaseListenerHandler(request, options: CallOptions(metadata: metadata));
      final maps = s.map((value) {
        final js = jsonDecode(value.json) as Map<String, dynamic>;
        return NotifyListener.fromJson(js);
      });
      return Tuple2(maps, channel);
    } catch (e) {
      log(e);
      channel.shutdown();
    }
    return const Tuple2(null, null);
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