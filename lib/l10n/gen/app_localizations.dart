import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Somno'**
  String get appName;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @statusNight.
  ///
  /// In en, this message translates to:
  /// **'Night tracking on'**
  String get statusNight;

  /// No description provided for @statusDay.
  ///
  /// In en, this message translates to:
  /// **'Day tracking on'**
  String get statusDay;

  /// No description provided for @statusAny.
  ///
  /// In en, this message translates to:
  /// **'Tracking any time'**
  String get statusAny;

  /// No description provided for @statusOff.
  ///
  /// In en, this message translates to:
  /// **'Tracking is off'**
  String get statusOff;

  /// No description provided for @titleNone.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get titleNone;

  /// No description provided for @titleToday.
  ///
  /// In en, this message translates to:
  /// **'Sleep today'**
  String get titleToday;

  /// No description provided for @titleYesterday.
  ///
  /// In en, this message translates to:
  /// **'Sleep yesterday'**
  String get titleYesterday;

  /// No description provided for @titleOnDate.
  ///
  /// In en, this message translates to:
  /// **'Sleep on {date}'**
  String titleOnDate(String date);

  /// No description provided for @noSleepYet.
  ///
  /// In en, this message translates to:
  /// **'No sleep detected yet'**
  String get noSleepYet;

  /// No description provided for @noSleepHint.
  ///
  /// In en, this message translates to:
  /// **'Leave your phone locked for {hours} hours or more and Somno will count it as sleep.'**
  String noSleepHint(int hours);

  /// No description provided for @goalPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of {goal} goal'**
  String goalPercent(int percent, String goal);

  /// No description provided for @goalToGo.
  ///
  /// In en, this message translates to:
  /// **'{duration} to go'**
  String goalToGo(String duration);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @asleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Asleep'**
  String get asleepLabel;

  /// No description provided for @awakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Awake'**
  String get awakeLabel;

  /// No description provided for @last7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7;

  /// No description provided for @avgShort.
  ///
  /// In en, this message translates to:
  /// **'Avg {duration}'**
  String avgShort(String duration);

  /// No description provided for @avgPerNight.
  ///
  /// In en, this message translates to:
  /// **'Average per night'**
  String get avgPerNight;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noData;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @goalLegend.
  ///
  /// In en, this message translates to:
  /// **'{goal} goal'**
  String goalLegend(String goal);

  /// No description provided for @sessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep sessions'**
  String get sessionsTitle;

  /// No description provided for @addMissingSleep.
  ///
  /// In en, this message translates to:
  /// **'+ Add missing sleep'**
  String get addMissingSleep;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sleep sessions in this period'**
  String get noSessions;

  /// No description provided for @sourceAuto.
  ///
  /// In en, this message translates to:
  /// **'Detected automatically'**
  String get sourceAuto;

  /// No description provided for @sourceEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited by you'**
  String get sourceEdited;

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get sourceManual;

  /// No description provided for @editSleep.
  ///
  /// In en, this message translates to:
  /// **'Edit sleep'**
  String get editSleep;

  /// No description provided for @addSleep.
  ///
  /// In en, this message translates to:
  /// **'Add sleep'**
  String get addSleep;

  /// No description provided for @totalSleep.
  ///
  /// In en, this message translates to:
  /// **'Total sleep'**
  String get totalSleep;

  /// No description provided for @fellAsleep.
  ///
  /// In en, this message translates to:
  /// **'Fell asleep'**
  String get fellAsleep;

  /// No description provided for @wokeUp.
  ///
  /// In en, this message translates to:
  /// **'Woke up'**
  String get wokeUp;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete this session'**
  String get deleteSession;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Changed times are marked as edited, so you can tell them apart from automatic ones.'**
  String get editNote;

  /// No description provided for @errEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'Wake time must be after the sleep time.'**
  String get errEndBeforeStart;

  /// No description provided for @errTooLong.
  ///
  /// In en, this message translates to:
  /// **'A session can be at most 24 hours.'**
  String get errTooLong;

  /// No description provided for @errOverlap.
  ///
  /// In en, this message translates to:
  /// **'This overlaps another sleep session.'**
  String get errOverlap;

  /// No description provided for @errFuture.
  ///
  /// In en, this message translates to:
  /// **'Times cannot be in the future.'**
  String get errFuture;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get sectionTracking;

  /// No description provided for @trackSleep.
  ///
  /// In en, this message translates to:
  /// **'Track my sleep'**
  String get trackSleep;

  /// No description provided for @countSleepDuring.
  ///
  /// In en, this message translates to:
  /// **'Count sleep during'**
  String get countSleepDuring;

  /// No description provided for @modeNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get modeNight;

  /// No description provided for @modeDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get modeDay;

  /// No description provided for @modeAny.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get modeAny;

  /// No description provided for @windowNight.
  ///
  /// In en, this message translates to:
  /// **'Night window'**
  String get windowNight;

  /// No description provided for @windowDay.
  ///
  /// In en, this message translates to:
  /// **'Day window'**
  String get windowDay;

  /// No description provided for @anyTimeNote.
  ///
  /// In en, this message translates to:
  /// **'Tracks around the clock. Use a longer minimum gap so idle time is not counted as sleep.'**
  String get anyTimeNote;

  /// No description provided for @minGap.
  ///
  /// In en, this message translates to:
  /// **'Minimum gap'**
  String get minGap;

  /// No description provided for @gapValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String gapValue(int hours);

  /// No description provided for @gapTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: in Any time mode, a gap of 4 h or more works best.'**
  String get gapTip;

  /// No description provided for @pickStart.
  ///
  /// In en, this message translates to:
  /// **'Tracking starts at'**
  String get pickStart;

  /// No description provided for @pickEnd.
  ///
  /// In en, this message translates to:
  /// **'Tracking stops at'**
  String get pickEnd;

  /// No description provided for @sectionGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get sectionGoal;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily sleep goal'**
  String get dailyGoal;

  /// No description provided for @birthYear.
  ///
  /// In en, this message translates to:
  /// **'Birth year'**
  String get birthYear;

  /// No description provided for @recommendedFor.
  ///
  /// In en, this message translates to:
  /// **'Recommended for your age: {range}'**
  String recommendedFor(String range);

  /// No description provided for @guideline.
  ///
  /// In en, this message translates to:
  /// **'This is a general guideline, not medical advice.'**
  String get guideline;

  /// No description provided for @sectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sectionApp;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get langSystem;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get langHindi;

  /// No description provided for @batteryGuide.
  ///
  /// In en, this message translates to:
  /// **'Battery setup guide'**
  String get batteryGuide;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'All data stays on this phone. No account, no ads, no tracking. Internet is only used to look for updates.'**
  String get privacyNote;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Somno'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Somno notices long gaps when your phone stays locked and counts them as sleep. Everything stays on this phone.'**
  String get welcomeBody;

  /// No description provided for @birthYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Your birth year'**
  String get birthYearLabel;

  /// No description provided for @birthYearError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid birth year'**
  String get birthYearError;

  /// No description provided for @recommendedAge.
  ///
  /// In en, this message translates to:
  /// **'Recommended for your age'**
  String get recommendedAge;

  /// No description provided for @yourGoal.
  ///
  /// In en, this message translates to:
  /// **'Your daily sleep goal'**
  String get yourGoal;

  /// No description provided for @changeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change the goal any time in Settings.'**
  String get changeLater;

  /// No description provided for @youngNote.
  ///
  /// In en, this message translates to:
  /// **'Phone-based tracking may not suit young children.'**
  String get youngNote;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @modeStepTitle.
  ///
  /// In en, this message translates to:
  /// **'When do you sleep?'**
  String get modeStepTitle;

  /// No description provided for @modeStepBody.
  ///
  /// In en, this message translates to:
  /// **'Pick when Somno should look for sleep. You can change this any time.'**
  String get modeStepBody;

  /// No description provided for @modeNightDesc.
  ///
  /// In en, this message translates to:
  /// **'Long sleep at night, starting between {start} and {end}'**
  String modeNightDesc(String start, String end);

  /// No description provided for @modeDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Sleep in the day, starting between {start} and {end}'**
  String modeDayDesc(String start, String end);

  /// No description provided for @modeAnyDesc.
  ///
  /// In en, this message translates to:
  /// **'Count any long gap, day or night'**
  String get modeAnyDesc;

  /// No description provided for @batteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Let Somno rest in the background'**
  String get batteryTitle;

  /// No description provided for @batteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop apps to save battery. Without this one-time step, Somno can miss when your screen turns off.'**
  String get batteryBody;

  /// No description provided for @batteryStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to open battery settings'**
  String get batteryStep1;

  /// No description provided for @batteryStep2.
  ///
  /// In en, this message translates to:
  /// **'Find Somno in the list (choose All apps if needed)'**
  String get batteryStep2;

  /// No description provided for @batteryStep3.
  ///
  /// In en, this message translates to:
  /// **'Set it to Unrestricted or Do not optimize'**
  String get batteryStep3;

  /// No description provided for @batteryFoot.
  ///
  /// In en, this message translates to:
  /// **'Somno only listens for screen on and off. It uses very little battery and never sends your sleep data anywhere.'**
  String get batteryFoot;

  /// No description provided for @openBatterySettings.
  ///
  /// In en, this message translates to:
  /// **'Open battery settings'**
  String get openBatterySettings;

  /// No description provided for @batteryAlreadyOk.
  ///
  /// In en, this message translates to:
  /// **'Battery saving is already off for Somno.'**
  String get batteryAlreadyOk;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get startTracking;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @notifHint.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so Android keeps Somno running. The notification only says that tracking is on.'**
  String get notifHint;

  /// No description provided for @bannerTrackingOff.
  ///
  /// In en, this message translates to:
  /// **'Tracking is off.'**
  String get bannerTrackingOff;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @bannerBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery saving may stop tracking.'**
  String get bannerBattery;

  /// No description provided for @fix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get fix;

  /// No description provided for @durationHM.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String durationHM(int h, int m);

  /// No description provided for @durationH.
  ///
  /// In en, this message translates to:
  /// **'{h}h'**
  String durationH(int h);

  /// No description provided for @durationM.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String durationM(int m);

  /// No description provided for @hoursRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} h'**
  String hoursRange(int min, int max);

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(int step, int total);

  /// No description provided for @sectionUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get sectionUpdates;

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @autoCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check automatically'**
  String get autoCheckUpdates;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version.'**
  String get upToDate;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check. Check your internet and try again.'**
  String get updateFailed;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update {version} available'**
  String updateAvailableTitle(String version);

  /// No description provided for @updateBanner.
  ///
  /// In en, this message translates to:
  /// **'New version {version} is available.'**
  String updateBanner(String version);

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @updateNote.
  ///
  /// In en, this message translates to:
  /// **'Your sleep data stays safe when you update. After downloading, open the file to install.'**
  String get updateNote;

  /// No description provided for @updatesNet.
  ///
  /// In en, this message translates to:
  /// **'Internet is used only to look for updates. Nothing else is sent.'**
  String get updatesNet;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get insightsTitle;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @consistencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistencyLabel;

  /// No description provided for @debtLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep debt'**
  String get debtLabel;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String daysCount(int days);

  /// No description provided for @debtShort.
  ///
  /// In en, this message translates to:
  /// **'short'**
  String get debtShort;

  /// No description provided for @debtAhead.
  ///
  /// In en, this message translates to:
  /// **'ahead'**
  String get debtAhead;

  /// No description provided for @debtEven.
  ///
  /// In en, this message translates to:
  /// **'on goal'**
  String get debtEven;

  /// No description provided for @needMoreDays.
  ///
  /// In en, this message translates to:
  /// **'needs 3+ days'**
  String get needMoreDays;

  /// No description provided for @insightsNote.
  ///
  /// In en, this message translates to:
  /// **'A day counts for your streak at 90% of your goal. Consistency compares bed and wake times over 7 days. Naps (20 min to 1.5 h) are kept apart.'**
  String get insightsNote;

  /// No description provided for @napsToday.
  ///
  /// In en, this message translates to:
  /// **'Naps today'**
  String get napsToday;

  /// No description provided for @napTag.
  ///
  /// In en, this message translates to:
  /// **'Nap'**
  String get napTag;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get accentColor;

  /// No description provided for @accentTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get accentTeal;

  /// No description provided for @accentPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get accentPurple;

  /// No description provided for @accentAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get accentAmber;

  /// No description provided for @accentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentBlue;

  /// No description provided for @wellbeing.
  ///
  /// In en, this message translates to:
  /// **'Digital Wellbeing'**
  String get wellbeing;

  /// No description provided for @wellbeingNote.
  ///
  /// In en, this message translates to:
  /// **'See your screen time in Android\'s own page. It stays on Android; Somno does not read it.'**
  String get wellbeingNote;

  /// No description provided for @wellbeingMissing.
  ///
  /// In en, this message translates to:
  /// **'Digital Wellbeing is not on this phone. Settings opened instead.'**
  String get wellbeingMissing;

  /// No description provided for @sectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get sectionReminder;

  /// No description provided for @bedtimeReminder.
  ///
  /// In en, this message translates to:
  /// **'Bedtime reminder'**
  String get bedtimeReminder;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get reminderTime;

  /// No description provided for @reminderNote.
  ///
  /// In en, this message translates to:
  /// **'One gentle notification every day at this time. To save battery, Android may deliver it a few minutes late.'**
  String get reminderNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
