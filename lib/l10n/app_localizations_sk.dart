// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get error => 'Chyba';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get save => 'Uložiť';

  @override
  String get back => 'Späť';

  @override
  String get requiredField => 'Toto pole je povinné';

  @override
  String get invalidUrl => 'Zadajte platnú adresu URL';

  @override
  String get errorActivityUploadFailed => 'Aktivitu sa nepodarilo nahrať';

  @override
  String errorActivityUploadFailedWithDetails(String details) {
    return 'Aktivitu sa nepodarilo nahrať: $details';
  }

  @override
  String get errorActivityUploadNotConfigured =>
      'Nahrávanie aktivít ešte nie je nastavené';

  @override
  String get errorActivityGpxCleanupFailed =>
      'Dočasný súbor aktivity sa nepodarilo odstrániť';

  @override
  String get errorActivityGpxFileWriteFailed =>
      'Súbor na nahranie aktivity sa nepodarilo pripraviť';

  @override
  String get errorActivityLocalActivityNotFound =>
      'Túto miestnu aktivitu sa nepodarilo nájsť';

  @override
  String get errorActivityLocalDeleteFailed =>
      'Miestnu aktivitu sa nepodarilo odstrániť';

  @override
  String get errorActivityLocalGpxMissing =>
      'Miestny súbor GPX nie je k dispozícii';

  @override
  String get errorActivityLocalLoadFailed =>
      'Miestne aktivity sa nepodarilo načítať';

  @override
  String get errorActivityLocalRecordInvalid =>
      'Túto aktivitu sa nepodarilo uložiť';

  @override
  String get errorActivityLocalSaveFailed =>
      'Aktivitu sa nepodarilo uložiť miestne';

  @override
  String get errorFetchProvidersFailed =>
      'Poskytovateľov prihlásenia sa nepodarilo načítať';

  @override
  String errorFetchProvidersFailedWithDetails(String details) {
    return 'Poskytovateľov prihlásenia sa nepodarilo načítať: $details';
  }

  @override
  String get errorFetchServerSettingsFailed =>
      'Nastavenia servera sa nepodarilo načítať';

  @override
  String errorFetchServerSettingsFailedWithDetails(String details) {
    return 'Nastavenia servera sa nepodarilo načítať: $details';
  }

  @override
  String get errorHealthGpxBuildFailed =>
      'Cvičenie sa nepodarilo previesť na GPX';

  @override
  String get errorHealthImportFailed => 'Cvičenie sa nepodarilo importovať';

  @override
  String errorHealthImportFailedWithDetails(String details) {
    return 'Nepodarilo sa importovať cvičenie: $details';
  }

  @override
  String get errorHealthPermissionDenied =>
      'Prístup k zdravotným údajom bol odmietnutý';

  @override
  String get errorHealthReadFailed => 'Nepodarilo sa prečítať zdravotné údaje';

  @override
  String get errorLoginError => 'Nepodarilo sa prihlásiť';

  @override
  String errorLoginErrorWithDetails(String details) {
    return 'Nepodarilo sa prihlásiť: $details';
  }

  @override
  String get errorLoginFailed => 'Prihlásenie zlyhalo';

  @override
  String errorLoginFailedWithDetails(String details) {
    return 'Prihlásenie zlyhalo: $details';
  }

  @override
  String get errorMfaVerificationError => 'Kód MFA sa nepodarilo overiť';

  @override
  String errorMfaVerificationErrorWithDetails(String details) {
    return 'Kód MFA sa nepodarilo overiť: $details';
  }

  @override
  String get errorMfaVerificationFailed => 'Overenie MFA zlyhalo';

  @override
  String errorMfaVerificationFailedWithDetails(String details) {
    return 'Overenie MFA zlyhalo: $details';
  }

  @override
  String get errorNoSessionIdReceived =>
      'Zo servera nebolo prijaté žiadne ID relácie';

  @override
  String get errorNotAuthenticated => 'Nie ste prihlásení';

  @override
  String get errorPkceVerifierMissingRestartLogin =>
      'Overovateľ prihlásenia sa nenašiel. Začnite prihlásenie znova.';

  @override
  String get errorServerUrlNotConfigured =>
      'Adresa URL servera nie je nastavená';

  @override
  String get errorInsecureTransportNotAllowed =>
      'Tento server vyžaduje zabezpečené pripojenie (HTTPS)';

  @override
  String get errorSessionExpired =>
      'Platnosť vašej relácie vypršala. Prihláste sa znova.';

  @override
  String get errorSsoTokenExchangeError =>
      'Prihlásenie cez SSO sa nepodarilo dokončiť';

  @override
  String errorSsoTokenExchangeErrorWithDetails(String details) {
    return 'Prihlásenie cez SSO sa nepodarilo dokončiť: $details';
  }

  @override
  String get errorTokenExchangeFailed => 'Výmena tokenov zlyhala';

  @override
  String errorTokenExchangeFailedWithDetails(String details) {
    return 'Výmena tokenov zlyhala: $details';
  }

  @override
  String get errorRequestTimeout =>
      'Vypršal časový limit požiadavky. Skontrolujte pripojenie a skúste to znova.';

  @override
  String get errorSecureStorageDeleteFailed =>
      'Zo zabezpečeného úložiska nie je možné odstrániť. Úložisko zariadenia nemusí byť dostupné.';

  @override
  String get errorSecureStorageReadFailed =>
      'Zo zabezpečeného úložiska nie je možné čítať. Úložisko zariadenia nemusí byť dostupné.';

  @override
  String get errorSecureStorageWriteFailed =>
      'Do zabezpečeného úložiska nie je možné zapisovať. Úložisko zariadenia nemusí byť dostupné.';

  @override
  String get errorUnexpectedResponseFormat =>
      'Server vrátil neočakávanú odpoveď';

  @override
  String get errorUnsupportedHttpMethod => 'Nepodporovaná metóda HTTP';

  @override
  String errorUnsupportedHttpMethodWithDetails(String details) {
    return 'Nepodporovaná metóda HTTP: $details';
  }

  @override
  String get loginTitle => 'Prihlásenie';

  @override
  String get login => 'Prihlásiť sa';

  @override
  String get logout => 'Odhlásiť sa';

  @override
  String get logoutConfirmTitle => 'Odhlásiť sa';

  @override
  String get logoutConfirmMessage => 'Naozaj sa chcete odhlásiť?';

  @override
  String get logoutServerFailedWarning =>
      'Odhlásenie zo servera zlyhalo, ale odhlásenie prebehlo miestne';

  @override
  String get ssoBrowserLaunchFailed =>
      'Prihlásenie cez SSO sa nepodarilo otvoriť v systémovom prehliadači';

  @override
  String ssoSignInWith(String provider) {
    return 'Prihlásiť sa cez $provider';
  }

  @override
  String get ssoOrDivider => 'ALEBO';

  @override
  String get next => 'Ďalej';

  @override
  String get username => 'Používateľské meno';

  @override
  String get usernameHint => 'Zadajte svoje používateľské meno';

  @override
  String get password => 'Heslo';

  @override
  String get passwordHint => 'Zadajte svoje heslo';

  @override
  String get showPassword => 'Zobraziť heslo';

  @override
  String get mfaTitle => 'Dvojfaktorové overenie';

  @override
  String get mfaCode => 'Kód MFA';

  @override
  String get mfaCodeHint => 'Zadajte 6-miestny kód';

  @override
  String get mfaCodeRequired => 'Zadajte kód MFA';

  @override
  String get verify => 'Overiť';

  @override
  String get activityDiscard => 'Zahodiť';

  @override
  String get activityDiscardConfirmMessage =>
      'Týmto sa odstránia zaznamenané body tejto aktivity.';

  @override
  String get activityDiscardConfirmTitle => 'Zahodiť aktivitu?';

  @override
  String get activityLocationPermissionDenied =>
      'Na zaznamenanie aktivity sa vyžaduje povolenie polohy.';

  @override
  String get activityLocationPermissionDeniedForever =>
      'Povolenie polohy je zablokované. Otvorte nastavenia a povoľte prístup k polohe.';

  @override
  String get activityLocationServiceDisabled =>
      'Služby určovania polohy sú vypnuté.';

  @override
  String get activityLocationStreamFailed =>
      'Aktualizácie polohy sa neočakávane zastavili.';

  @override
  String get activityGpxGenerationFailed =>
      'Súbor GPX aktivity sa nepodarilo vytvoriť.';

  @override
  String get activityLocalSaveFailed =>
      'Túto aktivitu sa nepodarilo uložiť do tohto zariadenia.';

  @override
  String get activityOpenSettings => 'Otvoriť nastavenia';

  @override
  String get activityPause => 'Pozastaviť';

  @override
  String get activityRecordingEmpty => 'Nezaznamenali sa žiadne body GPS.';

  @override
  String get activityRecordingFailed => 'Záznam zlyhal.';

  @override
  String get activityResume => 'Pokračovať';

  @override
  String get activityRetryUpload => 'Skúsiť nahrať znova';

  @override
  String get activityDone => 'Hotovo';

  @override
  String get activityViewHistory => 'Zobraziť históriu';

  @override
  String get activityDeleteLocal => 'Odstrániť miestnu kópiu';

  @override
  String get activityExportGpx => 'Zdieľať súbor GPX';

  @override
  String get activityExportGpxSubject => 'GPX aktivity Endurain';

  @override
  String get activityDeleteLocalConfirmTitle => 'Odstrániť miestnu aktivitu?';

  @override
  String get activityDeleteLocalConfirmMessage =>
      'Týmto sa z tohto zariadenia odstráni záznam miestnej aktivity a súbor GPX.';

  @override
  String get activityStart => 'Spustiť';

  @override
  String get activityBackgroundPermissionTitle =>
      'Povoliť sledovanie na pozadí?';

  @override
  String get activityBackgroundPermissionMessage =>
      'Endurain vyžaduje polohu na pozadí nastavenú na Vždy, aby záznam pokračoval, keď je aplikácia na pozadí, obrazovka je uzamknutá alebo prepnete aplikáciu.';

  @override
  String get activityBackgroundPermissionContinue => 'Pokračovať';

  @override
  String get activityBackgroundPermissionRequired =>
      'Sledovanie na pozadí na iPhone a iPad vyžaduje polohu nastavenú na Vždy.';

  @override
  String get activityBackgroundPermissionSettingsTitle =>
      'Sledovanie na pozadí je vypnuté';

  @override
  String get activityBackgroundPermissionSettingsMessage =>
      'Ak chcete spoľahlivo zaznamenávať na pozadí alebo pri uzamknutej obrazovke, otvorte Nastavenia a nastavte Polohu na Vždy pre Endurain.';

  @override
  String get activityTrackingNotificationTitle => 'Zaznamenávanie aktivity';

  @override
  String get activityTrackingNotificationText =>
      'Endurain sleduje vašu polohu, aby zaznamenal túto aktivitu.';

  @override
  String get activityStatDistance => 'Vzdialenosť';

  @override
  String get activityStatDuration => 'Čas';

  @override
  String get activityStatSpeed => 'Rýchlosť';

  @override
  String get activityStatPace => 'Tempo';

  @override
  String get activityStatMaxSpeed => 'Najvyššia rýchlosť';

  @override
  String get activityStatElevationGain => 'Prevýšenie';

  @override
  String get activityStatHeartRate => 'Tep';

  @override
  String get activityStatAvgHeartRate => 'Priem. tep';

  @override
  String get activityStatPower => 'Výkon';

  @override
  String get activityStatAvgPower => 'Priem. výkon';

  @override
  String get activityStatCadence => 'Kadencia';

  @override
  String get activityStatAvgCadence => 'Priem. kadencia';

  @override
  String get activityStop => 'Zastaviť';

  @override
  String get activityStopAndSave => 'Zastaviť a uložiť';

  @override
  String get activityStopConfirmMessage =>
      'Vyberte, či chcete tento záznam ponechať, alebo zahodiť.';

  @override
  String get activityStopConfirmTitle => 'Ukončiť aktivitu?';

  @override
  String get activityStopping => 'Zastavovanie';

  @override
  String get activityTypeHike => 'Turistika';

  @override
  String get activityTypeLabel => 'Typ aktivity';

  @override
  String get activityTypeOther => 'Iné';

  @override
  String get activityTypeRide => 'Cyklistika';

  @override
  String get activityTypeRun => 'Beh';

  @override
  String get activityTypeWalk => 'Chôdza';

  @override
  String get activityUploadFailed => 'Nahrávanie zlyhalo';

  @override
  String get activityUploadCleanupFailed => 'Nahraté, ale čistenie zlyhalo';

  @override
  String get activityUploadReady => 'Pripravené na nahranie';

  @override
  String get activityUploaded => 'Nahraté';

  @override
  String get activityUploading => 'Nahrávanie';

  @override
  String get activityUploadStatusPending => 'Čaká';

  @override
  String get activityUploadStatusUploaded => 'Nahraté';

  @override
  String get activityUploadStatusFailed => 'Zlyhalo';

  @override
  String get activityHistoryTitle => 'História aktivít';

  @override
  String get activityHistorySettingsSubtitle =>
      'Dokončené aktivity uložené v tomto zariadení';

  @override
  String get activityRetainUploadedGpx => 'Ponechať nahraté súbory GPX';

  @override
  String get activityRetainUploadedGpxSubtitle =>
      'Po nahraní ukladá dokončené súbory trás do súkromného úložiska aplikácie.';

  @override
  String get activityHistoryEmpty =>
      'V tomto zariadení nie sú uložené žiadne dokončené aktivity.';

  @override
  String get activityHistoryLoadFailed =>
      'Miestne aktivity sa nepodarilo načítať.';

  @override
  String get activityHistoryRefresh => 'Obnoviť';

  @override
  String get activityHistoryLocalActivities => 'Miestne aktivity';

  @override
  String activityHistoryEntryTitle(String activityType, String endedAt) {
    return '$activityType • $endedAt';
  }

  @override
  String activityHistoryDuration(String duration) {
    return 'Trvanie: $duration';
  }

  @override
  String activityHistoryDistance(String distance) {
    return 'Vzdialenosť: $distance';
  }

  @override
  String activityHistoryUploadStatus(String status) {
    return 'Nahranie: $status';
  }

  @override
  String get activityHistoryLoadMore => 'Načítať viac';

  @override
  String get activityHistoryDetailsTitle => 'Podrobnosti aktivity';

  @override
  String get activityHistoryDetailsMissing =>
      'Táto miestna aktivita už nie je k dispozícii.';

  @override
  String get activityHistorySummary => 'Súhrn';

  @override
  String get activityHistoryActions => 'Akcie';

  @override
  String get activityHistoryType => 'Typ';

  @override
  String get activityHistoryStartedAt => 'Začaté';

  @override
  String get activityHistoryEndedAt => 'Ukončené';

  @override
  String get activityHistoryDurationLabel => 'Trvanie';

  @override
  String get activityHistoryDistanceLabel => 'Vzdialenosť';

  @override
  String get activityHistoryAverageSpeed => 'Priemerná rýchlosť';

  @override
  String get activityHistoryPointCount => 'Body GPS';

  @override
  String get activityHistoryUploadStatusLabel => 'Nahranie';

  @override
  String get activityHistoryGpxStatus => 'Súbor GPX';

  @override
  String get activityHistoryGpxAvailable => 'Uložené v tomto zariadení';

  @override
  String get activityHistoryGpxMissing =>
      'Nie je k dispozícii v tomto zariadení';

  @override
  String get mapTab => 'Mapa';

  @override
  String get myLocation => 'Moja poloha';

  @override
  String get settingsTab => 'Nastavenia';

  @override
  String get endurainTrademarkNotice =>
      'Endurain® je registrovaná ochranná známka João Vitória Silva';

  @override
  String get settingsScreen => 'Nastavenia';

  @override
  String get deviceAccessTitle => 'Prístup k zariadeniu';

  @override
  String get deviceAccessSubtitle =>
      'Spravujte prístup k údajom o polohe a zdraví';

  @override
  String get deviceAccessLocationSection => 'Poloha';

  @override
  String get deviceAccessHealthSection => 'Zdravotné údaje';

  @override
  String get deviceAccessLocationTitle => 'Prístup k polohe';

  @override
  String get deviceAccessHealthTitle => 'Prístup k zdravotným údajom';

  @override
  String get deviceAccessChecking => 'Kontroluje sa prístup…';

  @override
  String get deviceAccessLocationServicesOff => 'Lokalizačné služby sú vypnuté';

  @override
  String get deviceAccessLocationAlways => 'Povolené po celú dobu';

  @override
  String get deviceAccessLocationWhileUsing =>
      'Povolené pri používaní aplikácie';

  @override
  String get deviceAccessLocationBlocked =>
      'Blokované v systémových nastaveniach';

  @override
  String get deviceAccessLocationNotAllowed => 'Nie je povolené';

  @override
  String get deviceAccessHealthUnavailable =>
      'Nie je k dispozícii na tomto zariadení';

  @override
  String get deviceAccessHealthRequired => 'Vyžaduje sa Health Connect';

  @override
  String get deviceAccessHealthSetUp => 'Zdravotný prístup nastavený';

  @override
  String get deviceAccessHealthNeedsAttention =>
      'Prístup si vyžaduje pozornosť';

  @override
  String get deviceAccessHealthNotConnected => 'Nepripojené';

  @override
  String get language => 'Jazyk';

  @override
  String get languageSystemDefault => 'Predvolené podľa systému';

  @override
  String get serverSettings => 'Server';

  @override
  String get signInConnectServer => 'Prihlásiť sa';

  @override
  String get signInConnectServerSubtitle =>
      'Zaznamenávajte offline teraz a aktivity synchronizujte neskôr';

  @override
  String get serverSettingsTitle => 'Nastavenia servera';

  @override
  String connectedToServer(String server) {
    return 'Pripojené k $server';
  }

  @override
  String get loggedIn => 'Prihlásené';

  @override
  String get notConfigured => 'Nenastavené';

  @override
  String get notLoggedIn => 'Neprihlásené';

  @override
  String get serverUrl => 'Adresa URL servera';

  @override
  String get serverProtocol => 'Protokol';

  @override
  String get serverUrlHint => 'https://priklad.com';

  @override
  String get warnHttpServerUrlTitle => 'Nezabezpečené pripojenie';

  @override
  String get warnHttpServerUrlMessage =>
      'Táto adresa URL servera používa nešifrované HTTP. Vaše prihlasovacie údaje a údaje budú prenášané bez šifrovania. Pokračujte iba vtedy, ak rozumiete riziku a prijímate ho.';

  @override
  String get warnHttpServerUrlConfirm => 'Napriek tomu pokračovať';

  @override
  String get tileServerUrl => 'Adresa URL servera mapových dlaždíc';

  @override
  String get tileServerUrlHint => 'https://tile.openstreetmap.org/...';

  @override
  String get tileServerHostWarningTitle => 'Iný hostiteľ servera dlaždíc';

  @override
  String get tileServerHostWarningMessage =>
      'Hostiteľ servera dlaždíc sa líši od hostiteľa vášho servera Endurain. Dlaždice sa načítajú zo servera tretej strany. Chcete pokračovať?';

  @override
  String get savedSuccessfully => 'Nastavenia boli úspešne uložené';

  @override
  String get diagnostics => 'Diagnostika';

  @override
  String get diagnosticsSubtitle => 'Miestny kontext pádov';

  @override
  String get sourceCode => 'GitHub';

  @override
  String get sourceCodeSubtitle => 'github.com/endurain-project';

  @override
  String get openLinkFailed => 'Odkaz sa nepodarilo otvoriť';

  @override
  String get diagnosticsTitle => 'Diagnostika';

  @override
  String get diagnosticsCollection => 'Zhromažďovanie';

  @override
  String get diagnosticsEnable => 'Zhromažďovať diagnostiku';

  @override
  String get diagnosticsEnableSubtitle =>
      'Ukladať nedávne udalosti a chyby aplikácie v tomto zariadení';

  @override
  String get diagnosticsDisabled =>
      'Zhromažďovanie diagnostiky je vypnuté. Zapnite ho, ak chcete začať zaznamenávať udalosti a chyby aplikácie v tomto zariadení.';

  @override
  String get diagnosticsEmpty =>
      'Zatiaľ neboli zachytené žiadne diagnostické údaje.';

  @override
  String get diagnosticsCopy => 'Kopírovať';

  @override
  String get diagnosticsCopied => 'Diagnostika skopírovaná';

  @override
  String get diagnosticsClear => 'Vymazať';

  @override
  String get diagnosticsCleared => 'Diagnostika vymazaná';

  @override
  String get diagnosticsSummary => 'Súhrn';

  @override
  String get diagnosticsLastUpdated => 'Naposledy aktualizované';

  @override
  String diagnosticsEventsCount(int count) {
    return 'Udalosti: $count';
  }

  @override
  String diagnosticsErrorsCount(int count) {
    return 'Chyby: $count';
  }

  @override
  String get diagnosticsEvents => 'Udalosti';

  @override
  String get diagnosticsNoEvents => 'Nezachytené žiadne udalosti';

  @override
  String diagnosticsEventTitle(String event) {
    return 'Udalosť: $event';
  }

  @override
  String get diagnosticsErrors => 'Chyby';

  @override
  String diagnosticsErrorTitle(String type) {
    return 'Chyba: $type';
  }

  @override
  String get diagnosticsActions => 'Akcie';

  @override
  String get diagnosticsRawReport => 'Nespracovaná správa';

  @override
  String get healthSyncSettingsTitle => 'Synchronizácia zdravia';

  @override
  String get healthSyncSettingsSubtitle =>
      'Importujte tréningy z vašej zdravotnej platformy';

  @override
  String get healthSyncScreenTitle => 'Synchronizácia zdravia';

  @override
  String get healthAccessScreenTitle => 'Zdravotný prístup';

  @override
  String get healthAccessRequestedData => 'Požadované údaje';

  @override
  String get healthAccessWorkouts => 'Tréningy';

  @override
  String get healthAccessWorkoutRoutes => 'Tréningové trasy';

  @override
  String get healthAccessHeartRate => 'Srdcová frekvencia';

  @override
  String get healthAccessWorkoutSummary =>
      'Vzdialenosť, kalórie a kroky tréningu';

  @override
  String get healthAccessAllowed => 'Povolené';

  @override
  String get healthAccessNeedsAttention => 'Vyžaduje pozornosť';

  @override
  String get healthAccessManagedBySystem =>
      'Spravované v systémových nastaveniach';

  @override
  String get healthAccessSystemManagedNotice =>
      'HealthKit nezverejňuje, ktoré údaje dokáže Endurain čítať. Skontrolujte prístup v aplikácii Zdravie.';

  @override
  String get healthAccessReview => 'Skontrolujte zdravotný prístup';

  @override
  String get healthAccessReviewIos => 'Ako skontrolovať prístup';

  @override
  String get healthAccessDisconnect => 'Odpojiť zdravotné údaje';

  @override
  String get healthAccessDisconnectTitle => 'Odpojiť zdravotné údaje?';

  @override
  String get healthAccessDisconnectMessage =>
      'Automatický import a miestna história importov pre tento server sa obnovia. Existujúce aktivity zostanú v histórii.';

  @override
  String get healthAccessReviewIosInstructions =>
      'Otvorte aplikáciu Zdravie, klepnite na svoj profilový obrázok a potom na položku Aplikácie a služby. Vyberte Endurain a aktualizujte kategórie údajov.';

  @override
  String get healthSyncAuthorize => 'Pripojte sa k zdravotným údajom';

  @override
  String get healthSyncInstallProvider => 'Nainštalujte Health Connect';

  @override
  String get healthSyncInstallProviderDescription =>
      'Na synchronizáciu tréningov sa vyžaduje Health Connect. Ak chcete pokračovať, nainštalujte ho.';

  @override
  String get healthSyncUnsupported =>
      'Synchronizácia stavu nie je na tomto zariadení k dispozícii.';

  @override
  String get healthSyncSelectAll => 'Vybrať všetko';

  @override
  String get healthSyncClearSelection => 'Jasné';

  @override
  String healthSyncImportSelected(int count) {
    return 'Importovať vybraté ($count)';
  }

  @override
  String healthSyncImportedCount(int count) {
    return 'Počet importovaných cvičení: $count.';
  }

  @override
  String get healthSyncNoRouteLabel => 'Žiadna trasa GPS';

  @override
  String get healthSyncEmptyState =>
      'Vo vybranom období sa nenašli žiadne tréningy.';

  @override
  String get healthSyncRouteConsentGuidance =>
      'Niektoré tréningy boli vynechané, pretože nebol povolený prístup k cvičebnej trase. Otvorte Health Connect → Povolenia a povoľte trasy cvičenia pre Endurain.';

  @override
  String get healthSyncRouteConsentGuidanceIos =>
      'Niektoré tréningy boli vynechané, pretože Endurain nedokázal prečítať ich GPS trasy. V aplikácii Zdravie otvorte svoj profil, potom Aplikácie a služby, vyberte Endurain a povoľte trasy cvičenia.';

  @override
  String get healthSyncReviewAccess => 'Kontrola prístupu';

  @override
  String get healthSyncAutoSyncTitle =>
      'Automatická synchronizácia pri obnovení';

  @override
  String get healthSyncAutoSyncSubtitle =>
      'Importujte nové tréningy automaticky po otvorení aplikácie.';

  @override
  String get healthSyncNoRoutesExplanation =>
      'Tieto tréningy neobsahujú trasu GPS, takže ich nemožno importovať. Niektoré aplikácie (napríklad Garmin Connect) zaznamenávajú aktivity do Apple Health bez zdieľania trasy. Tréningy zaznamenané pomocou Apple Watch zahŕňajú trasy a možno ich importovať.';

  @override
  String get healthSyncBadgeNonImportable => 'Neimportovateľné';

  @override
  String get healthSyncViewAvailable => 'Dostupné';

  @override
  String get healthSyncViewImported => 'Importované';

  @override
  String get healthSyncDateRange => 'Obdobie tréningov';

  @override
  String get healthSyncRange30Days => 'Posledných 30 dní';

  @override
  String get healthSyncRange3Months => 'Posledné 3 mesiace';

  @override
  String get healthSyncRange6Months => 'Posledných 6 mesiacov';

  @override
  String get healthSyncRangeYear => 'Posledný rok';

  @override
  String get healthSyncRangeAll => 'Celá história';

  @override
  String get healthSyncRangeCustom => 'Vlastné obdobie';

  @override
  String get healthSyncImportedEmpty =>
      'Pre toto pripojenie nie sú importované tréningy.';

  @override
  String healthSyncImportedAt(String dateTime) {
    return 'Importované: $dateTime';
  }

  @override
  String get healthSyncRestore => 'Obnoviť';

  @override
  String get sensorsTitle => 'Senzory';

  @override
  String get sensorsSettingsSubtitle =>
      'Snímače tepovej frekvencie a ďalšie externé senzory';

  @override
  String get sensorsHeartRateSection => 'Tep';

  @override
  String get sensorsHeartRateHelp =>
      'Spárujte snímač tepovej frekvencie Bluetooth, aby ste videli svoj tep naživo.';

  @override
  String get sensorsBluetoothOff =>
      'Bluetooth je vypnuté. Zapnite ho na pripojenie senzora.';

  @override
  String get sensorsBluetoothUnauthorized =>
      'Povoľte prístup k Bluetooth na pripojenie senzora.';

  @override
  String get sensorsBluetoothUnsupported =>
      'Toto zariadenie nepodporuje Bluetooth Low Energy.';

  @override
  String get sensorsScan => 'Hľadať senzory';

  @override
  String get sensorsScanning => 'Hľadanie…';

  @override
  String get sensorsStopScan => 'Zastaviť';

  @override
  String get sensorsNoDevices => 'Zatiaľ neboli nájdené žiadne snímače tepu.';

  @override
  String get sensorsAvailableSection => 'Dostupné senzory';

  @override
  String get sensorsSavedSection => 'Uložený senzor';

  @override
  String get sensorsConnect => 'Pripojiť';

  @override
  String get sensorsConnecting => 'Pripája sa…';

  @override
  String get sensorsConnected => 'Pripojené';

  @override
  String get sensorsDisconnect => 'Odpojiť';

  @override
  String get sensorsForget => 'Zabudnúť';

  @override
  String get sensorsConnectionFailed => 'Pripojenie zlyhalo. Skúste to znova.';

  @override
  String get sensorsPermissionRequired =>
      'Na hľadanie senzorov sa vyžaduje povolenie Bluetooth.';

  @override
  String get sensorsUnknownDevice => 'Neznámy senzor';

  @override
  String sensorsBpm(String bpm) {
    return '$bpm bpm';
  }

  @override
  String get sensorsPowerSection => 'Výkon';

  @override
  String get sensorsPowerHelp =>
      'Spárujte merač výkonu Bluetooth, aby ste videli svoj výkon naživo.';

  @override
  String get sensorsNoPowerDevices =>
      'Zatiaľ neboli nájdené žiadne merače výkonu.';

  @override
  String sensorsWatts(String watts) {
    return '$watts W';
  }

  @override
  String get sensorsCadenceSection => 'Kadencia';

  @override
  String get sensorsCadenceHelp =>
      'Spárujte snímač kadencie Bluetooth, aby ste videli svoju kadenciu naživo.';

  @override
  String get sensorsNoCadenceDevices =>
      'Zatiaľ neboli nájdené žiadne snímače kadencie.';

  @override
  String sensorsRpm(String rpm) {
    return '$rpm rpm';
  }

  @override
  String get diagnosticsRemoteTitle => 'Vzdialené hlásenie pádov';

  @override
  String get diagnosticsRemoteEnable => 'Odosielať hlásenia o pádoch';

  @override
  String get diagnosticsRemoteEnableSubtitle =>
      'Odosielajte hlásenia o pádoch a chybách na diagnostický server. Je to nezávislé od miestnej diagnostiky; môžete zapnúť oboje, jedno alebo nič.';

  @override
  String get diagnosticsRemoteActive => 'Crash reports are being sent.';

  @override
  String get diagnosticsRemoteNeedsServer =>
      'Vzdialené hlásenie pádov nie je v tejto verzii dostupné.';

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
  String get unitsTitle => 'Jednotky';

  @override
  String get unitsSubtitle => 'Jednotky vzdialenosti, rýchlosti a prevýšenia';

  @override
  String get unitsSystemDefault => 'Podľa regiónu zariadenia';

  @override
  String get unitsMetric => 'Metrické (km)';

  @override
  String get unitsImperial => 'Imperiálne (mi)';

  @override
  String get errorInsecureRedirectRejected =>
      'The server tried to redirect to an insecure connection. The request was blocked to protect your credentials.';

  @override
  String get errorTooManyRedirects =>
      'The server redirected too many times. Check the server address.';

  @override
  String get audioAnnouncementsTitle => 'Hlasové oznámenia';

  @override
  String get audioAnnouncementsSubtitle =>
      'Hlasové aktualizácie vzdialenosti, času, tempa alebo rýchlosti';

  @override
  String get audioAnnouncementsMasterSwitch => 'Oznamovať priebeh aktivity';

  @override
  String get audioAnnouncementsMasterSwitchSubtitle =>
      'Počas nahrávania nahlas oznamuje vzdialenosť, čas, tempo alebo rýchlosť';

  @override
  String get audioAnnouncementsDuckSwitch =>
      'Stlmiť iný zvuk počas rozprávania';

  @override
  String get audioAnnouncementsDuckSwitchSubtitle =>
      'Dočasne zníži hlasitosť iného zvuku počas každého oznámenia';

  @override
  String get audioAnnouncementsIntervalsHeader =>
      'Interval oznámení podľa aktivity';

  @override
  String get audioAnnouncementsByDistance => 'Vzdialenosť';

  @override
  String get audioAnnouncementsByTime => 'Čas';

  @override
  String audioAnnouncementsIntervalDistance(String value, String unit) {
    return 'Každých $value $unit';
  }

  @override
  String audioAnnouncementsIntervalTime(String minutes) {
    return 'Každých $minutes min';
  }

  @override
  String get audioAnnouncementsDecreaseInterval => 'Zmenšiť interval';

  @override
  String get audioAnnouncementsIncreaseInterval => 'Zväčšiť interval';

  @override
  String get audioAnnouncementsPreview => 'Prehrať ukážku';

  @override
  String get audioAnnouncementsPreviewUnavailable =>
      'Ukážka hlásenia nie je na tomto zariadení dostupná';

  @override
  String get audioAnnouncementsAppliesNextRecording =>
      'Zmeny sa prejavia pri ďalšom zázname.';

  @override
  String audioAnnouncementsSpokenMessage(
    String distance,
    String duration,
    String lapMetric,
    String overallMetric,
  ) {
    return 'Vzdialenosť $distance. Čas $duration. Okruh: $lapMetric. Celkovo: $overallMetric.';
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
  String get osmandRecordingsTitle => 'OsmAnd recordings';

  @override
  String get osmandRefresh => 'Refresh recordings';

  @override
  String get osmandRecordingsInstructions =>
      'Finish and save the recording as GPX in OsmAnd first. Original files are preserved. Use the Endurain button on the native map to return here.';

  @override
  String get osmandRecordingsLoadFailed =>
      'Saved recordings could not be loaded. Try refreshing.';

  @override
  String get osmandRecordingsEmpty => 'No saved GPX recordings yet.';

  @override
  String get osmandImportTitle => 'Import OsmAnd recording?';

  @override
  String get osmandImportAction => 'Import';

  @override
  String get osmandImportLocalConfirmation =>
      'Save locally. This copy will remain local after you sign in later.';

  @override
  String osmandImportAccountConfirmation(String server) {
    return 'Save locally and upload to the account currently signed in at $server. Previously imported files keep their original destination.';
  }

  @override
  String get osmandImportLocalResult =>
      'Saved locally. This file keeps its original local storage or account assignment.';

  @override
  String get osmandImportQueuedResult =>
      'Saved locally. The upload is queued and will be retried when possible.';

  @override
  String get osmandImportUploadFailed =>
      'Saved locally, but upload failed. You can retry from local activities.';

  @override
  String get osmandImportAccountChanged =>
      'The account changed. Please import again to confirm the destination.';

  @override
  String get osmandImportFailed =>
      'The recording could not be imported. Ensure it is saved as a valid GPX track with timestamps and try again.';

  @override
  String get osmandPreviouslyImported =>
      'This recording was already imported and its local history was deleted. It cannot be imported again or assigned to another account. The original OsmAnd GPX is preserved.';

  @override
  String get osmandNativeSettingsUnavailable =>
      'Endurain sensor and audio settings are unavailable in this build. Use OsmAnd from the Map screen.';
}
