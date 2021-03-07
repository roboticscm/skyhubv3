class LoadingService {
  Future loading () async {
    await Future.delayed(Duration(milliseconds: 500));
    // throw Exception("Loading Exception");
  }
}