import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';

String timeAgo(BuildContext context, DateTime fatchedDate, bool isShort) {
  DateTime currentDate = DateTime.now();

  var different = currentDate.difference(fatchedDate);

  if (different.inDays > 365)
    return "${(different.inDays / 365).floor()} ${(different.inDays / 365).floor() == 1 ? getTranslatedForCurrentUser(context, 'xxyearxx') : getTranslatedForCurrentUser(context, 'xxyearsxx')} ${getTranslatedForCurrentUser(context, 'xxagoxx')}";
  if (different.inDays > 30)
    return "${(different.inDays / 30).floor()} ${(different.inDays / 30).floor() == 1 ? getTranslatedForCurrentUser(context, 'xxmonthxx') : getTranslatedForCurrentUser(context, 'xxmonthsxx')} ${getTranslatedForCurrentUser(context, 'xxagoxx')}";
  if (different.inDays > 7)
    return "${(different.inDays / 7).floor()} ${(different.inDays / 7).floor() == 1 ? getTranslatedForCurrentUser(context, 'xxweekxx') : getTranslatedForCurrentUser(context, 'xxweeksxx')} ${getTranslatedForCurrentUser(context, 'xxagoxx')}";
  if (different.inDays > 0)
    return "${different.inDays} ${different.inDays == 1 ? isShort ? getTranslatedForCurrentUser(context, 'xxdayshortxx') : getTranslatedForCurrentUser(context, 'xxdayxx') : isShort ? getTranslatedForCurrentUser(context, 'xxdayxx') : getTranslatedForCurrentUser(context, 'xxdaysxx')} ${getTranslatedForCurrentUser(context, 'xxagoxx')}";
  if (different.inHours > 0)
    return "${different.inHours} ${different.inHours == 1 ? isShort ? getTranslatedForCurrentUser(context, 'xxhrshortxx') : getTranslatedForCurrentUser(context, 'xxhourxx') : isShort ? getTranslatedForCurrentUser(context, 'xxhrsshortxx') : getTranslatedForCurrentUser(context, 'xxhoursxx')} ${getTranslatedForCurrentUser(context, 'xxagoxx')}";
  if (different.inMinutes > 0)
    return "${different.inMinutes} ${different.inMinutes == 1 ? isShort ? getTranslatedForCurrentUser(context, 'xxminuteshortxx') : getTranslatedForCurrentUser(context, 'xxminutexx') : isShort ? getTranslatedForCurrentUser(context, 'xxminuteshortxx') : getTranslatedForCurrentUser(context, 'xxminutesxx')} ${getTranslatedForCurrentUser(context, 'xxagoxx')}";
  if (different.inMinutes == 0)
    return getTranslatedForCurrentUser(context, 'xxjustnowxx');

  return fatchedDate.toString();
}
