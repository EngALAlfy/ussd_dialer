import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:ussd_service/ussd_service.dart';

class UssdProvider extends ChangeNotifier {
  Map<String, String> results = Map();

  int sim;
  var number;
  int numberIndex = 0;
  var code;

  Duration duration = Duration(seconds: 50);
  Duration delay = Duration(seconds: 10);

  String _status = "N/A";
  String amount = "0";
  String codeFormat;

  bool stopped = false;

  List numbers;

  CancelableOperation cancelable;

  set status(String status) {
    _status = status;
    notifyListeners();
  }

  String get status => _status;

  dialUssd() async {
    try {
      String result = await UssdService.makeRequest(
        sim,
        code,
        duration,
      );
      print("number : $number");
      results[number.toString()] = result;
    } catch (e) {
      results[number.toString()] = e.toString();
    }
    notifyListeners();
  }

  Future<void> startDialLoop() async {
    stopped = false;
    results = Map();
    status = "Progress...";

    cancelable = CancelableOperation.fromFuture(
      dialLoop(),
      onCancel: () => status = "done",
    );
    cancelable.value.whenComplete(() { status = "done";numberIndex = 0;});
  }

  resetIndex(){
    numberIndex = 0;
    notifyListeners();
  }

  dialLoop() async {
    for (int i = numberIndex; i < numbers.length; i++) {
      print("i : $i");
      if (stopped) {
        numberIndex = i;
        break;
      }
      status = "Progress...${i+1}";
      if (i != 0) {
        await Future.delayed(delay);
      }
      // code = "*777*2*2*${numbers.elementAt(i)}*$amount*900119#";
      /// m for mobile number - a for amount
      code = codeFormat.replaceAll("m", numbers.elementAt(i)).replaceAll("a", amount);
      number = numbers.elementAt(i);
      await dialUssd();
    }
  }

  void stopDial() {
    stopped = true;
    if (cancelable != null) {
      cancelable.cancel();
    }
    notifyListeners();
  }
}
