import 'package:get/get.dart';
import 'package:skyone_mobile/modules/booking/model.dart';

class BookingController extends GetxController {
  RxList rxServices = RxList();
  RxList rxDoctors = RxList();

  void loadServices({String search}) async {
    rxServices.value = null;
    Future.delayed(const Duration(seconds: 1)).then((res) => {
          rxServices.value = [
            Services(imageData: 'abc', name: 'Service 1', price: 1000),
            Services(imageData: 'abc2', name: 'Service 2', price: 2000),
            Services(imageData: 'abc3', name: 'Service 3', price: 3000),
            Services(imageData: 'abc', name: 'Service 4', price: 1000),
            Services(imageData: 'abc2', name: 'Service 5', price: 2000),
            Services(imageData: 'abc3', name: 'Service 6', price: 3000),
          ]
        });
  }

  void loadDoctors({int serviceId, String search}) async {
    rxDoctors.value = null;
    Future.delayed(const Duration(seconds: 1)).then((res) => {
      rxDoctors.value = [
        Doctor(id: 1, imageData: 'abc', title: 'ThS', fullName: 'Abc Abc', department: 'Abc', schedule: 'Abc, Abc, Abc'),
        Doctor(id: 2, imageData: 'abc', title: 'TS', fullName: 'Abc Abc', department: 'Abc', schedule: 'Abc, Abc, Abc'),
        Doctor(id: 3, imageData: 'abc', title: 'ThS', fullName: 'Abc Abc', department: 'Abc', schedule: 'Abc, Abc, Abc'),
        Doctor(id: 4, imageData: 'abc', title: 'TS', fullName: 'Abc Abc', department: 'Abc', schedule: 'Abc, Abc, Abc'),
        Doctor(id: 5, imageData: 'abc', title: 'ThS', fullName: 'Abc Abc', department: 'Abc', schedule: 'Abc, Abc, Abc'),
      ]
    });
  }

  Future<void> book(Booking booking) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
