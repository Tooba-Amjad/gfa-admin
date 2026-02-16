import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';

String formatTimeDateCOMLPETEString({
  required BuildContext context,
  required int timestamp,
}) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  String when = Optionalconstants.isShowNativeTimDate == true
      ? getTranslatedForCurrentUser(context, DateFormat.MMMM().format(date)) +
          ' ' +
          DateFormat.d().format(date) +
          ', ' +
          DateFormat.y().format(date)
      : DateFormat.yMMMd().format(date);
  return '$when';
}

//--------------------
String minutesToHour(int minutes) {
  var d = Duration(minutes: minutes);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2)}:${parts[1].padLeft(2, '0')}';
}
