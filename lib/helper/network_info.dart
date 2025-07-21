import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    // ИЗМЕНЕНО: Работаем со списком результатов
    List<ConnectivityResult> result = await connectivity.checkConnectivity();
    // Проверяем, есть ли в списке хотя бы одно активное подключение
    if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }

  static void checkConnectivity(BuildContext context) {
    // ИЗМЕНЕНО: Слушаем изменения в списке подключений
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if(Provider.of<SplashController>(Get.context!, listen: false).firstTimeConnectionCheck) {
        Provider.of<SplashController>(Get.context!, listen: false).setFirstTimeConnectionCheck(false);
      }else {
        // ИЗМЕНЕНО: Проверяем, есть ли в списке активные подключения
        bool isNotConnected = !result.contains(ConnectivityResult.mobile) && !result.contains(ConnectivityResult.wifi);

        isNotConnected ? const SizedBox() : ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? getTranslated('no_connection', Get.context!)! : getTranslated('connected', Get.context!)!,
            textAlign: TextAlign.center,
          ),
        ));
      }
    });
  }
}