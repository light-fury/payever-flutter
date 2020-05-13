import 'package:flutter/foundation.dart';

class PosCartStateModel extends ChangeNotifier {

  bool isButtonAvailable = true;

  bool get getIsButtonAvailable => isButtonAvailable;

  bool cartHasItems = false;

  bool get getCartHasItems => cartHasItems;

//  int currentSelectedVariant = 0;
//
//  int get getCurrentSelectedVariant => currentSelectedVariant;

  void updateCart(bool value) {
    cartHasItems = value;
    notifyListeners();
  }

  void updateBuyButton(bool value) {
    isButtonAvailable = value;
    notifyListeners();
  }


//  void updateCurrentVariant(int value) {
//    currentSelectedVariant = value;
//    notifyListeners();
//    print("currentSelectedVariant: $currentSelectedVariant");
//  }

}
