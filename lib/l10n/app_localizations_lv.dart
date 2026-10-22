// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get error => 'Kļūda';

  @override
  String get ok => 'Labi';

  @override
  String get cancel => 'Atcelt';

  @override
  String get save => 'Saglabāt';

  @override
  String get back => 'Atpakaļ';

  @override
  String get requiredField => 'Šis lauks ir obligāts';

  @override
  String get invalidUrl => 'Ievadiet derīgu URL';

  @override
  String get errorActivityUploadFailed => 'Neizdevās augšupielādēt aktivitāti';

  @override
  String errorActivityUploadFailedWithDetails(String details) {
    return 'Neizdevās augšupielādēt aktivitāti: $details';
  }

  @override
  String get errorActivityIngestionUnsupportedFormat =>
      'Faila formāts netiek atbalstīts';

  @override
  String get errorActivityIngestionInvalidFile =>
      'Fails ir bojāts vai to nevarēja nolasīt';

  @override
  String get errorActivityIngestionNoActivitiesFound =>
      'Failā netika atrastas aktivitātes';

  @override
  String get errorActivityIngestionProcessingFailed =>
      'Importējot aktivitāti, radās kļūda. Mēģiniet vēlreiz.';

  @override
  String get errorActivityIngestionProviderUnavailable =>
      'Aktivitāšu sniedzējs pašlaik nav pieejams. Mēģiniet vēlāk.';

  @override
  String get errorActivityUploadNotConfigured =>
      'Aktivitāšu augšupielāde vēl nav konfigurēta';

  @override
  String get errorActivityGpxCleanupFailed =>
      'Neizdevās izdzēst pagaidu aktivitātes failu';

  @override
  String get errorActivityGpxFileWriteFailed =>
      'Neizdevās sagatavot aktivitātes augšupielādes failu';

  @override
  String get errorActivityLocalActivityNotFound =>
      'Neizdevās atrast šo lokālo aktivitāti';

  @override
  String get errorActivityLocalDeleteFailed =>
      'Neizdevās izdzēst lokālo aktivitāti';

  @override
  String get errorActivityLocalGpxMissing => 'Lokālais GPX fails nav pieejams';

  @override
  String get errorActivityLocalLoadFailed =>
      'Neizdevās ielādēt lokālās aktivitātes';

  @override
  String get errorActivityLocalRecordInvalid =>
      'Neizdevās saglabāt šo aktivitāti';

  @override
  String get errorActivityLocalSaveFailed =>
      'Neizdevās saglabāt aktivitāti lokāli';

  @override
  String get errorFetchProvidersFailed =>
      'Neizdevās ielādēt pieteikšanās nodrošinātājus';

  @override
  String errorFetchProvidersFailedWithDetails(String details) {
    return 'Neizdevās ielādēt pieteikšanās nodrošinātājus: $details';
  }

  @override
  String get errorFetchServerSettingsFailed =>
      'Neizdevās ielādēt servera iestatījumus';

  @override
  String errorFetchServerSettingsFailedWithDetails(String details) {
    return 'Neizdevās ielādēt servera iestatījumus: $details';
  }

  @override
  String get errorHealthGpxBuildFailed => 'Nevarēja konvertēt treniņu uz GPX';

  @override
  String get errorHealthImportFailed => 'Nevarēja importēt treniņu';

  @override
  String errorHealthImportFailedWithDetails(String details) {
    return 'Nevarēja importēt treniņu: $details';
  }

  @override
  String get errorHealthPermissionDenied =>
      'Piekļuve veselības datiem tika liegta';

  @override
  String get errorHealthReadFailed => 'Nevarēja nolasīt veselības datus';

  @override
  String get errorLoginError => 'Neizdevās pieteikties';

  @override
  String errorLoginErrorWithDetails(String details) {
    return 'Neizdevās pieteikties: $details';
  }

  @override
  String get errorLoginFailed => 'Pieteikšanās neizdevās';

  @override
  String errorLoginFailedWithDetails(String details) {
    return 'Pieteikšanās neizdevās: $details';
  }

  @override
  String get errorMfaVerificationError => 'Neizdevās pārbaudīt MFA kodu';

  @override
  String errorMfaVerificationErrorWithDetails(String details) {
    return 'Neizdevās pārbaudīt MFA kodu: $details';
  }

  @override
  String get errorMfaVerificationFailed => 'MFA pārbaude neizdevās';

  @override
  String errorMfaVerificationFailedWithDetails(String details) {
    return 'MFA pārbaude neizdevās: $details';
  }

  @override
  String get errorNoSessionIdReceived => 'No servera netika saņemts sesijas ID';

  @override
  String get errorNotAuthenticated => 'Jūs neesat pieteicies';

  @override
  String get errorPkceVerifierMissingRestartLogin =>
      'Pieteikšanās verificētājs netika atrasts. Sāciet pieteikšanos no jauna.';

  @override
  String get errorServerUrlNotConfigured => 'Servera URL nav konfigurēts';

  @override
  String get errorInsecureTransportNotAllowed =>
      'Šim serverim nepieciešams drošs (HTTPS) savienojums';

  @override
  String get errorSessionExpired =>
      'Jūsu sesija ir beigusies. Piesakieties vēlreiz.';

  @override
  String get errorSsoTokenExchangeError => 'Neizdevās pabeigt SSO pieteikšanos';

  @override
  String errorSsoTokenExchangeErrorWithDetails(String details) {
    return 'Neizdevās pabeigt SSO pieteikšanos: $details';
  }

  @override
  String get errorTokenExchangeFailed => 'Pilnvaru apmaiņa neizdevās';

  @override
  String errorTokenExchangeFailedWithDetails(String details) {
    return 'Pilnvaru apmaiņa neizdevās: $details';
  }

  @override
  String get errorRequestTimeout =>
      'Pieprasījuma noildze. Pārbaudiet savienojumu un mēģiniet vēlreiz.';

  @override
  String get errorSecureStorageDeleteFailed =>
      'Nevar izdzēst no drošās krātuves. Ierīces krātuve, iespējams, nav pieejama.';

  @override
  String get errorSecureStorageReadFailed =>
      'Nevar nolasīt no drošās krātuves. Ierīces krātuve, iespējams, nav pieejama.';

  @override
  String get errorSecureStorageWriteFailed =>
      'Nevar ierakstīt drošajā krātuvē. Ierīces krātuve, iespējams, nav pieejama.';

  @override
  String get errorUnexpectedResponseFormat =>
      'Serveris atgrieza negaidītu atbildi';

  @override
  String get errorUnsupportedHttpMethod => 'Neatbalstīta HTTP metode';

  @override
  String errorUnsupportedHttpMethodWithDetails(String details) {
    return 'Neatbalstīta HTTP metode: $details';
  }

  @override
  String get loginTitle => 'Pieteikšanās';

  @override
  String get login => 'Pieteikties';

  @override
  String get logout => 'Atteikties';

  @override
  String get logoutConfirmTitle => 'Atteikties';

  @override
  String get logoutConfirmMessage => 'Vai tiešām vēlaties atteikties?';

  @override
  String get logoutServerFailedWarning =>
      'Neizdevās atteikties no servera, bet atteikšanās veikta lokāli';

  @override
  String get ssoBrowserLaunchFailed =>
      'Neizdevās atvērt SSO pieteikšanos sistēmas pārlūkā';

  @override
  String ssoSignInWith(String provider) {
    return 'Pieteikties ar $provider';
  }

  @override
  String get ssoOrDivider => 'VAI';

  @override
  String get next => 'Tālāk';

  @override
  String get username => 'Lietotājvārds';

  @override
  String get usernameHint => 'Ievadiet savu lietotājvārdu';

  @override
  String get password => 'Parole';

  @override
  String get passwordHint => 'Ievadiet savu paroli';

  @override
  String get showPassword => 'Rādīt paroli';

  @override
  String get mfaTitle => 'Divfaktoru autentifikācija';

  @override
  String get mfaCode => 'MFA kods';

  @override
  String get mfaCodeHint => 'Ievadiet 6 ciparu kodu';

  @override
  String get mfaCodeRequired => 'Ievadiet MFA kodu';

  @override
  String get verify => 'Pārbaudīt';

  @override
  String get activityDiscard => 'Atmest';

  @override
  String get activityDiscardConfirmMessage =>
      'Tādējādi tiks izdzēsti šīs aktivitātes ierakstītie punkti.';

  @override
  String get activityDiscardConfirmTitle => 'Atmest aktivitāti?';

  @override
  String get activityLocationPermissionDenied =>
      'Lai ierakstītu aktivitāti, nepieciešama atrašanās vietas atļauja.';

  @override
  String get activityLocationPermissionDeniedForever =>
      'Atrašanās vietas atļauja ir bloķēta. Atveriet iestatījumus, lai atļautu piekļuvi atrašanās vietai.';

  @override
  String get activityLocationServiceDisabled =>
      'Atrašanās vietas pakalpojumi ir atspējoti.';

  @override
  String get activityLocationStreamFailed =>
      'Atrašanās vietas atjauninājumi negaidīti apstājās.';

  @override
  String get activityGpxGenerationFailed =>
      'Neizdevās izveidot aktivitātes GPX failu.';

  @override
  String get activityLocalSaveFailed =>
      'Neizdevās saglabāt šo aktivitāti šajā ierīcē.';

  @override
  String get activityOpenSettings => 'Atvērt iestatījumus';

  @override
  String get activityPause => 'Pauze';

  @override
  String get activityRecordingEmpty => 'Netika ierakstīts neviens GPS punkts.';

  @override
  String get activityRecordingFailed => 'Ierakstīšana neizdevās.';

  @override
  String get activityResume => 'Turpināt';

  @override
  String get activityRetryUpload => 'Mēģināt augšupielādēt vēlreiz';

  @override
  String get activityDone => 'Gatavs';

  @override
  String get activityViewHistory => 'Skatīt vēsturi';

  @override
  String get activityDeleteLocal => 'Dzēst lokālo kopiju';

  @override
  String get activityExportGpx => 'Kopīgot GPX failu';

  @override
  String get activityExportGpxSubject => 'Endurain aktivitātes GPX';

  @override
  String get activityDeleteLocalConfirmTitle => 'Dzēst lokālo aktivitāti?';

  @override
  String get activityDeleteLocalConfirmMessage =>
      'Tādējādi no šīs ierīces tiek noņemts lokālās aktivitātes ieraksts un GPX fails.';

  @override
  String get activityStart => 'Sākt';

  @override
  String get activityBackgroundPermissionTitle => 'Atļaut izsekošanu fonā?';

  @override
  String get activityBackgroundPermissionMessage =>
      'Endurain nepieciešams, lai fona atrašanās vieta būtu iestatīta uz Vienmēr, lai ierakstīšana turpinātos, kad lietotne ir fonā, ekrāns ir bloķēts vai jūs pārslēdzat lietotnes.';

  @override
  String get activityBackgroundPermissionContinue => 'Turpināt';

  @override
  String get activityBackgroundPermissionRequired =>
      'Izsekošanai fonā iPhone un iPad ierīcēs atrašanās vietai jābūt iestatītai uz Vienmēr.';

  @override
  String get activityBackgroundPermissionSettingsTitle =>
      'Izsekošana fonā ir izslēgta';

  @override
  String get activityBackgroundPermissionSettingsMessage =>
      'Lai droši ierakstītu fonā vai ar bloķētu ekrānu, atveriet Iestatījumus un iestatiet Atrašanās vietu uz Vienmēr Endurain lietotnei.';

  @override
  String get activityTrackingNotificationTitle =>
      'Notiek aktivitātes ierakstīšana';

  @override
  String get activityTrackingNotificationText =>
      'Endurain izseko jūsu atrašanās vietu, lai ierakstītu šo aktivitāti.';

  @override
  String get activityStatDistance => 'Attālums';

  @override
  String get activityStatDuration => 'Laiks';

  @override
  String get activityStatSpeed => 'Ātrums';

  @override
  String get activityStatPace => 'Temps';

  @override
  String get activityStatMaxSpeed => 'Maks. ātrums';

  @override
  String get activityStatElevationGain => 'Kāpums';

  @override
  String get activityStatHeartRate => 'Pulss';

  @override
  String get activityStatAvgHeartRate => 'Vid. pulss';

  @override
  String get activityStatPower => 'Jauda';

  @override
  String get activityStatAvgPower => 'Vid. jauda';

  @override
  String get activityStatCadence => 'Kadence';

  @override
  String get activityStatAvgCadence => 'Vid. kadence';

  @override
  String get activityStop => 'Apturēt';

  @override
  String get activityStopAndSave => 'Apturēt un saglabāt';

  @override
  String get activityStopConfirmMessage =>
      'Izvēlieties, vai saglabāt šo ierakstu vai to atmest.';

  @override
  String get activityStopConfirmTitle => 'Beigt aktivitāti?';

  @override
  String get activityStopping => 'Notiek apturēšana';

  @override
  String get activityTypeHike => 'Pārgājiens';

  @override
  String get activityTypeLabel => 'Aktivitātes veids';

  @override
  String get activityTypeOther => 'Cits';

  @override
  String get activityTypeRide => 'Riteņbraukšana';

  @override
  String get activityTypeRun => 'Skriešana';

  @override
  String get activityTypeWalk => 'Pastaiga';

  @override
  String get activityUploadFailed => 'Augšupielāde neizdevās';

  @override
  String get activityUploadCleanupFailed =>
      'Augšupielādēts, bet tīrīšana neizdevās';

  @override
  String get activityUploadReady => 'Gatavs augšupielādei';

  @override
  String get activityUploaded => 'Augšupielādēts';

  @override
  String get activityUploading => 'Notiek augšupielāde';

  @override
  String get activityUploadStatusPending => 'Gaida';

  @override
  String get activityUploadStatusUploaded => 'Augšupielādēts';

  @override
  String get activityUploadStatusFailed => 'Neizdevās';

  @override
  String get activityHistoryTitle => 'Aktivitāšu vēsture';

  @override
  String get activityHistorySettingsSubtitle =>
      'Šajā ierīcē saglabātās pabeigtās aktivitātes';

  @override
  String get activityRetainUploadedGpx => 'Saglabāt augšupielādētos GPX failus';

  @override
  String get activityRetainUploadedGpxSubtitle =>
      'Pēc augšupielādes saglabā pabeigtos maršrutu failus lietotnes privātajā krātuvē.';

  @override
  String get activityAutoPauseTitle => 'Automātiska pauze';

  @override
  String get activityAutoPauseSubtitle =>
      'Automātiski aptur, kad pārstājat kustēties';

  @override
  String get activityAutoPauseToggleLabel => 'Automātiski pauzēt';

  @override
  String get activityAutoPauseToggleDescription =>
      'Ierakstīšana automātiski tiek apturēta, kad pārstājat kustēties, un atsākta, tiklīdz atkal sākat kustēties.';

  @override
  String get activityAutoPauseDelayHelperText =>
      'Izvēlieties, cik ilgi bez kustības gaidīt pirms pauzes.';

  @override
  String activityAutoPauseDelayOptionLabel(int seconds) {
    return '$seconds sekundes';
  }

  @override
  String get activityAutoPausedIndicator => 'Automātiski pauzēts';

  @override
  String get audioAnnouncementsAutoPaused => 'Ierakstīšana pauzēta';

  @override
  String get audioAnnouncementsAutoResumed => 'Ierakstīšana atsākta';

  @override
  String get activityHistoryEmpty =>
      'Šajā ierīcē nav saglabātu pabeigtu aktivitāšu.';

  @override
  String get activityHistoryLoadFailed =>
      'Neizdevās ielādēt lokālās aktivitātes.';

  @override
  String get activityHistoryRefresh => 'Atsvaidzināt';

  @override
  String get activityHistoryLocalActivities => 'Lokālās aktivitātes';

  @override
  String activityHistoryEntryTitle(String activityType, String endedAt) {
    return '$activityType • $endedAt';
  }

  @override
  String activityHistoryDuration(String duration) {
    return 'Ilgums: $duration';
  }

  @override
  String activityHistoryDistance(String distance) {
    return 'Attālums: $distance';
  }

  @override
  String activityHistoryUploadStatus(String status) {
    return 'Augšupielāde: $status';
  }

  @override
  String get activityHistoryLoadMore => 'Ielādēt vairāk';

  @override
  String get activityHistoryDetailsTitle => 'Aktivitātes informācija';

  @override
  String get activityHistoryDetailsMissing =>
      'Šī lokālā aktivitāte vairs nav pieejama.';

  @override
  String get activityHistorySummary => 'Kopsavilkums';

  @override
  String get activityHistoryActions => 'Darbības';

  @override
  String get activityHistoryType => 'Veids';

  @override
  String get activityHistoryStartedAt => 'Sākts';

  @override
  String get activityHistoryEndedAt => 'Beidzies';

  @override
  String get activityHistoryDurationLabel => 'Ilgums';

  @override
  String get activityHistoryDistanceLabel => 'Attālums';

  @override
  String get activityHistoryAverageSpeed => 'Vidējais ātrums';

  @override
  String get activityHistoryPointCount => 'GPS punkti';

  @override
  String get activityHistoryUploadStatusLabel => 'Augšupielāde';

  @override
  String get activityHistoryGpxStatus => 'GPX fails';

  @override
  String get activityHistoryGpxAvailable => 'Saglabāts šajā ierīcē';

  @override
  String get activityHistoryGpxMissing => 'Nav pieejams šajā ierīcē';

  @override
  String get mapTab => 'Karte';

  @override
  String get myLocation => 'Mana atrašanās vieta';

  @override
  String get settingsTab => 'Iestatījumi';

  @override
  String get endurainTrademarkNotice =>
      'Endurain® ir João Vitória Silva reģistrēta preču zīme.';

  @override
  String get settingsScreen => 'Iestatījumi';

  @override
  String get deviceAccessTitle => 'Ierīces piekļuve';

  @override
  String get deviceAccessSubtitle =>
      'Pārvaldiet piekļuvi atrašanās vietas un veselības datiem';

  @override
  String get deviceAccessLocationSection => 'Atrašanās vieta';

  @override
  String get deviceAccessHealthSection => 'Veselības dati';

  @override
  String get deviceAccessLocationTitle => 'Piekļuve atrašanās vietai';

  @override
  String get deviceAccessHealthTitle => 'Piekļuve veselības datiem';

  @override
  String get deviceAccessChecking => 'Notiek piekļuves pārbaude…';

  @override
  String get deviceAccessLocationServicesOff =>
      'Atrašanās vietas pakalpojumi ir izslēgti';

  @override
  String get deviceAccessLocationAlways => 'Atļauts visu laiku';

  @override
  String get deviceAccessLocationWhileUsing =>
      'Atļauts lietotnes lietošanas laikā';

  @override
  String get deviceAccessLocationBlocked => 'Bloķēts sistēmas iestatījumos';

  @override
  String get deviceAccessLocationNotAllowed => 'Nav atļauts';

  @override
  String get deviceAccessHealthUnavailable => 'Nav pieejams šajā ierīcē';

  @override
  String get deviceAccessHealthRequired => 'Nepieciešams Health Connect';

  @override
  String get deviceAccessHealthSetUp =>
      'Ir izveidota piekļuve veselības aprūpei';

  @override
  String get deviceAccessHealthNeedsAttention => 'Piekļuvei jāpievērš uzmanība';

  @override
  String get deviceAccessHealthNotConnected => 'Nav savienots';

  @override
  String get language => 'Valoda';

  @override
  String get languageSystemDefault => 'Sistēmas noklusējums';

  @override
  String get serverSettings => 'Serveris';

  @override
  String get signInConnectServer => 'Pieteikties';

  @override
  String get signInConnectServerSubtitle =>
      'Ierakstiet bezsaistē tagad un sinhronizējiet aktivitātes vēlāk';

  @override
  String get serverSettingsTitle => 'Servera iestatījumi';

  @override
  String connectedToServer(String server) {
    return 'Izveidots savienojums ar $server';
  }

  @override
  String get loggedIn => 'Pieteicies';

  @override
  String get notConfigured => 'Nav konfigurēts';

  @override
  String get notLoggedIn => 'Neesat pieteicies';

  @override
  String get serverUrl => 'Servera URL';

  @override
  String get serverProtocol => 'Protokols';

  @override
  String get serverUrlHint => 'https://piemers.com';

  @override
  String get warnHttpServerUrlTitle => 'Nedrošs savienojums';

  @override
  String get warnHttpServerUrlMessage =>
      'Šis servera URL izmanto vienkāršu HTTP. Jūsu pieteikšanās akreditācijas dati un dati tiks pārsūtīti bez šifrēšanas. Turpiniet tikai tad, ja saprotat un pieņemat risku.';

  @override
  String get warnHttpServerUrlConfirm => 'Tomēr turpināt';

  @override
  String get tileServerUrl => 'Kartes elementu servera URL';

  @override
  String get tileServerUrlHint => 'https://tile.openstreetmap.org/...';

  @override
  String get tileServerHostWarningTitle => 'Cits elementu servera resursdators';

  @override
  String get tileServerHostWarningMessage =>
      'Elementu servera resursdators atšķiras no jūsu Endurain servera resursdatora. Elementi tiks ielādēti no trešās puses servera. Vai vēlaties turpināt?';

  @override
  String get savedSuccessfully => 'Iestatījumi veiksmīgi saglabāti';

  @override
  String get diagnostics => 'Diagnostika';

  @override
  String get diagnosticsSubtitle => 'Lokālais avāriju konteksts';

  @override
  String get sourceCode => 'GitHub';

  @override
  String get sourceCodeSubtitle => 'github.com/endurain-project';

  @override
  String get openLinkFailed => 'Neizdevās atvērt saiti';

  @override
  String get diagnosticsTitle => 'Diagnostika';

  @override
  String get diagnosticsCollection => 'Vākšana';

  @override
  String get diagnosticsEnable => 'Vākt diagnostiku';

  @override
  String get diagnosticsEnableSubtitle =>
      'Saglabāt jaunākos lietotnes notikumus un kļūdas šajā ierīcē';

  @override
  String get diagnosticsDisabled =>
      'Diagnostikas vākšana ir izslēgta. Ieslēdziet to, lai sāktu reģistrēt lietotnes notikumus un kļūdas šajā ierīcē.';

  @override
  String get diagnosticsEmpty => 'Vēl nav tverti diagnostikas dati.';

  @override
  String get diagnosticsCopy => 'Kopēt';

  @override
  String get diagnosticsCopied => 'Diagnostika nokopēta';

  @override
  String get diagnosticsClear => 'Notīrīt';

  @override
  String get diagnosticsCleared => 'Diagnostika notīrīta';

  @override
  String get diagnosticsSummary => 'Kopsavilkums';

  @override
  String get diagnosticsLastUpdated => 'Pēdējoreiz atjaunināts';

  @override
  String diagnosticsEventsCount(int count) {
    return 'Notikumi: $count';
  }

  @override
  String diagnosticsErrorsCount(int count) {
    return 'Kļūdas: $count';
  }

  @override
  String get diagnosticsEvents => 'Notikumi';

  @override
  String get diagnosticsNoEvents => 'Nav tvertu notikumu';

  @override
  String diagnosticsEventTitle(String event) {
    return 'Notikums: $event';
  }

  @override
  String get diagnosticsErrors => 'Kļūdas';

  @override
  String diagnosticsErrorTitle(String type) {
    return 'Kļūda: $type';
  }

  @override
  String get diagnosticsActions => 'Darbības';

  @override
  String get diagnosticsRawReport => 'Neapstrādāts pārskats';

  @override
  String get healthSyncSettingsTitle => 'Veselības sinhronizācija';

  @override
  String get healthSyncSettingsSubtitle =>
      'Importējiet treniņus no savas veselības platformas';

  @override
  String get healthSyncScreenTitle => 'Veselības sinhronizācija';

  @override
  String get healthAccessScreenTitle => 'Veselības pieejamība';

  @override
  String get healthAccessRequestedData => 'Pieprasītie dati';

  @override
  String get healthAccessWorkouts => 'Treniņi';

  @override
  String get healthAccessWorkoutRoutes => 'Treniņu maršruti';

  @override
  String get healthAccessHeartRate => 'Sirdsdarbība';

  @override
  String get healthAccessWorkoutSummary =>
      'Treniņa distance, kalorijas un soļi';

  @override
  String get healthAccessAllowed => 'Atļauts';

  @override
  String get healthAccessNeedsAttention => 'Nepieciešama uzmanība';

  @override
  String get healthAccessManagedBySystem => 'Pārvalda sistēmas iestatījumos';

  @override
  String get healthAccessSystemManagedNotice =>
      'HealthKit neatklāj, kādus datus Endurain var nolasīt. Pārskatiet piekļuvi lietotnē Health.';

  @override
  String get healthAccessReview => 'Pārskatiet veselības pieejamību';

  @override
  String get healthAccessReviewIos => 'Kā pārskatīt piekļuvi';

  @override
  String get healthAccessDisconnect => 'Atvienot veselības datus';

  @override
  String get healthAccessDisconnectTitle => 'Atvienot veselības datus?';

  @override
  String get healthAccessDisconnectMessage =>
      'Šī servera automātiskā importēšana un lokālā importēšanas vēsture tiks atiestatīta. Esošās aktivitātes paliks vēsturē.';

  @override
  String get healthAccessReviewIosInstructions =>
      'Atveriet lietotni Health, pieskarieties savam profila attēlam un pēc tam: Programmas un pakalpojumi. Atlasiet Endurain un atjauniniet datu kategorijas.';

  @override
  String get healthSyncAuthorize =>
      'Izveidojiet savienojumu ar veselības datiem';

  @override
  String get healthSyncInstallProvider => 'Instalējiet Health Connect';

  @override
  String get healthSyncInstallProviderDescription =>
      'Lai sinhronizētu treniņus, ir nepieciešams Health Connect. Instalējiet to, lai turpinātu.';

  @override
  String get healthSyncUnsupported =>
      'Veselības sinhronizācija šajā ierīcē nav pieejama.';

  @override
  String get healthSyncSelectAll => 'Atlasiet visu';

  @override
  String get healthSyncClearSelection => 'Skaidrs';

  @override
  String healthSyncImportSelected(int count) {
    return 'Importēt atlasīto ($count)';
  }

  @override
  String healthSyncImportedCount(int count) {
    return 'Importēts(-i) $count treniņš(-i).';
  }

  @override
  String get healthSyncNoRouteLabel => 'Nav GPS maršruta';

  @override
  String get healthSyncEmptyState =>
      'Atlasītajā periodā nav atrasts neviens treniņš.';

  @override
  String get healthSyncRouteConsentGuidance =>
      'Daži treniņi tika izlaisti, jo netika piešķirta piekļuve vingrinājumu maršrutam. Atveriet Health Connect → Atļaujas un atļaujiet Endurain vingrojumu maršrutus.';

  @override
  String get healthSyncRouteConsentGuidanceIos =>
      'Daži treniņi tika izlaisti, jo Endurain nevarēja nolasīt savus GPS maršrutus. Lietotnē Health atveriet savu profilu, pēc tam Programmas un pakalpojumi, atlasiet Endurain un atļaujiet Workout Routes.';

  @override
  String get healthSyncReviewAccess => 'Pārskatiet piekļuvi';

  @override
  String get healthSyncAutoSyncTitle => 'Automātiskā sinhronizācija, atsākot';

  @override
  String get healthSyncAutoSyncSubtitle =>
      'Kad lietotne tiek atvērta, automātiski importējiet jaunus treniņus.';

  @override
  String get healthSyncNoRoutesExplanation =>
      'Šajos treniņos nav iekļauts GPS maršruts, tāpēc tos nevar importēt. Dažas lietotnes (piemēram, Garmin Connect) ieraksta darbības pakalpojumā Apple Health, nekoplietojot maršrutu. Ar Apple Watch ierakstītajos treniņos ir iekļauti maršruti, un tos var importēt.';

  @override
  String get healthSyncBadgeNonImportable => 'Neimportējams';

  @override
  String get healthSyncViewAvailable => 'Pieejami';

  @override
  String get healthSyncViewImported => 'Importēti';

  @override
  String get healthSyncDateRange => 'Treniņu periods';

  @override
  String get healthSyncRange30Days => 'Pēdējās 30 dienas';

  @override
  String get healthSyncRange3Months => 'Pēdējie 3 mēneši';

  @override
  String get healthSyncRange6Months => 'Pēdējie 6 mēneši';

  @override
  String get healthSyncRangeYear => 'Pēdējais gads';

  @override
  String get healthSyncRangeAll => 'Visa vēsture';

  @override
  String get healthSyncRangeCustom => 'Pielāgots periods';

  @override
  String get healthSyncImportedEmpty =>
      'Šim savienojumam nav importētu treniņu.';

  @override
  String healthSyncImportedAt(String dateTime) {
    return 'Importēts: $dateTime';
  }

  @override
  String get healthSyncRestore => 'Atjaunot';

  @override
  String get sensorsTitle => 'Sensori';

  @override
  String get sensorsSettingsSubtitle => 'Pulsa mērītāji un citi ārējie sensori';

  @override
  String get sensorsHeartRateSection => 'Pulss';

  @override
  String get sensorsHeartRateHelp =>
      'Savienojiet pārī Bluetooth pulsa mērītāju, lai reāllaikā redzētu savu pulsu.';

  @override
  String get sensorsBluetoothOff =>
      'Bluetooth ir izslēgts. Ieslēdziet to, lai savienotu sensoru.';

  @override
  String get sensorsBluetoothUnauthorized =>
      'Atļaujiet piekļuvi Bluetooth, lai savienotu sensoru.';

  @override
  String get sensorsBluetoothUnsupported =>
      'Šī ierīce neatbalsta Bluetooth Low Energy.';

  @override
  String get sensorsScan => 'Meklēt sensorus';

  @override
  String get sensorsScanning => 'Meklē…';

  @override
  String get sensorsStopScan => 'Apturēt';

  @override
  String get sensorsNoDevices => 'Pulsa sensori vēl nav atrasti.';

  @override
  String get sensorsAvailableSection => 'Pieejamie sensori';

  @override
  String get sensorsSavedSection => 'Saglabātais sensors';

  @override
  String get sensorsConnect => 'Savienot';

  @override
  String get sensorsConnecting => 'Savieno…';

  @override
  String get sensorsConnected => 'Savienots';

  @override
  String get sensorsDisconnect => 'Atvienot';

  @override
  String get sensorsForget => 'Aizmirst';

  @override
  String get sensorsConnectionFailed => 'Neizdevās savienot. Mēģiniet vēlreiz.';

  @override
  String get sensorsPermissionRequired =>
      'Lai atrastu sensorus, nepieciešama Bluetooth atļauja.';

  @override
  String get sensorsUnknownDevice => 'Nezināms sensors';

  @override
  String sensorsBpm(String bpm) {
    return '$bpm bpm';
  }

  @override
  String get sensorsPowerSection => 'Jauda';

  @override
  String get sensorsPowerHelp =>
      'Savienojiet pārī Bluetooth jaudas mērītāju, lai reāllaikā redzētu savu jaudu.';

  @override
  String get sensorsNoPowerDevices => 'Jaudas mērītāji vēl nav atrasti.';

  @override
  String sensorsWatts(String watts) {
    return '$watts W';
  }

  @override
  String get sensorsCadenceSection => 'Kadence';

  @override
  String get sensorsCadenceHelp =>
      'Savienojiet pārī Bluetooth kadences sensoru, lai reāllaikā redzētu savu kadenci.';

  @override
  String get sensorsNoCadenceDevices => 'Kadences sensori vēl nav atrasti.';

  @override
  String sensorsRpm(String rpm) {
    return '$rpm rpm';
  }

  @override
  String get diagnosticsRemoteTitle => 'Attālināta avāriju ziņošana';

  @override
  String get diagnosticsRemoteEnable => 'Sūtīt avāriju ziņojumus';

  @override
  String get diagnosticsRemoteEnableSubtitle =>
      'Sūtiet avāriju un kļūdu ziņojumus uz diagnostikas serveri. Tas ir neatkarīgs no vietējās diagnostikas; varat iespējot abus, vienu vai nevienu.';

  @override
  String get diagnosticsRemoteActive => 'Crash reports are being sent.';

  @override
  String get diagnosticsRemoteNeedsServer =>
      'Attālināta avāriju ziņošana šajā versijā nav pieejama.';

  @override
  String unitMeter(String value) {
    return '$value m';
  }

  @override
  String unitKilometer(String value) {
    return '$value km';
  }

  @override
  String unitFoot(String value) {
    return '$value ft';
  }

  @override
  String unitMile(String value) {
    return '$value mi';
  }

  @override
  String unitKilometersPerHour(String value) {
    return '$value km/h';
  }

  @override
  String unitMilesPerHour(String value) {
    return '$value mph';
  }

  @override
  String unitMinutesPerKilometer(String value) {
    return '$value min/km';
  }

  @override
  String unitMinutesPerMile(String value) {
    return '$value min/mi';
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
  String get unitsTitle => 'Mērvienības';

  @override
  String get unitsSubtitle => 'Attāluma, ātruma un augstuma mērvienības';

  @override
  String get unitsSystemDefault => 'Sekot ierīces reģionam';

  @override
  String get unitsMetric => 'Metriskā (km)';

  @override
  String get unitsImperial => 'Imperiālā (mi)';

  @override
  String get errorInsecureRedirectRejected =>
      'The server tried to redirect to an insecure connection. The request was blocked to protect your credentials.';

  @override
  String get errorTooManyRedirects =>
      'The server redirected too many times. Check the server address.';

  @override
  String get audioAnnouncementsTitle => 'Balss paziņojumi';

  @override
  String get audioAnnouncementsSubtitle =>
      'Balss atjauninājumi par attālumu, laiku, tempu vai ātrumu';

  @override
  String get audioAnnouncementsMasterSwitch => 'Paziņot aktivitātes progresu';

  @override
  String get audioAnnouncementsMasterSwitchSubtitle =>
      'Ieraksta laikā balsī paziņo attālumu, laiku, tempu vai ātrumu';

  @override
  String get audioAnnouncementsDuckSwitch =>
      'Klusināt citu skaņu runāšanas laikā';

  @override
  String get audioAnnouncementsDuckSwitchSubtitle =>
      'Īslaicīgi samazina citas skaņas skaļumu katra paziņojuma laikā';

  @override
  String get audioAnnouncementsIntervalsHeader =>
      'Paziņojuma intervāls pēc aktivitātes';

  @override
  String get audioAnnouncementsByDistance => 'Attālums';

  @override
  String get audioAnnouncementsByTime => 'Laiks';

  @override
  String audioAnnouncementsIntervalDistance(String value, String unit) {
    return 'Ik pēc $value $unit';
  }

  @override
  String audioAnnouncementsIntervalTime(String minutes) {
    return 'Ik pēc $minutes min';
  }

  @override
  String get audioAnnouncementsDecreaseInterval => 'Samazināt intervālu';

  @override
  String get audioAnnouncementsIncreaseInterval => 'Palielināt intervālu';

  @override
  String get audioAnnouncementsPreview => 'Klausīties paraugu';

  @override
  String get audioAnnouncementsPreviewUnavailable =>
      'Paziņojuma paraugs šajā ierīcē nav pieejams';

  @override
  String get audioAnnouncementsAppliesNextRecording =>
      'Izmaiņas tiks piemērotas nākamajā ierakstā.';

  @override
  String audioAnnouncementsSpokenMessage(
    String distance,
    String duration,
    String lapMetric,
    String overallMetric,
  ) {
    return 'Attālums $distance. Laiks $duration. Aplis: $lapMetric. Kopā: $overallMetric.';
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

  @override
  String get updatesTitle => 'App updates';

  @override
  String get updatesSubtitle => 'Check GitHub for Stable or Nightly builds';

  @override
  String updatesInstalled(String version, String channel) {
    return 'Installed: $version ($channel)';
  }

  @override
  String get updatesCheck => 'Check for updates';

  @override
  String updatesLastChecked(String date) {
    return 'Last successful check: $date';
  }

  @override
  String get updatesNightlyDescription =>
      'Latest verified builds. May contain unfinished changes.';

  @override
  String get updatesUnsupported => 'APK updates are available on Android only.';

  @override
  String get updatesCurrent => 'You are up to date.';

  @override
  String get updatesWaitingStable =>
      'Waiting for the next Stable build newer than your installed version.';

  @override
  String get updatesDownload => 'Download';

  @override
  String get updatesInstall => 'Install';

  @override
  String get updatesPermission =>
      'Allow this app to install updates in Android settings, then tap Install again.';

  @override
  String get updatesInstallerOpened =>
      'Installer opened. Installation is confirmed only after the installed version changes.';

  @override
  String get updatesRecordingActive =>
      'Finish your activity recording before installing an update.';

  @override
  String get errorUpdateInvalid =>
      'The release metadata is invalid or does not match the APK.';

  @override
  String get errorUpdateIncompatible =>
      'This build does not support your Android version or device architecture.';

  @override
  String get errorUpdateNetwork =>
      'Could not contact GitHub. Please try again.';

  @override
  String get errorUpdateRateLimited =>
      'GitHub is limiting requests. Please try again later.';

  @override
  String get errorUpdateUnavailable =>
      'This channel is temporarily unavailable or has no published build. Please try again later.';

  @override
  String get errorUpdateIntegrity =>
      'The download is incomplete or its checksum does not match. Please download it again.';

  @override
  String get errorUpdateInstallFailed =>
      'Android could not open this update. Check the installation permission and try again.';

  @override
  String get errorUpdateStorage =>
      'Could not save update files or settings. Check available storage and try again.';

  @override
  String get updatesLocalChannel => 'Local build';

  @override
  String get updatesCheckChannel => 'Verification build';
}
