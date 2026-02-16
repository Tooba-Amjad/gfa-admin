import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';

getWhen(BuildContext context, DateTime date) {
  DateTime now = DateTime.now();
  String when;
  if (date.day == now.day)
    when = getTranslatedForCurrentUser(context, 'xxtodayxx');
  else if (date.day == now.subtract(Duration(days: 1)).day)
    when = getTranslatedForCurrentUser(context, 'xxyesterdayxx');
  else
    when = Optionalconstants.isShowNativeTimDate == true
        ? getTranslatedForCurrentUser(context, DateFormat.MMMM().format(date)) +
            ' ' +
            DateFormat.d().format(date)
        : DateFormat.MMMd().format(date);
  return when;
}
