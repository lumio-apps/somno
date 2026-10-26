import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/gen/app_localizations.dart';

String localeTag(BuildContext context) =>
    Localizations.localeOf(context).toString();

String durationText(AppLocalizations l, int minutes) {
  final safe = minutes < 0 ? 0 : minutes;
  final h = safe ~/ 60;
  final m = safe % 60;
  if (h == 0) {
    return l.durationM(m);
  }
  if (m == 0) {
    return l.durationH(h);
  }
  return l.durationHM(h, m);
}

String timeText(BuildContext context, DateTime t) {
  return TimeOfDay.fromDateTime(t).format(context);
}

String minuteOfDayText(BuildContext context, int minuteOfDay) {
  final tod = TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
  return tod.format(context);
}

String dateShort(BuildContext context, DateTime d) {
  return DateFormat.MMMd(localeTag(context)).format(d);
}

String dateFull(BuildContext context, DateTime d) {
  return DateFormat.MMMEd(localeTag(context)).format(d);
}

String weekdayShort(BuildContext context, DateTime d) {
  return DateFormat.E(localeTag(context)).format(d);
}
