// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get error => 'Σφάλμα';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Άκυρο';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get back => 'Πίσω';

  @override
  String get requiredField => 'Αυτό το πεδίο είναι υποχρεωτικό';

  @override
  String get invalidUrl => 'Εισαγάγετε έγκυρο URL';

  @override
  String get errorUpdateIncompatible =>
      'This build does not support your Android version or device architecture.';

  @override
  String get errorUpdateInstallFailed =>
      'Android could not open this update. Check the installation permission and try again.';

  @override
  String get errorUpdateIntegrity =>
      'The download is incomplete or its checksum does not match. Please download it again.';

  @override
  String get errorUpdateInvalid =>
      'The release metadata is invalid or does not match the APK.';

  @override
  String get errorUpdateNetwork =>
      'Could not contact GitHub. Please try again.';

  @override
  String get errorUpdateRateLimited =>
      'GitHub is limiting requests. Please try again later.';

  @override
  String get errorUpdateStorage =>
      'Could not save update files or settings. Check available storage and try again.';

  @override
  String get errorUpdateUnavailable =>
      'This channel is temporarily unavailable or has no published build. Please try again later.';

  @override
  String get errorActivityUploadFailed =>
      'Δεν ήταν δυνατή η μεταφόρτωση της δραστηριότητας';

  @override
  String errorActivityUploadFailedWithDetails(String details) {
    return 'Δεν ήταν δυνατή η μεταφόρτωση της δραστηριότητας: $details';
  }

  @override
  String get errorActivityIngestionUnsupportedFormat =>
      'Η μορφή του αρχείου δεν υποστηρίζεται';

  @override
  String get errorActivityIngestionInvalidFile =>
      'Το αρχείο είναι κατεστραμμένο ή δεν ήταν δυνατή η ανάγνωσή του';

  @override
  String get errorActivityIngestionNoActivitiesFound =>
      'Δεν βρέθηκαν δραστηριότητες στο αρχείο';

  @override
  String get errorActivityIngestionProcessingFailed =>
      'Παρουσιάστηκε σφάλμα κατά την εισαγωγή της δραστηριότητας. Δοκιμάστε ξανά.';

  @override
  String get errorActivityIngestionProviderUnavailable =>
      'Ο πάροχος δραστηριοτήτων δεν είναι διαθέσιμος αυτή τη στιγμή. Δοκιμάστε ξανά αργότερα.';

  @override
  String get errorActivityUploadNotConfigured =>
      'Η μεταφόρτωση δραστηριοτήτων δεν έχει ρυθμιστεί ακόμη';

  @override
  String get errorActivityGpxCleanupFailed =>
      'Δεν ήταν δυνατή η διαγραφή του προσωρινού αρχείου δραστηριότητας';

  @override
  String get errorActivityGpxFileWriteFailed =>
      'Δεν ήταν δυνατή η προετοιμασία του αρχείου μεταφόρτωσης της δραστηριότητας';

  @override
  String get errorActivityLocalActivityNotFound =>
      'Δεν ήταν δυνατή η εύρεση αυτής της τοπικής δραστηριότητας';

  @override
  String get errorActivityLocalDeleteFailed =>
      'Δεν ήταν δυνατή η διαγραφή της τοπικής δραστηριότητας';

  @override
  String get errorActivityLocalGpxMissing =>
      'Το τοπικό αρχείο GPX δεν είναι διαθέσιμο';

  @override
  String get errorActivityLocalLoadFailed =>
      'Δεν ήταν δυνατή η φόρτωση των τοπικών δραστηριοτήτων';

  @override
  String get errorActivityLocalRecordInvalid =>
      'Δεν ήταν δυνατή η αποθήκευση αυτής της δραστηριότητας';

  @override
  String get errorActivityLocalSaveFailed =>
      'Δεν ήταν δυνατή η τοπική αποθήκευση της δραστηριότητας';

  @override
  String get errorFetchProvidersFailed =>
      'Δεν ήταν δυνατή η φόρτωση των παρόχων σύνδεσης';

  @override
  String errorFetchProvidersFailedWithDetails(String details) {
    return 'Δεν ήταν δυνατή η φόρτωση των παρόχων σύνδεσης: $details';
  }

  @override
  String get errorFetchServerSettingsFailed =>
      'Δεν ήταν δυνατή η φόρτωση των ρυθμίσεων διακομιστή';

  @override
  String errorFetchServerSettingsFailedWithDetails(String details) {
    return 'Δεν ήταν δυνατή η φόρτωση των ρυθμίσεων διακομιστή: $details';
  }

  @override
  String get errorHealthGpxBuildFailed =>
      'Δεν ήταν δυνατή η μετατροπή της προπόνησης σε GPX';

  @override
  String get errorHealthImportFailed =>
      'Δεν ήταν δυνατή η εισαγωγή της προπόνησης';

  @override
  String errorHealthImportFailedWithDetails(String details) {
    return 'Δεν ήταν δυνατή η εισαγωγή της προπόνησης: $details';
  }

  @override
  String get errorHealthPermissionDenied =>
      'Απορρίφθηκε η πρόσβαση στα δεδομένα υγείας';

  @override
  String get errorHealthReadFailed =>
      'Δεν ήταν δυνατή η ανάγνωση των δεδομένων υγείας';

  @override
  String get errorLoginError => 'Δεν ήταν δυνατή η σύνδεση';

  @override
  String errorLoginErrorWithDetails(String details) {
    return 'Δεν ήταν δυνατή η σύνδεση: $details';
  }

  @override
  String get errorLoginFailed => 'Η σύνδεση απέτυχε';

  @override
  String errorLoginFailedWithDetails(String details) {
    return 'Η σύνδεση απέτυχε: $details';
  }

  @override
  String get errorMfaVerificationError =>
      'Δεν ήταν δυνατή η επαλήθευση του κωδικού MFA';

  @override
  String errorMfaVerificationErrorWithDetails(String details) {
    return 'Δεν ήταν δυνατή η επαλήθευση του κωδικού MFA: $details';
  }

  @override
  String get errorMfaVerificationFailed => 'Η επαλήθευση MFA απέτυχε';

  @override
  String errorMfaVerificationFailedWithDetails(String details) {
    return 'Η επαλήθευση MFA απέτυχε: $details';
  }

  @override
  String get errorNoSessionIdReceived =>
      'Δεν ελήφθη αναγνωριστικό συνεδρίας από τον διακομιστή';

  @override
  String get errorNotAuthenticated => 'Δεν έχετε συνδεθεί';

  @override
  String get errorPkceVerifierMissingRestartLogin =>
      'Ο επαληθευτής σύνδεσης δεν βρέθηκε. Ξεκινήστε ξανά τη σύνδεση.';

  @override
  String get errorServerUrlNotConfigured =>
      'Το URL του διακομιστή δεν έχει ρυθμιστεί';

  @override
  String get errorInsecureTransportNotAllowed =>
      'Αυτός ο διακομιστής απαιτεί ασφαλή σύνδεση (HTTPS)';

  @override
  String get errorSessionExpired => 'Η συνεδρία σας έληξε. Συνδεθείτε ξανά.';

  @override
  String get errorSsoTokenExchangeError =>
      'Δεν ήταν δυνατή η ολοκλήρωση της σύνδεσης SSO';

  @override
  String errorSsoTokenExchangeErrorWithDetails(String details) {
    return 'Δεν ήταν δυνατή η ολοκλήρωση της σύνδεσης SSO: $details';
  }

  @override
  String get errorTokenExchangeFailed => 'Η ανταλλαγή διακριτικών απέτυχε';

  @override
  String errorTokenExchangeFailedWithDetails(String details) {
    return 'Η ανταλλαγή διακριτικών απέτυχε: $details';
  }

  @override
  String get errorRequestTimeout =>
      'Το αίτημα έληξε. Ελέγξτε τη σύνδεσή σας και δοκιμάστε ξανά.';

  @override
  String get errorSecureStorageDeleteFailed =>
      'Δεν είναι δυνατή η διαγραφή από τον ασφαλή χώρο αποθήκευσης. Ο χώρος αποθήκευσης της συσκευής ενδέχεται να μην είναι διαθέσιμος.';

  @override
  String get errorSecureStorageReadFailed =>
      'Δεν είναι δυνατή η ανάγνωση από τον ασφαλή χώρο αποθήκευσης. Ο χώρος αποθήκευσης της συσκευής ενδέχεται να μην είναι διαθέσιμος.';

  @override
  String get errorSecureStorageWriteFailed =>
      'Δεν είναι δυνατή η εγγραφή στον ασφαλή χώρο αποθήκευσης. Ο χώρος αποθήκευσης της συσκευής ενδέχεται να μην είναι διαθέσιμος.';

  @override
  String get errorUnexpectedResponseFormat =>
      'Ο διακομιστής επέστρεψε μια μη αναμενόμενη απόκριση';

  @override
  String get errorUnsupportedHttpMethod => 'Μη υποστηριζόμενη μέθοδος HTTP';

  @override
  String errorUnsupportedHttpMethodWithDetails(String details) {
    return 'Μη υποστηριζόμενη μέθοδος HTTP: $details';
  }

  @override
  String get loginTitle => 'Σύνδεση';

  @override
  String get login => 'Σύνδεση';

  @override
  String get logout => 'Αποσύνδεση';

  @override
  String get logoutConfirmTitle => 'Αποσύνδεση';

  @override
  String get logoutConfirmMessage =>
      'Είστε βέβαιοι ότι θέλετε να αποσυνδεθείτε;';

  @override
  String get logoutServerFailedWarning =>
      'Δεν ήταν δυνατή η αποσύνδεση από τον διακομιστή, αλλά έγινε αποσύνδεση τοπικά';

  @override
  String get ssoBrowserLaunchFailed =>
      'Δεν ήταν δυνατό το άνοιγμα της σύνδεσης SSO στο πρόγραμμα περιήγησης συστήματος';

  @override
  String ssoSignInWith(String provider) {
    return 'Σύνδεση με $provider';
  }

  @override
  String get ssoOrDivider => 'Ή';

  @override
  String get next => 'Επόμενο';

  @override
  String get username => 'Όνομα χρήστη';

  @override
  String get usernameHint => 'Εισαγάγετε το όνομα χρήστη σας';

  @override
  String get password => 'Κωδικός πρόσβασης';

  @override
  String get passwordHint => 'Εισαγάγετε τον κωδικό πρόσβασής σας';

  @override
  String get showPassword => 'Εμφάνιση κωδικού πρόσβασης';

  @override
  String get mfaTitle => 'Έλεγχος ταυτότητας δύο παραγόντων';

  @override
  String get mfaCode => 'Κωδικός MFA';

  @override
  String get mfaCodeHint => 'Εισαγάγετε τον 6ψήφιο κωδικό';

  @override
  String get mfaCodeRequired => 'Εισαγάγετε τον κωδικό MFA';

  @override
  String get verify => 'Επαλήθευση';

  @override
  String get activityDiscard => 'Απόρριψη';

  @override
  String get activityDiscardConfirmMessage =>
      'Αυτό θα διαγράψει τα καταγεγραμμένα σημεία αυτής της δραστηριότητας.';

  @override
  String get activityDiscardConfirmTitle => 'Απόρριψη δραστηριότητας;';

  @override
  String get activityLocationPermissionDenied =>
      'Απαιτείται άδεια τοποθεσίας για την καταγραφή μιας δραστηριότητας.';

  @override
  String get activityLocationPermissionDeniedForever =>
      'Η άδεια τοποθεσίας είναι αποκλεισμένη. Ανοίξτε τις ρυθμίσεις για να επιτρέψετε την πρόσβαση στην τοποθεσία.';

  @override
  String get activityLocationServiceDisabled =>
      'Οι υπηρεσίες τοποθεσίας είναι απενεργοποιημένες.';

  @override
  String get activityLocationStreamFailed =>
      'Οι ενημερώσεις τοποθεσίας σταμάτησαν απροσδόκητα.';

  @override
  String get activityGpxGenerationFailed =>
      'Δεν ήταν δυνατή η δημιουργία του αρχείου GPX της δραστηριότητας.';

  @override
  String get activityLocalSaveFailed =>
      'Δεν ήταν δυνατή η αποθήκευση αυτής της δραστηριότητας σε αυτήν τη συσκευή.';

  @override
  String get activityOpenSettings => 'Άνοιγμα ρυθμίσεων';

  @override
  String get activityPause => 'Παύση';

  @override
  String get activityRecordingEmpty => 'Δεν καταγράφηκαν σημεία GPS.';

  @override
  String get activityRecordingFailed => 'Η καταγραφή απέτυχε.';

  @override
  String get activityResume => 'Συνέχεια';

  @override
  String get activityRetryUpload => 'Επανάληψη μεταφόρτωσης';

  @override
  String get activityDone => 'Τέλος';

  @override
  String get activityViewHistory => 'Προβολή ιστορικού';

  @override
  String get activityDeleteLocal => 'Διαγραφή τοπικού αντιγράφου';

  @override
  String get activityExportGpx => 'Κοινή χρήση αρχείου GPX';

  @override
  String get activityExportGpxSubject => 'GPX δραστηριότητας Endurain';

  @override
  String get activityDeleteLocalConfirmTitle =>
      'Διαγραφή τοπικής δραστηριότητας;';

  @override
  String get activityDeleteLocalConfirmMessage =>
      'Αυτό αφαιρεί την εγγραφή τοπικής δραστηριότητας και το αρχείο GPX από αυτήν τη συσκευή.';

  @override
  String get activityStart => 'Έναρξη';

  @override
  String get activityBackgroundPermissionTitle =>
      'Να επιτρέπεται η παρακολούθηση στο παρασκήνιο;';

  @override
  String get activityBackgroundPermissionMessage =>
      'Το Endurain χρειάζεται την τοποθεσία στο παρασκήνιο ρυθμισμένη σε «Πάντα», ώστε η καταγραφή να συνεχίζεται όταν η εφαρμογή βρίσκεται στο παρασκήνιο, η οθόνη είναι κλειδωμένη ή αλλάζετε εφαρμογή.';

  @override
  String get activityBackgroundPermissionContinue => 'Συνέχεια';

  @override
  String get activityBackgroundPermissionRequired =>
      'Η παρακολούθηση στο παρασκήνιο σε iPhone και iPad απαιτεί την τοποθεσία ρυθμισμένη σε «Πάντα».';

  @override
  String get activityBackgroundPermissionSettingsTitle =>
      'Η παρακολούθηση στο παρασκήνιο είναι απενεργοποιημένη';

  @override
  String get activityBackgroundPermissionSettingsMessage =>
      'Για αξιόπιστη καταγραφή στο παρασκήνιο ή με κλειδωμένη οθόνη, ανοίξτε τις Ρυθμίσεις και ορίστε την Τοποθεσία σε «Πάντα» για το Endurain.';

  @override
  String get activityTrackingNotificationTitle => 'Καταγραφή δραστηριότητας';

  @override
  String get activityTrackingNotificationText =>
      'Το Endurain παρακολουθεί την τοποθεσία σας για να καταγράψει αυτήν τη δραστηριότητα.';

  @override
  String get activityStatDistance => 'Απόσταση';

  @override
  String get activityStatDuration => 'Χρόνος';

  @override
  String get activityStatSpeed => 'Ταχύτητα';

  @override
  String get activityStatPace => 'Ρυθμός';

  @override
  String get activityStatMaxSpeed => 'Μέγιστη ταχύτητα';

  @override
  String get activityStatElevationGain => 'Ανάβαση';

  @override
  String get activityStatHeartRate => 'Καρδιακός ρυθμός';

  @override
  String get activityStatAvgHeartRate => 'Μέσος καρδιακός ρυθμός';

  @override
  String get activityStatPower => 'Ισχύς';

  @override
  String get activityStatAvgPower => 'Μέση ισχύς';

  @override
  String get activityStatCadence => 'Καντένς';

  @override
  String get activityStatAvgCadence => 'Μέση καντένς';

  @override
  String get activityStop => 'Διακοπή';

  @override
  String get activityStopAndSave => 'Διακοπή και αποθήκευση';

  @override
  String get activityStopConfirmMessage =>
      'Επιλέξτε αν θέλετε να διατηρήσετε αυτήν την καταγραφή ή να την απορρίψετε.';

  @override
  String get activityStopConfirmTitle => 'Τερματισμός δραστηριότητας;';

  @override
  String get activityStopping => 'Διακοπή';

  @override
  String get activityTypeHike => 'Πεζοπορία';

  @override
  String get activityTypeLabel => 'Τύπος δραστηριότητας';

  @override
  String get activityTypeOther => 'Άλλο';

  @override
  String get activityTypeRide => 'Ποδηλασία';

  @override
  String get activityTypeRun => 'Τρέξιμο';

  @override
  String get activityTypeWalk => 'Περπάτημα';

  @override
  String get activityUploadFailed => 'Η μεταφόρτωση απέτυχε';

  @override
  String get activityUploadCleanupFailed =>
      'Μεταφορτώθηκε, αλλά ο καθαρισμός απέτυχε';

  @override
  String get activityUploadReady => 'Έτοιμο για μεταφόρτωση';

  @override
  String get activityUploaded => 'Μεταφορτώθηκε';

  @override
  String get activityUploading => 'Μεταφόρτωση';

  @override
  String get activityUploadStatusPending => 'Σε εκκρεμότητα';

  @override
  String get activityUploadStatusUploaded => 'Μεταφορτώθηκε';

  @override
  String get activityUploadStatusFailed => 'Απέτυχε';

  @override
  String get activityHistoryTitle => 'Ιστορικό δραστηριοτήτων';

  @override
  String get activityHistorySettingsSubtitle =>
      'Ολοκληρωμένες δραστηριότητες αποθηκευμένες σε αυτήν τη συσκευή';

  @override
  String get activityRetainUploadedGpx =>
      'Διατήρηση μεταφορτωμένων αρχείων GPX';

  @override
  String get activityRetainUploadedGpxSubtitle =>
      'Αποθηκεύει τα ολοκληρωμένα αρχεία διαδρομής στον ιδιωτικό χώρο αποθήκευσης της εφαρμογής μετά τη μεταφόρτωση.';

  @override
  String get activityAutoPauseTitle => 'Αυτόματη παύση';

  @override
  String get activityAutoPauseSubtitle =>
      'Παύση αυτόματα όταν σταματήσετε να κινείστε';

  @override
  String get activityAutoPauseToggleLabel => 'Αυτόματη παύση';

  @override
  String get activityAutoPauseToggleDescription =>
      'Η καταγραφή τίθεται σε παύση αυτόματα όταν σταματήσετε να κινείστε και συνεχίζεται μόλις ξανακινηθείτε.';

  @override
  String get activityAutoPauseDelayHelperText =>
      'Επιλέξτε πόσο χρόνο χωρίς κίνηση θα περιμένει πριν από την παύση.';

  @override
  String activityAutoPauseDelayOptionLabel(int seconds) {
    return '$seconds δευτερόλεπτα';
  }

  @override
  String get activityAutoPausedIndicator => 'Αυτόματη παύση';

  @override
  String get audioAnnouncementsAutoPaused => 'Η καταγραφή τέθηκε σε παύση';

  @override
  String get audioAnnouncementsAutoResumed => 'Η καταγραφή συνεχίστηκε';

  @override
  String get activityHistoryEmpty =>
      'Δεν υπάρχουν ολοκληρωμένες δραστηριότητες αποθηκευμένες σε αυτήν τη συσκευή.';

  @override
  String get activityHistoryLoadFailed =>
      'Δεν ήταν δυνατή η φόρτωση των τοπικών δραστηριοτήτων.';

  @override
  String get activityHistoryRefresh => 'Ανανέωση';

  @override
  String get activityHistoryLocalActivities => 'Τοπικές δραστηριότητες';

  @override
  String activityHistoryEntryTitle(String activityType, String endedAt) {
    return '$activityType • $endedAt';
  }

  @override
  String activityHistoryDuration(String duration) {
    return 'Διάρκεια: $duration';
  }

  @override
  String activityHistoryDistance(String distance) {
    return 'Απόσταση: $distance';
  }

  @override
  String activityHistoryUploadStatus(String status) {
    return 'Μεταφόρτωση: $status';
  }

  @override
  String get activityHistoryLoadMore => 'Φόρτωση περισσότερων';

  @override
  String get activityHistoryDetailsTitle => 'Λεπτομέρειες δραστηριότητας';

  @override
  String get activityHistoryDetailsMissing =>
      'Αυτή η τοπική δραστηριότητα δεν είναι πλέον διαθέσιμη.';

  @override
  String get activityHistorySummary => 'Σύνοψη';

  @override
  String get activityHistoryActions => 'Ενέργειες';

  @override
  String get activityHistoryType => 'Τύπος';

  @override
  String get activityHistoryStartedAt => 'Έναρξη';

  @override
  String get activityHistoryEndedAt => 'Λήξη';

  @override
  String get activityHistoryDurationLabel => 'Διάρκεια';

  @override
  String get activityHistoryDistanceLabel => 'Απόσταση';

  @override
  String get activityHistoryAverageSpeed => 'Μέση ταχύτητα';

  @override
  String get activityHistoryPointCount => 'Σημεία GPS';

  @override
  String get activityHistoryUploadStatusLabel => 'Μεταφόρτωση';

  @override
  String get activityHistoryGpxStatus => 'Αρχείο GPX';

  @override
  String get activityHistoryGpxAvailable => 'Αποθηκευμένο σε αυτήν τη συσκευή';

  @override
  String get activityHistoryGpxMissing => 'Μη διαθέσιμο σε αυτήν τη συσκευή';

  @override
  String get mapTab => 'Χάρτης';

  @override
  String get myLocation => 'Η τοποθεσία μου';

  @override
  String get updatesCheck => 'Check for updates';

  @override
  String get updatesCheckChannel => 'Verification build';

  @override
  String get updatesCurrent => 'You are up to date.';

  @override
  String get updatesDownload => 'Download';

  @override
  String updatesDownloadSize(String size) {
    return '$size MB';
  }

  @override
  String get updatesInstall => 'Install';

  @override
  String updatesInstalled(String version, String channel) {
    return 'Installed: $version ($channel)';
  }

  @override
  String get updatesInstallerOpened =>
      'Installer opened. Installation is confirmed only after the installed version changes.';

  @override
  String updatesLastChecked(String date) {
    return 'Last successful check: $date';
  }

  @override
  String get updatesLocalChannel => 'Local build';

  @override
  String get updatesNightlyChannel => 'Nightly';

  @override
  String get updatesNightlyDescription =>
      'Latest verified builds. May contain unfinished changes.';

  @override
  String get updatesPermission =>
      'Allow this app to install updates in Android settings, then tap Install again.';

  @override
  String get updatesRecordingActive =>
      'Finish your activity recording before installing an update.';

  @override
  String get updatesStableChannel => 'Stable';

  @override
  String get updatesSubtitle => 'Check GitHub for Stable or Nightly builds';

  @override
  String get updatesTitle => 'App updates';

  @override
  String get updatesUnsupported => 'APK updates are available on Android only.';

  @override
  String get updatesWaitingStable =>
      'Waiting for the next Stable build newer than your installed version.';

  @override
  String get settingsTab => 'Ρυθμίσεις';

  @override
  String get endurainTrademarkNotice =>
      'Το Endurain® είναι καταχωρισμένο εμπορικό σήμα του João Vitória Silva';

  @override
  String get settingsScreen => 'Ρυθμίσεις';

  @override
  String get deviceAccessTitle => 'Πρόσβαση στη συσκευή';

  @override
  String get deviceAccessSubtitle =>
      'Διαχειριστείτε την πρόσβαση σε δεδομένα τοποθεσίας και υγείας';

  @override
  String get deviceAccessLocationSection => 'Τοποθεσία';

  @override
  String get deviceAccessHealthSection => 'Δεδομένα υγείας';

  @override
  String get deviceAccessLocationTitle => 'Πρόσβαση τοποθεσίας';

  @override
  String get deviceAccessHealthTitle => 'Πρόσβαση σε δεδομένα υγείας';

  @override
  String get deviceAccessChecking => 'Έλεγχος πρόσβασης…';

  @override
  String get deviceAccessLocationServicesOff =>
      'Οι υπηρεσίες τοποθεσίας είναι απενεργοποιημένες';

  @override
  String get deviceAccessLocationAlways => 'Επιτρέπεται όλη την ώρα';

  @override
  String get deviceAccessLocationWhileUsing =>
      'Επιτρέπεται κατά τη χρήση της εφαρμογής';

  @override
  String get deviceAccessLocationBlocked =>
      'Αποκλείστηκε στις ρυθμίσεις συστήματος';

  @override
  String get deviceAccessLocationNotAllowed => 'Δεν επιτρέπεται';

  @override
  String get deviceAccessHealthUnavailable =>
      'Δεν είναι διαθέσιμο σε αυτήν τη συσκευή';

  @override
  String get deviceAccessHealthRequired => 'Απαιτείται Health Connect';

  @override
  String get deviceAccessHealthSetUp => 'Ρύθμιση πρόσβασης υγείας';

  @override
  String get deviceAccessHealthNeedsAttention =>
      'Η πρόσβαση χρειάζεται προσοχή';

  @override
  String get deviceAccessHealthNotConnected => 'Δεν είναι συνδεδεμένο';

  @override
  String get language => 'Γλώσσα';

  @override
  String get languageSystemDefault => 'Προεπιλογή συστήματος';

  @override
  String get serverSettings => 'Διακομιστής';

  @override
  String get signInConnectServer => 'Σύνδεση';

  @override
  String get signInConnectServerSubtitle =>
      'Καταγράψτε εκτός σύνδεσης τώρα και συγχρονίστε τις δραστηριότητές σας αργότερα';

  @override
  String get serverSettingsTitle => 'Ρυθμίσεις διακομιστή';

  @override
  String connectedToServer(String server) {
    return 'Συνδέθηκε με $server';
  }

  @override
  String get loggedIn => 'Συνδεδεμένος';

  @override
  String get notConfigured => 'Δεν έχει ρυθμιστεί';

  @override
  String get notLoggedIn => 'Μη συνδεδεμένος';

  @override
  String get serverUrl => 'URL διακομιστή';

  @override
  String get serverProtocol => 'Πρωτόκολλο';

  @override
  String get serverUrlHint => 'https://example.com';

  @override
  String get warnHttpServerUrlTitle => 'Μη ασφαλής σύνδεση';

  @override
  String get warnHttpServerUrlMessage =>
      'Αυτό το URL διακομιστή χρησιμοποιεί απλό HTTP. Τα διαπιστευτήρια και τα δεδομένα σας θα μεταδοθούν χωρίς κρυπτογράφηση. Συνεχίστε μόνο αν κατανοείτε και αποδέχεστε τον κίνδυνο.';

  @override
  String get warnHttpServerUrlConfirm => 'Συνέχεια ούτως ή άλλως';

  @override
  String get tileServerUrl => 'URL διακομιστή πλακιδίων χάρτη';

  @override
  String get tileServerUrlHint => 'https://tile.openstreetmap.org/...';

  @override
  String get tileServerHostWarningTitle =>
      'Διαφορετικός κεντρικός υπολογιστής διακομιστή πλακιδίων';

  @override
  String get tileServerHostWarningMessage =>
      'Ο κεντρικός υπολογιστής του διακομιστή πλακιδίων διαφέρει από τον κεντρικό υπολογιστή του διακομιστή Endurain σας. Τα πλακίδια θα φορτωθούν από διακομιστή τρίτου μέρους. Θέλετε να συνεχίσετε;';

  @override
  String get savedSuccessfully => 'Οι ρυθμίσεις αποθηκεύτηκαν με επιτυχία';

  @override
  String get diagnostics => 'Διαγνωστικά';

  @override
  String get diagnosticsSubtitle => 'Τοπικό πλαίσιο σφαλμάτων';

  @override
  String get sourceCode => 'GitHub';

  @override
  String get sourceCodeSubtitle => 'github.com/endurain-project';

  @override
  String get openLinkFailed => 'Δεν ήταν δυνατό το άνοιγμα του συνδέσμου';

  @override
  String get diagnosticsTitle => 'Διαγνωστικά';

  @override
  String get diagnosticsCollection => 'Συλλογή';

  @override
  String get diagnosticsEnable => 'Συλλογή διαγνωστικών';

  @override
  String get diagnosticsEnableSubtitle =>
      'Αποθήκευση πρόσφατων συμβάντων και σφαλμάτων της εφαρμογής σε αυτή τη συσκευή';

  @override
  String get diagnosticsDisabled =>
      'Η συλλογή διαγνωστικών είναι απενεργοποιημένη. Ενεργοποιήστε την για να ξεκινήσετε την καταγραφή συμβάντων και σφαλμάτων της εφαρμογής σε αυτή τη συσκευή.';

  @override
  String get diagnosticsEmpty => 'Δεν έχουν καταγραφεί ακόμη διαγνωστικά.';

  @override
  String get diagnosticsCopy => 'Αντιγραφή';

  @override
  String get diagnosticsCopied => 'Τα διαγνωστικά αντιγράφηκαν';

  @override
  String get diagnosticsClear => 'Εκκαθάριση';

  @override
  String get diagnosticsCleared => 'Τα διαγνωστικά εκκαθαρίστηκαν';

  @override
  String get diagnosticsSummary => 'Σύνοψη';

  @override
  String get diagnosticsLastUpdated => 'Τελευταία ενημέρωση';

  @override
  String diagnosticsEventsCount(int count) {
    return 'Συμβάντα: $count';
  }

  @override
  String diagnosticsErrorsCount(int count) {
    return 'Σφάλματα: $count';
  }

  @override
  String get diagnosticsEvents => 'Συμβάντα';

  @override
  String get diagnosticsNoEvents => 'Δεν καταγράφηκαν συμβάντα';

  @override
  String diagnosticsEventTitle(String event) {
    return 'Συμβάν: $event';
  }

  @override
  String get diagnosticsErrors => 'Σφάλματα';

  @override
  String diagnosticsErrorTitle(String type) {
    return 'Σφάλμα: $type';
  }

  @override
  String get diagnosticsActions => 'Ενέργειες';

  @override
  String get diagnosticsRawReport => 'Ακατέργαστη αναφορά';

  @override
  String get healthSyncSettingsTitle => 'Συγχρονισμός υγείας';

  @override
  String get healthSyncSettingsSubtitle =>
      'Εισαγάγετε προπονήσεις από την πλατφόρμα υγείας σας';

  @override
  String get healthSyncScreenTitle => 'Συγχρονισμός υγείας';

  @override
  String get healthAccessScreenTitle => 'Πρόσβαση στην υγεία';

  @override
  String get healthAccessRequestedData => 'Ζητούμενα δεδομένα';

  @override
  String get healthAccessWorkouts => 'Προπονήσεις';

  @override
  String get healthAccessWorkoutRoutes => 'Διαδρομές προπόνησης';

  @override
  String get healthAccessHeartRate => 'Καρδιακός ρυθμός';

  @override
  String get healthAccessWorkoutSummary =>
      'Απόσταση, θερμίδες και βήματα προπόνησης';

  @override
  String get healthAccessAllowed => 'Επιτρέπεται';

  @override
  String get healthAccessNeedsAttention => 'Χρειάζεται προσοχή';

  @override
  String get healthAccessManagedBySystem =>
      'Διαχειρίζεται στις ρυθμίσεις συστήματος';

  @override
  String get healthAccessSystemManagedNotice =>
      'Το HealthKit δεν αποκαλύπτει ποια δεδομένα μπορεί να διαβάσει το Endurain. Ελέγξτε την πρόσβαση στην εφαρμογή Υγεία.';

  @override
  String get healthAccessReview => 'Ελέγξτε την πρόσβαση στην υγεία';

  @override
  String get healthAccessReviewIos => 'Πώς να ελέγξετε την πρόσβαση';

  @override
  String get healthAccessDisconnect => 'Αποσύνδεση δεδομένων υγείας';

  @override
  String get healthAccessDisconnectTitle => 'Αποσύνδεση δεδομένων υγείας;';

  @override
  String get healthAccessDisconnectMessage =>
      'Η αυτόματη εισαγωγή και το τοπικό ιστορικό εισαγωγών για αυτόν τον διακομιστή θα επαναφερθούν. Οι υπάρχουσες δραστηριότητες παραμένουν στο ιστορικό.';

  @override
  String get healthAccessReviewIosInstructions =>
      'Ανοίξτε την εφαρμογή Υγεία, πατήστε τη φωτογραφία του προφίλ σας και, στη συνέχεια, Εφαρμογές και Υπηρεσίες. Επιλέξτε Endurain και ενημερώστε τις κατηγορίες δεδομένων.';

  @override
  String get healthSyncAuthorize => 'Σύνδεση σε δεδομένα υγείας';

  @override
  String get healthSyncInstallProvider => 'Εγκαταστήστε το Health Connect';

  @override
  String get healthSyncInstallProviderDescription =>
      'Απαιτείται Health Connect για τον συγχρονισμό των προπονήσεων. Εγκαταστήστε το για να συνεχίσετε.';

  @override
  String get healthSyncUnsupported =>
      'Ο συγχρονισμός υγείας δεν είναι διαθέσιμος σε αυτήν τη συσκευή.';

  @override
  String get healthSyncSelectAll => 'Επιλέξτε όλα';

  @override
  String get healthSyncClearSelection => 'Καθαρό';

  @override
  String healthSyncImportSelected(int count) {
    return 'Επιλέχτηκε εισαγωγή ($count)';
  }

  @override
  String healthSyncImportedCount(int count) {
    return 'Εισήχθησαν $count προπόνηση(ες).';
  }

  @override
  String get healthSyncNoRouteLabel => 'Δεν υπάρχει διαδρομή GPS';

  @override
  String get healthSyncEmptyState =>
      'Δεν βρέθηκαν προπονήσεις στο επιλεγμένο χρονικό διάστημα.';

  @override
  String get healthSyncRouteConsentGuidance =>
      'Ορισμένες προπονήσεις παραλείφθηκαν επειδή δεν παραχωρήθηκε πρόσβαση στη διαδρομή άσκησης. Ανοίξτε το Health Connect → Άδειες και επιτρέψτε διαδρομές άσκησης για το Endurain.';

  @override
  String get healthSyncRouteConsentGuidanceIos =>
      'Ορισμένες προπονήσεις παραλείφθηκαν επειδή ο Endurain δεν μπορούσε να διαβάσει τις διαδρομές του GPS. Στην εφαρμογή Υγεία, ανοίξτε το προφίλ σας, στη συνέχεια Εφαρμογές και υπηρεσίες, επιλέξτε Endurain και επιτρέψτε τις διαδρομές προπόνησης.';

  @override
  String get healthSyncReviewAccess => 'Έλεγχος πρόσβασης';

  @override
  String get healthSyncAutoSyncTitle => 'Αυτόματος συγχρονισμός στη συνέχιση';

  @override
  String get healthSyncAutoSyncSubtitle =>
      'Εισαγάγετε αυτόματα νέες προπονήσεις όταν ανοίξει η εφαρμογή.';

  @override
  String get healthSyncNoRoutesExplanation =>
      'Αυτές οι προπονήσεις δεν περιλαμβάνουν διαδρομή GPS, επομένως δεν είναι δυνατή η εισαγωγή τους. Ορισμένες εφαρμογές (όπως το Garmin Connect) καταγράφουν δραστηριότητες στο Apple Health χωρίς να μοιράζονται τη διαδρομή. Οι προπονήσεις που καταγράφονται με το Apple Watch περιλαμβάνουν διαδρομές και μπορούν να εισαχθούν.';

  @override
  String get healthSyncBadgeNonImportable => 'Μη εισαγόμενο';

  @override
  String get healthSyncViewAvailable => 'Διαθέσιμα';

  @override
  String get healthSyncViewImported => 'Εισαγμένα';

  @override
  String get healthSyncDateRange => 'Περίοδος προπονήσεων';

  @override
  String get healthSyncRange30Days => 'Τελευταίες 30 ημέρες';

  @override
  String get healthSyncRange3Months => 'Τελευταίοι 3 μήνες';

  @override
  String get healthSyncRange6Months => 'Τελευταίοι 6 μήνες';

  @override
  String get healthSyncRangeYear => 'Τελευταίο έτος';

  @override
  String get healthSyncRangeAll => 'Όλο το ιστορικό';

  @override
  String get healthSyncRangeCustom => 'Προσαρμοσμένη περίοδος';

  @override
  String get healthSyncImportedEmpty =>
      'Δεν υπάρχουν εισαγμένες προπονήσεις για αυτή τη σύνδεση.';

  @override
  String healthSyncImportedAt(String dateTime) {
    return 'Εισαγωγή: $dateTime';
  }

  @override
  String get healthSyncRestore => 'Επαναφορά';

  @override
  String get sensorsTitle => 'Αισθητήρες';

  @override
  String get sensorsSettingsSubtitle =>
      'Μετρητές καρδιακών παλμών και άλλοι εξωτερικοί αισθητήρες';

  @override
  String get sensorsHeartRateSection => 'Καρδιακός ρυθμός';

  @override
  String get sensorsHeartRateHelp =>
      'Συζεύξτε έναν μετρητή καρδιακών παλμών Bluetooth για να βλέπετε τον καρδιακό σας ρυθμό σε πραγματικό χρόνο.';

  @override
  String get sensorsBluetoothOff =>
      'Το Bluetooth είναι απενεργοποιημένο. Ενεργοποιήστε το για να συνδέσετε έναν αισθητήρα.';

  @override
  String get sensorsBluetoothUnauthorized =>
      'Επιτρέψτε την πρόσβαση στο Bluetooth για να συνδέσετε έναν αισθητήρα.';

  @override
  String get sensorsBluetoothUnsupported =>
      'Αυτή η συσκευή δεν υποστηρίζει Bluetooth Low Energy.';

  @override
  String get sensorsScan => 'Αναζήτηση αισθητήρων';

  @override
  String get sensorsScanning => 'Αναζήτηση…';

  @override
  String get sensorsStopScan => 'Διακοπή';

  @override
  String get sensorsNoDevices =>
      'Δεν βρέθηκαν ακόμη αισθητήρες καρδιακών παλμών.';

  @override
  String get sensorsAvailableSection => 'Διαθέσιμοι αισθητήρες';

  @override
  String get sensorsSavedSection => 'Αποθηκευμένος αισθητήρας';

  @override
  String get sensorsConnect => 'Σύνδεση';

  @override
  String get sensorsConnecting => 'Σύνδεση…';

  @override
  String get sensorsConnected => 'Συνδέθηκε';

  @override
  String get sensorsDisconnect => 'Αποσύνδεση';

  @override
  String get sensorsForget => 'Κατάργηση';

  @override
  String get sensorsConnectionFailed => 'Η σύνδεση απέτυχε. Δοκιμάστε ξανά.';

  @override
  String get sensorsPermissionRequired =>
      'Απαιτείται άδεια Bluetooth για την εύρεση αισθητήρων.';

  @override
  String get sensorsUnknownDevice => 'Άγνωστος αισθητήρας';

  @override
  String sensorsBpm(String bpm) {
    return '$bpm bpm';
  }

  @override
  String get sensorsPowerSection => 'Ισχύς';

  @override
  String get sensorsPowerHelp =>
      'Συζεύξτε έναν μετρητή ισχύος Bluetooth για να βλέπετε την ισχύ σας σε πραγματικό χρόνο.';

  @override
  String get sensorsNoPowerDevices => 'Δεν βρέθηκαν ακόμη μετρητές ισχύος.';

  @override
  String sensorsWatts(String watts) {
    return '$watts W';
  }

  @override
  String get sensorsCadenceSection => 'Καντένς';

  @override
  String get sensorsCadenceHelp =>
      'Συζεύξτε έναν αισθητήρα καντένς Bluetooth για να βλέπετε την καντένς σας σε πραγματικό χρόνο.';

  @override
  String get sensorsNoCadenceDevices =>
      'Δεν βρέθηκαν ακόμη αισθητήρες καντένς.';

  @override
  String sensorsRpm(String rpm) {
    return '$rpm rpm';
  }

  @override
  String get diagnosticsRemoteTitle => 'Απομακρυσμένη αναφορά καταρρεύσεων';

  @override
  String get diagnosticsRemoteEnable => 'Αποστολή αναφορών κατάρρευσης';

  @override
  String get diagnosticsRemoteEnableSubtitle =>
      'Στείλτε αναφορές κατάρρευσης και σφαλμάτων σε έναν διακομιστή διαγνωστικών. Είναι ανεξάρτητο από τα τοπικά διαγνωστικά; μπορείτε να ενεργοποιήσετε και τα δύο, ένα ή κανένα.';

  @override
  String get diagnosticsRemoteActive => 'Crash reports are being sent.';

  @override
  String get diagnosticsRemoteNeedsServer =>
      'Η απομακρυσμένη αναφορά καταρρεύσεων δεν είναι διαθέσιμη σε αυτήν την έκδοση.';

  @override
  String unitMeter(String value) {
    return '$value μ';
  }

  @override
  String unitKilometer(String value) {
    return '$value χλμ';
  }

  @override
  String unitFoot(String value) {
    return '$value πόδ';
  }

  @override
  String unitMile(String value) {
    return '$value μί';
  }

  @override
  String unitKilometersPerHour(String value) {
    return '$value χλμ/ώ';
  }

  @override
  String unitMilesPerHour(String value) {
    return '$value μί/ώ';
  }

  @override
  String unitMinutesPerKilometer(String value) {
    return '$value λεπ/χλμ';
  }

  @override
  String unitMinutesPerMile(String value) {
    return '$value λεπ/μί';
  }

  @override
  String unitBpm(String value) {
    return '$value bpm';
  }

  @override
  String unitWatt(String value) {
    return '$value W';
  }

  @override
  String unitRpm(String value) {
    return '$value rpm';
  }

  @override
  String get unitsTitle => 'Μονάδες';

  @override
  String get unitsSubtitle => 'Μονάδες απόστασης, ταχύτητας και υψομέτρου';

  @override
  String get unitsSystemDefault => 'Σύμφωνα με την περιοχή συσκευής';

  @override
  String get unitsMetric => 'Μετρικές (χλμ)';

  @override
  String get unitsImperial => 'Αυτοκρατορικές (μί)';

  @override
  String get errorInsecureRedirectRejected =>
      'The server tried to redirect to an insecure connection. The request was blocked to protect your credentials.';

  @override
  String get errorTooManyRedirects =>
      'The server redirected too many times. Check the server address.';

  @override
  String get audioAnnouncementsTitle => 'Φωνητικές ανακοινώσεις';

  @override
  String get audioAnnouncementsSubtitle =>
      'Φωνητικές ενημερώσεις για απόσταση, χρόνο, ρυθμό ή ταχύτητα';

  @override
  String get audioAnnouncementsMasterSwitch =>
      'Ανακοίνωση προόδου δραστηριότητας';

  @override
  String get audioAnnouncementsMasterSwitchSubtitle =>
      'Εκφωνεί την απόσταση, τον χρόνο, τον ρυθμό ή την ταχύτητά σας κατά την εγγραφή';

  @override
  String get audioAnnouncementsDuckSwitch =>
      'Χαμήλωμα άλλου ήχου κατά την ομιλία';

  @override
  String get audioAnnouncementsDuckSwitchSubtitle =>
      'Μειώνει προσωρινά την ένταση άλλου ήχου κατά τη διάρκεια κάθε ανακοίνωσης';

  @override
  String get audioAnnouncementsIntervalsHeader =>
      'Διάστημα ανακοίνωσης ανά δραστηριότητα';

  @override
  String get audioAnnouncementsByDistance => 'Απόσταση';

  @override
  String get audioAnnouncementsByTime => 'Χρόνος';

  @override
  String audioAnnouncementsIntervalDistance(String value, String unit) {
    return 'Κάθε $value $unit';
  }

  @override
  String audioAnnouncementsIntervalTime(String minutes) {
    return 'Κάθε $minutes λεπτά';
  }

  @override
  String get audioAnnouncementsDecreaseInterval => 'Μείωση διαστήματος';

  @override
  String get audioAnnouncementsIncreaseInterval => 'Αύξηση διαστήματος';

  @override
  String get audioAnnouncementsPreview => 'Ακρόαση δείγματος';

  @override
  String get audioAnnouncementsPreviewUnavailable =>
      'Το δείγμα ανακοίνωσης δεν είναι διαθέσιμο σε αυτή τη συσκευή';

  @override
  String get audioAnnouncementsAppliesNextRecording =>
      'Οι αλλαγές ισχύουν από την επόμενη καταγραφή σας.';

  @override
  String audioAnnouncementsSpokenMessage(
    String distance,
    String duration,
    String lapMetric,
    String overallMetric,
  ) {
    return 'Απόσταση $distance. Χρόνος $duration. Γύρος: $lapMetric. Συνολικά: $overallMetric.';
  }

  @override
  String get activitiesTab => 'Activities';

  @override
  String get serverActivitiesSearch => 'Search name or location';

  @override
  String get serverActivitiesAllSports => 'All sports';

  @override
  String get serverActivitiesDateFilter => 'Date range';

  @override
  String get serverActivitiesClearFilters => 'Clear filters';

  @override
  String get serverActivitiesEmpty =>
      'No activities yet. Your server activities will appear here.';

  @override
  String get serverActivitiesNoMatches => 'No activities match your filters.';

  @override
  String get serverActivitiesLoadFailed =>
      'Activities could not be loaded. Pull to refresh or try again.';

  @override
  String get serverActivitiesMoreFailed =>
      'More activities could not be loaded. Your loaded activities are still available.';

  @override
  String get serverActivitiesRetry => 'Try again';

  @override
  String get serverActivitiesLoadMore => 'Load more';

  @override
  String get serverActivitiesGuestTitle => 'Your activities, together';

  @override
  String get serverActivitiesGuestMessage =>
      'Connect your Endurain account to browse the activities saved on your server.';

  @override
  String get serverActivitiesSignIn => 'Connect account';

  @override
  String get serverActivitiesStartDate => 'Start date';

  @override
  String get serverActivitiesEndDate => 'End date';

  @override
  String get serverActivitiesNewestFirst => 'Newest first';

  @override
  String get serverActivitiesClearDates => 'Clear date range';

  @override
  String serverActivitySport(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      '1': 'Run',
      '2': 'Trail run',
      '3': 'Virtual run',
      '4': 'Ride',
      '5': 'Gravel ride',
      '6': 'Mountain bike',
      '7': 'Virtual ride',
      '8': 'Pool swim',
      '9': 'Open water swim',
      '10': 'Workout',
      '11': 'Walk',
      '12': 'Hike',
      '13': 'Rowing',
      '14': 'Yoga',
      '15': 'Alpine ski',
      '16': 'Nordic ski',
      '17': 'Snowboard',
      '18': 'Transition',
      '19': 'Strength training',
      '20': 'Crossfit',
      '21': 'Tennis',
      '22': 'Table tennis',
      '23': 'Badminton',
      '24': 'Squash',
      '25': 'Racquetball',
      '26': 'Pickleball',
      '27': 'Commuting ride',
      '28': 'Indoor ride',
      '29': 'Mixed surface ride',
      '30': 'Windsurf',
      '31': 'Indoor walk',
      '32': 'Stand up paddling',
      '33': 'Surf',
      '34': 'Track run',
      '35': 'E-bike ride',
      '36': 'E-mountain bike',
      '37': 'Ice skating',
      '38': 'Soccer',
      '39': 'Padel',
      '40': 'Treadmill run',
      '41': 'Cardio training',
      '42': 'Kayaking',
      '43': 'Sailing',
      '44': 'Snowshoeing',
      '45': 'Inline skating',
      '46': 'HIIT',
      '47': 'Jump rope',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get errorServerActivitiesFetchFailed =>
      'Server activities could not be loaded.';

  @override
  String serverActivityUnitMinutesPer100Meters(String value) {
    return '$value min/100m';
  }

  @override
  String serverActivityUnitMinutesPer100Yards(String value) {
    return '$value min/100yd';
  }

  @override
  String serverActivityUnitMinutesPer500Meters(String value) {
    return '$value min/500m';
  }

  @override
  String serverActivityUnitYard(String value) {
    return '$value yd';
  }

  @override
  String serverActivityUnitKnots(String value) {
    return '$value kn';
  }

  @override
  String get serverActivityAccountChanged =>
      'The account has changed. Return to activities to open a detail.';

  @override
  String get serverActivityDetailFailed => 'Could not load activity details.';

  @override
  String get serverActivityRoute => 'Route';

  @override
  String get serverActivityRouteFailed => 'Could not load the route.';

  @override
  String get serverActivityNoRoute => 'No GPS route available.';

  @override
  String get serverActivityDescription => 'Description';

  @override
  String get serverActivityElapsedTime => 'Elapsed time';

  @override
  String get serverActivityCalories => 'Calories';

  @override
  String get statsTab => 'Statistics';

  @override
  String get statsWeek => 'Week';

  @override
  String get statsMonth => 'Month';

  @override
  String get statsYear => 'Year';

  @override
  String get statsPrevious => 'Previous period';

  @override
  String get statsNext => 'Next period';

  @override
  String get statsGuest =>
      'Connect your account to see your training statistics.';

  @override
  String get statsLoadFailed =>
      'Statistics could not be loaded. Pull to refresh or try again.';

  @override
  String get statsDistance => 'Total distance';

  @override
  String get statsDuration => 'Duration';

  @override
  String get statsCount => 'Activities';

  @override
  String get statsElevation => 'Elevation gain';

  @override
  String get statsEmpty => 'No activities in this period.';

  @override
  String get statsDistanceTrend => 'Distance over time';

  @override
  String get statsDurationTrend => 'Duration over time';

  @override
  String get statsSports => 'By sport';

  @override
  String get statsCalendarNote =>
      'Server calendar (UTC), using your web week-start setting. Distance includes distance-based sports only.';

  @override
  String get statsPartialWeeks =>
      'Weeks within this month, including partial weeks. Only weeks with activities are shown.';

  @override
  String statsWeekContaining(String date) {
    return 'Week containing $date';
  }

  @override
  String statsWeekNumber(int number) {
    return 'Week $number';
  }

  @override
  String get chartTitle => 'Charts';

  @override
  String get chartNoData => 'No measurement streams available.';

  @override
  String get chartLoadFailed => 'Could not load charts.';

  @override
  String get chartLaps => 'Recorded laps';

  @override
  String get chartLapsEmpty => 'No recorded laps available.';

  @override
  String get chartLapsFailed => 'Could not load laps.';

  @override
  String get chartTimeAxis => 'Time from first measurement';

  @override
  String get chartSampleAxis => 'Measurement number (timestamps unavailable)';

  @override
  String get chartReadHint =>
      'Tap the chart or use the slider to read measurements.';

  @override
  String get chartCadence => 'Cadence';

  @override
  String get chartTemperature => 'Temperature';

  @override
  String get chartRest => 'Recovery';

  @override
  String get chartLap => 'Lap';

  @override
  String get chartSpm => 'spm';

  @override
  String get homeTab => 'Home';

  @override
  String get homeGreeting => 'Every activity counts.';

  @override
  String get homeWeek => 'Your week';

  @override
  String get homeActiveTime => 'Time in motion';

  @override
  String get homeDailyTime => 'Active time per day';

  @override
  String get homeGoals => 'Your goals';

  @override
  String get homeAllGoals => 'All goals';

  @override
  String get homeRecent => 'Recently achieved';

  @override
  String get homeAllActivities => 'All activities';

  @override
  String get homeRecordActivity => 'Record Activity';

  @override
  String get homeReturnToRecording => 'Return to recording';

  @override
  String get homeRecordingActive => 'Recording in progress';

  @override
  String get homeRecordingPaused => 'Recording paused';

  @override
  String get homeNoGoals =>
      'Set your goals in Endurain to see your progress here.';

  @override
  String get homeGuestGoals =>
      'Connect your Endurain account to see your goals.';

  @override
  String get homeNoActivities => 'Your next activity starts here.';

  @override
  String get homeGoalAchieved => 'Goal reached';

  @override
  String get homeLoadFailed => 'Could not update. Pull down to retry.';

  @override
  String get homeGoalDaily => 'Daily';

  @override
  String get homeGoalWeekly => 'Weekly';

  @override
  String get homeGoalMonthly => 'Monthly';

  @override
  String get homeGoalYearly => 'Yearly';

  @override
  String get homeGoalCalories => 'Calories';

  @override
  String get homePendingUploads =>
      'Activities awaiting upload are not included in server totals.';

  @override
  String homeActivitiesCount(int count) {
    return '$count activities';
  }

  @override
  String homeActiveDays(int count) {
    return 'In motion on $count days. Well done!';
  }

  @override
  String homeGoalRemaining(String value) {
    return '$value to your goal';
  }

  @override
  String get homeGoalSwim => 'Swimming';

  @override
  String get errorActivityUploadInsufficientGps =>
      'This activity has too few GPS points to upload. At least two timed GPS points in the same recording segment are required. The local recording is saved and can be exported.';

  @override
  String get errorActivityUploadInvalidGpx =>
      'The saved GPX file could not be read. The local recording is preserved and can be exported.';
}
