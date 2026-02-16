import 'package:thinkcreative_technologies/Utils/utils.dart';

DateTime? currentBackPressTime;
//----- Double tap to go back -----
Future<bool> doubleTapTrigger() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime!) > Duration(seconds: 3)) {
    currentBackPressTime = now;
    Utils.toast(
      'Double Tap to go back',
    );
    return Future.value(false);
  }
  return Future.value(true);
}
