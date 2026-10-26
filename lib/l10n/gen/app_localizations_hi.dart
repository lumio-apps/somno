// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Somno';

  @override
  String get navToday => 'आज';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get statusNight => 'रात की ट्रैकिंग चालू';

  @override
  String get statusDay => 'दिन की ट्रैकिंग चालू';

  @override
  String get statusAny => 'किसी भी समय ट्रैकिंग चालू';

  @override
  String get statusOff => 'ट्रैकिंग बंद है';

  @override
  String get titleNone => 'नींद';

  @override
  String get titleToday => 'आज की नींद';

  @override
  String get titleYesterday => 'कल की नींद';

  @override
  String titleOnDate(String date) {
    return '$date की नींद';
  }

  @override
  String get noSleepYet => 'अभी तक कोई नींद नहीं मिली';

  @override
  String noSleepHint(int hours) {
    return 'फ़ोन को $hours घंटे या उससे ज़्यादा लॉक रखें, तो Somno उसे नींद गिन लेगा।';
  }

  @override
  String goalPercent(int percent, String goal) {
    return '$goal के लक्ष्य का $percent%';
  }

  @override
  String goalToGo(String duration) {
    return '$duration बाकी';
  }

  @override
  String get goalReached => 'लक्ष्य पूरा';

  @override
  String get asleepLabel => 'सोए';

  @override
  String get awakeLabel => 'जागे';

  @override
  String get last7 => 'पिछले 7 दिन';

  @override
  String avgShort(String duration) {
    return 'औसत $duration';
  }

  @override
  String get avgPerNight => 'रोज़ का औसत';

  @override
  String get noData => 'अभी कोई डेटा नहीं';

  @override
  String get periodWeek => 'हफ़्ता';

  @override
  String get periodMonth => 'महीना';

  @override
  String goalLegend(String goal) {
    return '$goal का लक्ष्य';
  }

  @override
  String get sessionsTitle => 'नींद के सेशन';

  @override
  String get addMissingSleep => '+ छूटी हुई नींद जोड़ें';

  @override
  String get noSessions => 'इस अवधि में कोई सेशन नहीं';

  @override
  String get sourceAuto => 'अपने आप पकड़ा गया';

  @override
  String get sourceEdited => 'आपने बदला';

  @override
  String get sourceManual => 'आपने जोड़ा';

  @override
  String get editSleep => 'नींद बदलें';

  @override
  String get addSleep => 'नींद जोड़ें';

  @override
  String get totalSleep => 'कुल नींद';

  @override
  String get fellAsleep => 'सोए';

  @override
  String get wokeUp => 'जागे';

  @override
  String get save => 'सेव करें';

  @override
  String get deleteSession => 'यह सेशन हटाएं';

  @override
  String get deleteConfirmTitle => 'यह सेशन हटाएं?';

  @override
  String get deleteConfirmBody => 'इसे वापस नहीं लाया जा सकता।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get editNote =>
      'बदले हुए समय अलग से चिह्नित होते हैं, ताकि वे अपने आप पकड़े गए समय से अलग दिखें।';

  @override
  String get errEndBeforeStart => 'जागने का समय सोने के समय के बाद होना चाहिए।';

  @override
  String get errTooLong => 'एक सेशन अधिकतम 24 घंटे का हो सकता है।';

  @override
  String get errOverlap => 'यह किसी दूसरे नींद सेशन से टकरा रहा है।';

  @override
  String get errFuture => 'समय भविष्य में नहीं हो सकता।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get sectionTracking => 'ट्रैकिंग';

  @override
  String get trackSleep => 'मेरी नींद ट्रैक करें';

  @override
  String get countSleepDuring => 'नींद गिनें';

  @override
  String get modeNight => 'रात';

  @override
  String get modeDay => 'दिन';

  @override
  String get modeAny => 'कभी भी';

  @override
  String get windowNight => 'रात की समय-सीमा';

  @override
  String get windowDay => 'दिन की समय-सीमा';

  @override
  String get anyTimeNote =>
      'चौबीसों घंटे ट्रैक करता है। बेकार पड़े फ़ोन को नींद गिनने से बचाने के लिए न्यूनतम अंतराल ज़्यादा रखें।';

  @override
  String get minGap => 'न्यूनतम अंतराल';

  @override
  String gapValue(int hours) {
    return '$hours घंटे';
  }

  @override
  String get gapTip =>
      'सुझाव: «कभी भी» मोड में 4 घंटे या ज़्यादा का अंतराल सबसे ठीक रहता है।';

  @override
  String get pickStart => 'ट्रैकिंग कब शुरू हो';

  @override
  String get pickEnd => 'ट्रैकिंग कब बंद हो';

  @override
  String get sectionGoal => 'लक्ष्य';

  @override
  String get dailyGoal => 'रोज़ की नींद का लक्ष्य';

  @override
  String get birthYear => 'जन्म वर्ष';

  @override
  String recommendedFor(String range) {
    return 'आपकी उम्र के लिए सुझाव: $range';
  }

  @override
  String get guideline => 'यह एक सामान्य मार्गदर्शन है, डॉक्टर की सलाह नहीं।';

  @override
  String get sectionApp => 'ऐप';

  @override
  String get theme => 'थीम';

  @override
  String get themeDark => 'डार्क';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get language => 'भाषा';

  @override
  String get langSystem => 'सिस्टम';

  @override
  String get langEnglish => 'English';

  @override
  String get langHindi => 'हिन्दी';

  @override
  String get batteryGuide => 'बैटरी सेटअप गाइड';

  @override
  String get open => 'खोलें';

  @override
  String get privacyNote =>
      'सारा डेटा इसी फ़ोन में रहता है। न अकाउंट, न विज्ञापन, न इंटरनेट।';

  @override
  String get decrease => 'घटाएं';

  @override
  String get increase => 'बढ़ाएं';

  @override
  String get welcomeTitle => 'Somno में स्वागत है';

  @override
  String get welcomeBody =>
      'फ़ोन जब लंबे समय तक लॉक रहता है, तो Somno उसे नींद गिन लेता है। सब कुछ इसी फ़ोन में रहता है।';

  @override
  String get birthYearLabel => 'आपका जन्म वर्ष';

  @override
  String get birthYearError => 'सही जन्म वर्ष डालें';

  @override
  String get recommendedAge => 'आपकी उम्र के लिए सुझाव';

  @override
  String get yourGoal => 'आपका रोज़ का नींद लक्ष्य';

  @override
  String get changeLater => 'लक्ष्य आप कभी भी सेटिंग्स में बदल सकते हैं।';

  @override
  String get youngNote => 'छोटे बच्चों के लिए फ़ोन से ट्रैकिंग ठीक नहीं बैठती।';

  @override
  String get continueLabel => 'आगे बढ़ें';

  @override
  String get modeStepTitle => 'आप कब सोते हैं?';

  @override
  String get modeStepBody =>
      'चुनें कि Somno को नींद कब ढूंढनी है। इसे कभी भी बदल सकते हैं।';

  @override
  String modeNightDesc(String start, String end) {
    return 'रात की लंबी नींद, शुरुआत $start से $end के बीच';
  }

  @override
  String modeDayDesc(String start, String end) {
    return 'दिन की नींद, शुरुआत $start से $end के बीच';
  }

  @override
  String get modeAnyDesc => 'दिन या रात, कोई भी लंबा अंतराल गिनें';

  @override
  String get batteryTitle => 'Somno को बैकग्राउंड में चलने दें';

  @override
  String get batteryBody =>
      'कुछ फ़ोन बैटरी बचाने के लिए ऐप बंद कर देते हैं। यह एक बार का कदम न उठाया, तो Somno स्क्रीन बंद होने का पल चूक सकता है।';

  @override
  String get batteryStep1 => 'नीचे के बटन से बैटरी सेटिंग्स खोलें';

  @override
  String get batteryStep2 =>
      'सूची में Somno ढूंढें (ज़रूरत हो तो सभी ऐप चुनें)';

  @override
  String get batteryStep3 => 'इसे अनरिस्ट्रिक्टेड या ऑप्टिमाइज़ न करें पर रखें';

  @override
  String get batteryFoot =>
      'Somno सिर्फ़ स्क्रीन ऑन और ऑफ़ सुनता है। बैटरी बहुत कम लेता है और इंटरनेट से कभी नहीं जुड़ता।';

  @override
  String get openBatterySettings => 'बैटरी सेटिंग्स खोलें';

  @override
  String get batteryAlreadyOk => 'Somno के लिए बैटरी सेविंग पहले से बंद है।';

  @override
  String get startTracking => 'ट्रैकिंग शुरू करें';

  @override
  String get skipForNow => 'अभी छोड़ें';

  @override
  String get done => 'हो गया';

  @override
  String get notifHint =>
      'नोटिफ़िकेशन की अनुमति दें, ताकि Android Somno को चालू रखे। नोटिफ़िकेशन सिर्फ़ इतना बताता है कि ट्रैकिंग चालू है।';

  @override
  String get bannerTrackingOff => 'ट्रैकिंग बंद है।';

  @override
  String get turnOn => 'चालू करें';

  @override
  String get bannerBattery => 'बैटरी सेविंग ट्रैकिंग रोक सकती है।';

  @override
  String get fix => 'ठीक करें';

  @override
  String durationHM(int h, int m) {
    return '$h घं $m मि';
  }

  @override
  String durationH(int h) {
    return '$h घं';
  }

  @override
  String durationM(int m) {
    return '$m मि';
  }

  @override
  String hoursRange(int min, int max) {
    return '$min–$max घंटे';
  }

  @override
  String stepOf(int step, int total) {
    return 'चरण $step/$total';
  }
}
