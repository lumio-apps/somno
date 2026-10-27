// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Somno';

  @override
  String get navToday => 'Today';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get statusNight => 'Night tracking on';

  @override
  String get statusDay => 'Day tracking on';

  @override
  String get statusAny => 'Tracking any time';

  @override
  String get statusOff => 'Tracking is off';

  @override
  String get titleNone => 'Sleep';

  @override
  String get titleToday => 'Sleep today';

  @override
  String get titleYesterday => 'Sleep yesterday';

  @override
  String titleOnDate(String date) {
    return 'Sleep on $date';
  }

  @override
  String get noSleepYet => 'No sleep detected yet';

  @override
  String noSleepHint(int hours) {
    return 'Leave your phone locked for $hours hours or more and Somno will count it as sleep.';
  }

  @override
  String goalPercent(int percent, String goal) {
    return '$percent% of $goal goal';
  }

  @override
  String goalToGo(String duration) {
    return '$duration to go';
  }

  @override
  String get goalReached => 'Goal reached';

  @override
  String get asleepLabel => 'Asleep';

  @override
  String get awakeLabel => 'Awake';

  @override
  String get last7 => 'Last 7 days';

  @override
  String avgShort(String duration) {
    return 'Avg $duration';
  }

  @override
  String get avgPerNight => 'Average per night';

  @override
  String get noData => 'No data yet';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String goalLegend(String goal) {
    return '$goal goal';
  }

  @override
  String get sessionsTitle => 'Sleep sessions';

  @override
  String get addMissingSleep => '+ Add missing sleep';

  @override
  String get noSessions => 'No sleep sessions in this period';

  @override
  String get sourceAuto => 'Detected automatically';

  @override
  String get sourceEdited => 'Edited by you';

  @override
  String get sourceManual => 'Added by you';

  @override
  String get editSleep => 'Edit sleep';

  @override
  String get addSleep => 'Add sleep';

  @override
  String get totalSleep => 'Total sleep';

  @override
  String get fellAsleep => 'Fell asleep';

  @override
  String get wokeUp => 'Woke up';

  @override
  String get save => 'Save';

  @override
  String get deleteSession => 'Delete this session';

  @override
  String get deleteConfirmTitle => 'Delete this session?';

  @override
  String get deleteConfirmBody => 'This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get editNote =>
      'Changed times are marked as edited, so you can tell them apart from automatic ones.';

  @override
  String get errEndBeforeStart => 'Wake time must be after the sleep time.';

  @override
  String get errTooLong => 'A session can be at most 24 hours.';

  @override
  String get errOverlap => 'This overlaps another sleep session.';

  @override
  String get errFuture => 'Times cannot be in the future.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionTracking => 'Tracking';

  @override
  String get trackSleep => 'Track my sleep';

  @override
  String get countSleepDuring => 'Count sleep during';

  @override
  String get modeNight => 'Night';

  @override
  String get modeDay => 'Day';

  @override
  String get modeAny => 'Any time';

  @override
  String get windowNight => 'Night window';

  @override
  String get windowDay => 'Day window';

  @override
  String get anyTimeNote =>
      'Tracks around the clock. Use a longer minimum gap so idle time is not counted as sleep.';

  @override
  String get minGap => 'Minimum gap';

  @override
  String gapValue(int hours) {
    return '$hours h';
  }

  @override
  String get gapTip =>
      'Tip: in Any time mode, a gap of 4 h or more works best.';

  @override
  String get pickStart => 'Tracking starts at';

  @override
  String get pickEnd => 'Tracking stops at';

  @override
  String get sectionGoal => 'Goal';

  @override
  String get dailyGoal => 'Daily sleep goal';

  @override
  String get birthYear => 'Birth year';

  @override
  String recommendedFor(String range) {
    return 'Recommended for your age: $range';
  }

  @override
  String get guideline => 'This is a general guideline, not medical advice.';

  @override
  String get sectionApp => 'App';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get langSystem => 'System';

  @override
  String get langEnglish => 'English';

  @override
  String get langHindi => 'हिन्दी';

  @override
  String get batteryGuide => 'Battery setup guide';

  @override
  String get open => 'Open';

  @override
  String get privacyNote =>
      'All data stays on this phone. No account, no ads, no tracking. Internet is only used to check for and download updates.';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get welcomeTitle => 'Welcome to Somno';

  @override
  String get welcomeBody =>
      'Somno notices long gaps when your phone stays locked and counts them as sleep. Everything stays on this phone.';

  @override
  String get birthYearLabel => 'Your birth year';

  @override
  String get birthYearError => 'Enter a valid birth year';

  @override
  String get recommendedAge => 'Recommended for your age';

  @override
  String get yourGoal => 'Your daily sleep goal';

  @override
  String get changeLater => 'You can change the goal any time in Settings.';

  @override
  String get youngNote => 'Phone-based tracking may not suit young children.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get modeStepTitle => 'When do you sleep?';

  @override
  String get modeStepBody =>
      'Pick when Somno should look for sleep. You can change this any time.';

  @override
  String modeNightDesc(String start, String end) {
    return 'Long sleep at night, starting between $start and $end';
  }

  @override
  String modeDayDesc(String start, String end) {
    return 'Sleep in the day, starting between $start and $end';
  }

  @override
  String get modeAnyDesc => 'Count any long gap, day or night';

  @override
  String get batteryTitle => 'Let Somno rest in the background';

  @override
  String get batteryBody =>
      'Some phones stop apps to save battery. Without this one-time step, Somno can miss when your screen turns off.';

  @override
  String get batteryStep1 => 'Tap the button below to open battery settings';

  @override
  String get batteryStep2 =>
      'Find Somno in the list (choose All apps if needed)';

  @override
  String get batteryStep3 => 'Set it to Unrestricted or Do not optimize';

  @override
  String get batteryFoot =>
      'Somno only listens for screen on and off. It uses very little battery and never sends your sleep data anywhere.';

  @override
  String get openBatterySettings => 'Open battery settings';

  @override
  String get batteryAlreadyOk => 'Battery saving is already off for Somno.';

  @override
  String get startTracking => 'Start tracking';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get done => 'Done';

  @override
  String get notifHint =>
      'Allow notifications so Android keeps Somno running. The notification only says that tracking is on.';

  @override
  String get bannerTrackingOff => 'Tracking is off.';

  @override
  String get turnOn => 'Turn on';

  @override
  String get bannerBattery => 'Battery saving may stop tracking.';

  @override
  String get fix => 'Fix';

  @override
  String durationHM(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String durationH(int h) {
    return '${h}h';
  }

  @override
  String durationM(int m) {
    return '${m}m';
  }

  @override
  String hoursRange(int min, int max) {
    return '$min–$max h';
  }

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get sectionUpdates => 'Updates';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get autoCheckUpdates => 'Check automatically';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checking => 'Checking…';

  @override
  String get upToDate => 'You have the latest version.';

  @override
  String get updateFailed =>
      'Couldn\'t check. Check your internet and try again.';

  @override
  String updateAvailableTitle(String version) {
    return 'Update $version available';
  }

  @override
  String updateBanner(String version) {
    return 'New version $version is available.';
  }

  @override
  String get download => 'Download';

  @override
  String get later => 'Later';

  @override
  String get view => 'View';

  @override
  String get updateNote => 'Your sleep data stays safe when you update.';

  @override
  String get updatesNet =>
      'Internet is used only to look for and download updates. Nothing else is sent.';

  @override
  String get insightsTitle => 'This week';

  @override
  String get streakLabel => 'Streak';

  @override
  String get consistencyLabel => 'Consistency';

  @override
  String get debtLabel => 'Sleep debt';

  @override
  String daysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get debtShort => 'short';

  @override
  String get debtAhead => 'ahead';

  @override
  String get debtEven => 'on goal';

  @override
  String get needMoreDays => 'needs 3+ days';

  @override
  String get insightsNote =>
      'A day counts for your streak at 90% of your goal. Consistency compares bed and wake times over 7 days. Naps (20 min to 1.5 h) are kept apart.';

  @override
  String get napsToday => 'Naps today';

  @override
  String get napTag => 'Nap';

  @override
  String get accentColor => 'Accent colour';

  @override
  String get accentTeal => 'Teal';

  @override
  String get accentPurple => 'Purple';

  @override
  String get accentAmber => 'Amber';

  @override
  String get accentBlue => 'Blue';

  @override
  String get wellbeing => 'Digital Wellbeing';

  @override
  String get wellbeingNote =>
      'See your screen time in Android\'s own page. It stays on Android; Somno does not read it.';

  @override
  String get wellbeingMissing =>
      'Digital Wellbeing is not on this phone. Settings opened instead.';

  @override
  String get sectionReminder => 'Reminder';

  @override
  String get bedtimeReminder => 'Bedtime reminder';

  @override
  String get reminderTime => 'Remind me at';

  @override
  String get reminderNote =>
      'One gentle notification every day at this time. To save battery, Android may deliver it a few minutes late.';

  @override
  String get downloadInstall => 'Download and install';

  @override
  String get install => 'Install';

  @override
  String get tryAgain => 'Try again';

  @override
  String downloadingPercent(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get installPermission =>
      'Android needs your OK once. In the screen that opened, allow Somno to install apps, then come back and tap Install.';

  @override
  String get updateDownloadFailed =>
      'Download failed. Check your internet and try again.';

  @override
  String get trackingStatus => 'Tracking status';

  @override
  String get statusUsage => 'Usage access';

  @override
  String get accessOn => 'On';

  @override
  String get accessOff => 'Off';

  @override
  String get statusService => 'Background tracker';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get statusBattery => 'Battery restriction';

  @override
  String get statusBatteryOk => 'Unrestricted';

  @override
  String get statusBatteryBad => 'Restricted';

  @override
  String get statusLastOff => 'Last screen-off seen';

  @override
  String get statusLastUnlock => 'Last unlock seen';

  @override
  String get statusNever => 'never';

  @override
  String get statusPhone => 'Phone';

  @override
  String get usageExplain =>
      'Recommended. Some phones, such as Xiaomi, Oppo and Vivo, stop background apps at night. With Usage access, Somno reads when your screen turned off and when you unlocked from Android itself, so your sleep is still found. Only these screen times are read, never which apps you use. Nothing leaves your phone.';

  @override
  String get usageIsOn =>
      'Usage access is on. Sleep is read from Android\'s own screen history.';

  @override
  String get allowUsage => 'Allow usage access';

  @override
  String get usageBanner =>
      'Allow Usage access so Somno can find your sleep even if Android stops it at night.';

  @override
  String get autostartNote =>
      'Xiaomi, Oppo, Vivo, Huawei and Honor: also allow Autostart and background activity for Somno.';

  @override
  String get openAutostart => 'Open autostart settings';
}
