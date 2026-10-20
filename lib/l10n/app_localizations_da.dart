// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get error => 'Fejl';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get back => 'Tilbage';

  @override
  String get requiredField => 'Dette felt er påkrævet';

  @override
  String get invalidUrl => 'Indtast en gyldig URL';

  @override
  String get errorActivityUploadFailed => 'Aktiviteten kunne ikke uploades';

  @override
  String errorActivityUploadFailedWithDetails(String details) {
    return 'Aktiviteten kunne ikke uploades: $details';
  }

  @override
  String get errorActivityUploadNotConfigured =>
      'Upload af aktiviteter er endnu ikke konfigureret';

  @override
  String get errorActivityGpxCleanupFailed =>
      'Den midlertidige aktivitetsfil kunne ikke slettes';

  @override
  String get errorActivityGpxFileWriteFailed =>
      'Filen til upload af aktiviteten kunne ikke forberedes';

  @override
  String get errorActivityLocalActivityNotFound =>
      'Denne lokale aktivitet kunne ikke findes';

  @override
  String get errorActivityLocalDeleteFailed =>
      'Den lokale aktivitet kunne ikke slettes';

  @override
  String get errorActivityLocalGpxMissing =>
      'Den lokale GPX-fil er ikke tilgængelig';

  @override
  String get errorActivityLocalLoadFailed =>
      'Lokale aktiviteter kunne ikke indlæses';

  @override
  String get errorActivityLocalRecordInvalid =>
      'Denne aktivitet kunne ikke gemmes';

  @override
  String get errorActivityLocalSaveFailed =>
      'Aktiviteten kunne ikke gemmes lokalt';

  @override
  String get errorFetchProvidersFailed => 'Loginudbydere kunne ikke indlæses';

  @override
  String errorFetchProvidersFailedWithDetails(String details) {
    return 'Loginudbydere kunne ikke indlæses: $details';
  }

  @override
  String get errorFetchServerSettingsFailed =>
      'Serverindstillinger kunne ikke indlæses';

  @override
  String errorFetchServerSettingsFailedWithDetails(String details) {
    return 'Serverindstillinger kunne ikke indlæses: $details';
  }

  @override
  String get errorHealthGpxBuildFailed =>
      'Kunne ikke konvertere træning til GPX';

  @override
  String get errorHealthImportFailed => 'Kunne ikke importere træning';

  @override
  String errorHealthImportFailedWithDetails(String details) {
    return 'Kunne ikke importere træning: $details';
  }

  @override
  String get errorHealthPermissionDenied =>
      'Adgang til sundhedsdata blev nægtet';

  @override
  String get errorHealthReadFailed => 'Kunne ikke læse sundhedsdata';

  @override
  String get errorLoginError => 'Kunne ikke logge ind';

  @override
  String errorLoginErrorWithDetails(String details) {
    return 'Kunne ikke logge ind: $details';
  }

  @override
  String get errorLoginFailed => 'Login mislykkedes';

  @override
  String errorLoginFailedWithDetails(String details) {
    return 'Login mislykkedes: $details';
  }

  @override
  String get errorMfaVerificationError => 'MFA-koden kunne ikke bekræftes';

  @override
  String errorMfaVerificationErrorWithDetails(String details) {
    return 'MFA-koden kunne ikke bekræftes: $details';
  }

  @override
  String get errorMfaVerificationFailed => 'MFA-bekræftelse mislykkedes';

  @override
  String errorMfaVerificationFailedWithDetails(String details) {
    return 'MFA-bekræftelse mislykkedes: $details';
  }

  @override
  String get errorNoSessionIdReceived =>
      'Der blev ikke modtaget noget sessions-id fra serveren';

  @override
  String get errorNotAuthenticated => 'Du er ikke logget ind';

  @override
  String get errorPkceVerifierMissingRestartLogin =>
      'Loginverifikatoren blev ikke fundet. Start login forfra.';

  @override
  String get errorServerUrlNotConfigured => 'Server-URL er ikke konfigureret';

  @override
  String get errorInsecureTransportNotAllowed =>
      'Denne server kræver en sikker (HTTPS-)forbindelse';

  @override
  String get errorSessionExpired => 'Din session er udløbet. Log ind igen.';

  @override
  String get errorSsoTokenExchangeError => 'SSO-login kunne ikke fuldføres';

  @override
  String errorSsoTokenExchangeErrorWithDetails(String details) {
    return 'SSO-login kunne ikke fuldføres: $details';
  }

  @override
  String get errorTokenExchangeFailed => 'Tokenudveksling mislykkedes';

  @override
  String errorTokenExchangeFailedWithDetails(String details) {
    return 'Tokenudveksling mislykkedes: $details';
  }

  @override
  String get errorRequestTimeout =>
      'Anmodningen fik timeout. Tjek din forbindelse, og prøv igen.';

  @override
  String get errorSecureStorageDeleteFailed =>
      'Kan ikke slette fra sikker lagring. Enhedens lagring er muligvis ikke tilgængelig.';

  @override
  String get errorSecureStorageReadFailed =>
      'Kan ikke læse fra sikker lagring. Enhedens lagring er muligvis ikke tilgængelig.';

  @override
  String get errorSecureStorageWriteFailed =>
      'Kan ikke skrive til sikker lagring. Enhedens lagring er muligvis ikke tilgængelig.';

  @override
  String get errorUnexpectedResponseFormat =>
      'Serveren returnerede et uventet svar';

  @override
  String get errorUnsupportedHttpMethod => 'HTTP-metoden understøttes ikke';

  @override
  String errorUnsupportedHttpMethodWithDetails(String details) {
    return 'HTTP-metoden understøttes ikke: $details';
  }

  @override
  String get loginTitle => 'Log ind';

  @override
  String get login => 'Log ind';

  @override
  String get logout => 'Log ud';

  @override
  String get logoutConfirmTitle => 'Log ud';

  @override
  String get logoutConfirmMessage => 'Er du sikker på, at du vil logge ud?';

  @override
  String get logoutServerFailedWarning =>
      'Kunne ikke logge ud fra serveren, men loggede ud lokalt';

  @override
  String get ssoBrowserLaunchFailed =>
      'SSO-login kunne ikke åbnes i systembrowseren';

  @override
  String ssoSignInWith(String provider) {
    return 'Log ind med $provider';
  }

  @override
  String get ssoOrDivider => 'ELLER';

  @override
  String get next => 'Næste';

  @override
  String get username => 'Brugernavn';

  @override
  String get usernameHint => 'Indtast dit brugernavn';

  @override
  String get password => 'Adgangskode';

  @override
  String get passwordHint => 'Indtast din adgangskode';

  @override
  String get showPassword => 'Vis adgangskode';

  @override
  String get mfaTitle => 'Tofaktorgodkendelse';

  @override
  String get mfaCode => 'MFA-kode';

  @override
  String get mfaCodeHint => 'Indtast den 6-cifrede kode';

  @override
  String get mfaCodeRequired => 'Indtast MFA-koden';

  @override
  String get verify => 'Bekræft';

  @override
  String get activityDiscard => 'Kassér';

  @override
  String get activityDiscardConfirmMessage =>
      'Dette sletter de registrerede punkter for denne aktivitet.';

  @override
  String get activityDiscardConfirmTitle => 'Kassér aktiviteten?';

  @override
  String get activityLocationPermissionDenied =>
      'Placeringstilladelse er påkrævet for at registrere en aktivitet.';

  @override
  String get activityLocationPermissionDeniedForever =>
      'Placeringstilladelsen er blokeret. Åbn indstillingerne for at tillade placeringsadgang.';

  @override
  String get activityLocationServiceDisabled =>
      'Placeringstjenester er deaktiveret.';

  @override
  String get activityLocationStreamFailed =>
      'Placeringsopdateringerne stoppede uventet.';

  @override
  String get activityGpxGenerationFailed =>
      'Aktivitetens GPX-fil kunne ikke oprettes.';

  @override
  String get activityLocalSaveFailed =>
      'Denne aktivitet kunne ikke gemmes på denne enhed.';

  @override
  String get activityOpenSettings => 'Åbn indstillinger';

  @override
  String get activityPause => 'Pause';

  @override
  String get activityRecordingEmpty =>
      'Der blev ikke registreret nogen GPS-punkter.';

  @override
  String get activityRecordingFailed => 'Registreringen mislykkedes.';

  @override
  String get activityResume => 'Genoptag';

  @override
  String get activityRetryUpload => 'Prøv upload igen';

  @override
  String get activityDone => 'Færdig';

  @override
  String get activityViewHistory => 'Vis historik';

  @override
  String get activityDeleteLocal => 'Slet lokal kopi';

  @override
  String get activityExportGpx => 'Del GPX-fil';

  @override
  String get activityExportGpxSubject => 'Endurain-aktivitets-GPX';

  @override
  String get activityDeleteLocalConfirmTitle => 'Slet lokal aktivitet?';

  @override
  String get activityDeleteLocalConfirmMessage =>
      'Dette fjerner den lokale aktivitetspost og GPX-filen fra denne enhed.';

  @override
  String get activityStart => 'Start';

  @override
  String get activityBackgroundPermissionTitle =>
      'Tillad sporing i baggrunden?';

  @override
  String get activityBackgroundPermissionMessage =>
      'Endurain skal have baggrundsplacering indstillet til Altid, så registreringen fortsætter, når appen er i baggrunden, skærmen er låst, eller du skifter app.';

  @override
  String get activityBackgroundPermissionContinue => 'Fortsæt';

  @override
  String get activityBackgroundPermissionRequired =>
      'Sporing i baggrunden på iPhone og iPad kræver, at Placering er indstillet til Altid.';

  @override
  String get activityBackgroundPermissionSettingsTitle =>
      'Sporing i baggrunden er slået fra';

  @override
  String get activityBackgroundPermissionSettingsMessage =>
      'For at registrere pålideligt i baggrunden eller med låst skærm skal du åbne Indstillinger og indstille Placering til Altid for Endurain.';

  @override
  String get activityTrackingNotificationTitle => 'Registrerer aktivitet';

  @override
  String get activityTrackingNotificationText =>
      'Endurain sporer din placering for at registrere denne aktivitet.';

  @override
  String get activityStatDistance => 'Distance';

  @override
  String get activityStatDuration => 'Tid';

  @override
  String get activityStatSpeed => 'Hastighed';

  @override
  String get activityStatPace => 'Tempo';

  @override
  String get activityStatMaxSpeed => 'Maks. hastighed';

  @override
  String get activityStatElevationGain => 'Stigning';

  @override
  String get activityStatHeartRate => 'Puls';

  @override
  String get activityStatAvgHeartRate => 'Gns. puls';

  @override
  String get activityStatPower => 'Effekt';

  @override
  String get activityStatAvgPower => 'Gns. effekt';

  @override
  String get activityStatCadence => 'Kadence';

  @override
  String get activityStatAvgCadence => 'Gns. kadence';

  @override
  String get activityStop => 'Stop';

  @override
  String get activityStopAndSave => 'Stop og gem';

  @override
  String get activityStopConfirmMessage =>
      'Vælg, om du vil beholde denne registrering eller kassere den.';

  @override
  String get activityStopConfirmTitle => 'Afslut aktiviteten?';

  @override
  String get activityStopping => 'Stopper';

  @override
  String get activityTypeHike => 'Vandretur';

  @override
  String get activityTypeLabel => 'Aktivitetstype';

  @override
  String get activityTypeOther => 'Andet';

  @override
  String get activityTypeRide => 'Cykling';

  @override
  String get activityTypeRun => 'Løb';

  @override
  String get activityTypeWalk => 'Gåtur';

  @override
  String get activityUploadFailed => 'Upload mislykkedes';

  @override
  String get activityUploadCleanupFailed =>
      'Uploadet, men oprydning mislykkedes';

  @override
  String get activityUploadReady => 'Klar til upload';

  @override
  String get activityUploaded => 'Uploadet';

  @override
  String get activityUploading => 'Uploader';

  @override
  String get activityUploadStatusPending => 'Afventer';

  @override
  String get activityUploadStatusUploaded => 'Uploadet';

  @override
  String get activityUploadStatusFailed => 'Mislykkedes';

  @override
  String get activityHistoryTitle => 'Aktivitetshistorik';

  @override
  String get activityHistorySettingsSubtitle =>
      'Gennemførte aktiviteter gemt på denne enhed';

  @override
  String get activityRetainUploadedGpx => 'Behold uploadede GPX-filer';

  @override
  String get activityRetainUploadedGpxSubtitle =>
      'Gemmer gennemførte rutefiler i appens private lagring efter upload.';

  @override
  String get activityHistoryEmpty =>
      'Ingen gennemførte aktiviteter gemt på denne enhed.';

  @override
  String get activityHistoryLoadFailed =>
      'Lokale aktiviteter kunne ikke indlæses.';

  @override
  String get activityHistoryRefresh => 'Opdater';

  @override
  String get activityHistoryLocalActivities => 'Lokale aktiviteter';

  @override
  String activityHistoryEntryTitle(String activityType, String endedAt) {
    return '$activityType • $endedAt';
  }

  @override
  String activityHistoryDuration(String duration) {
    return 'Varighed: $duration';
  }

  @override
  String activityHistoryDistance(String distance) {
    return 'Distance: $distance';
  }

  @override
  String activityHistoryUploadStatus(String status) {
    return 'Upload: $status';
  }

  @override
  String get activityHistoryLoadMore => 'Indlæs mere';

  @override
  String get activityHistoryDetailsTitle => 'Aktivitetsoplysninger';

  @override
  String get activityHistoryDetailsMissing =>
      'Denne lokale aktivitet er ikke længere tilgængelig.';

  @override
  String get activityHistorySummary => 'Oversigt';

  @override
  String get activityHistoryActions => 'Handlinger';

  @override
  String get activityHistoryType => 'Type';

  @override
  String get activityHistoryStartedAt => 'Startet';

  @override
  String get activityHistoryEndedAt => 'Afsluttet';

  @override
  String get activityHistoryDurationLabel => 'Varighed';

  @override
  String get activityHistoryDistanceLabel => 'Distance';

  @override
  String get activityHistoryAverageSpeed => 'Gennemsnitshastighed';

  @override
  String get activityHistoryPointCount => 'GPS-punkter';

  @override
  String get activityHistoryUploadStatusLabel => 'Upload';

  @override
  String get activityHistoryGpxStatus => 'GPX-fil';

  @override
  String get activityHistoryGpxAvailable => 'Gemt på denne enhed';

  @override
  String get activityHistoryGpxMissing => 'Ikke tilgængelig på denne enhed';

  @override
  String get mapTab => 'Kort';

  @override
  String get myLocation => 'Min placering';

  @override
  String get settingsTab => 'Indstillinger';

  @override
  String get endurainTrademarkNotice =>
      'Endurain® er et registreret varemærke tilhørende João Vitória Silva';

  @override
  String get settingsScreen => 'Indstillinger';

  @override
  String get deviceAccessTitle => 'Enhedsadgang';

  @override
  String get deviceAccessSubtitle =>
      'Administrer lokations- og sundhedsdataadgang';

  @override
  String get deviceAccessLocationSection => 'Beliggenhed';

  @override
  String get deviceAccessHealthSection => 'Sundhedsdata';

  @override
  String get deviceAccessLocationTitle => 'Placeringsadgang';

  @override
  String get deviceAccessHealthTitle => 'Adgang til sundhedsdata';

  @override
  String get deviceAccessChecking => 'Tjekker adgang...';

  @override
  String get deviceAccessLocationServicesOff =>
      'Placeringstjenester er slået fra';

  @override
  String get deviceAccessLocationAlways => 'Tilladt hele tiden';

  @override
  String get deviceAccessLocationWhileUsing => 'Tilladt, mens du bruger appen';

  @override
  String get deviceAccessLocationBlocked => 'Blokeret i systemindstillinger';

  @override
  String get deviceAccessLocationNotAllowed => 'Ikke tilladt';

  @override
  String get deviceAccessHealthUnavailable => 'Ikke tilgængelig på denne enhed';

  @override
  String get deviceAccessHealthRequired => 'Health Connect er påkrævet';

  @override
  String get deviceAccessHealthSetUp => 'Sundhedsadgang opsat';

  @override
  String get deviceAccessHealthNeedsAttention => 'Adgang kræver opmærksomhed';

  @override
  String get deviceAccessHealthNotConnected => 'Ikke forbundet';

  @override
  String get language => 'Sprog';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get serverSettings => 'Server';

  @override
  String get signInConnectServer => 'Log ind';

  @override
  String get signInConnectServerSubtitle =>
      'Registrer offline nu, og synkroniser dine aktiviteter senere';

  @override
  String get serverSettingsTitle => 'Serverindstillinger';

  @override
  String connectedToServer(String server) {
    return 'Forbundet til $server';
  }

  @override
  String get loggedIn => 'Logget ind';

  @override
  String get notConfigured => 'Ikke konfigureret';

  @override
  String get notLoggedIn => 'Ikke logget ind';

  @override
  String get serverUrl => 'Server-URL';

  @override
  String get serverProtocol => 'Protokol';

  @override
  String get serverUrlHint => 'https://eksempel.com';

  @override
  String get warnHttpServerUrlTitle => 'Usikker forbindelse';

  @override
  String get warnHttpServerUrlMessage =>
      'Denne server-URL bruger almindelig HTTP. Dine loginoplysninger og data overføres uden kryptering. Fortsæt kun, hvis du forstår og accepterer risikoen.';

  @override
  String get warnHttpServerUrlConfirm => 'Fortsæt alligevel';

  @override
  String get tileServerUrl => 'URL til kortfliseserver';

  @override
  String get tileServerUrlHint => 'https://tile.openstreetmap.org/...';

  @override
  String get tileServerHostWarningTitle => 'Anden fliseservervært';

  @override
  String get tileServerHostWarningMessage =>
      'Fliseserverens vært er forskellig fra din Endurain-servers vært. Fliser indlæses fra en tredjepartsserver. Vil du fortsætte?';

  @override
  String get savedSuccessfully => 'Indstillingerne blev gemt';

  @override
  String get diagnostics => 'Diagnostik';

  @override
  String get diagnosticsSubtitle => 'Lokal nedbrudskontekst';

  @override
  String get sourceCode => 'GitHub';

  @override
  String get sourceCodeSubtitle => 'github.com/endurain-project';

  @override
  String get openLinkFailed => 'Linket kunne ikke åbnes';

  @override
  String get diagnosticsTitle => 'Diagnostik';

  @override
  String get diagnosticsCollection => 'Indsamling';

  @override
  String get diagnosticsEnable => 'Indsaml diagnostik';

  @override
  String get diagnosticsEnableSubtitle =>
      'Gem seneste app-hændelser og fejl på denne enhed';

  @override
  String get diagnosticsDisabled =>
      'Indsamling af diagnostik er slået fra. Slå den til for at begynde at registrere app-hændelser og fejl på denne enhed.';

  @override
  String get diagnosticsEmpty =>
      'Der er endnu ikke indsamlet nogen diagnostik.';

  @override
  String get diagnosticsCopy => 'Kopiér';

  @override
  String get diagnosticsCopied => 'Diagnostik kopieret';

  @override
  String get diagnosticsClear => 'Ryd';

  @override
  String get diagnosticsCleared => 'Diagnostik ryddet';

  @override
  String get diagnosticsSummary => 'Oversigt';

  @override
  String get diagnosticsLastUpdated => 'Senest opdateret';

  @override
  String diagnosticsEventsCount(int count) {
    return 'Hændelser: $count';
  }

  @override
  String diagnosticsErrorsCount(int count) {
    return 'Fejl: $count';
  }

  @override
  String get diagnosticsEvents => 'Hændelser';

  @override
  String get diagnosticsNoEvents => 'Ingen hændelser indsamlet';

  @override
  String diagnosticsEventTitle(String event) {
    return 'Hændelse: $event';
  }

  @override
  String get diagnosticsErrors => 'Fejl';

  @override
  String diagnosticsErrorTitle(String type) {
    return 'Fejl: $type';
  }

  @override
  String get diagnosticsActions => 'Handlinger';

  @override
  String get diagnosticsRawReport => 'Rårapport';

  @override
  String get healthSyncSettingsTitle => 'Sundhedssynkronisering';

  @override
  String get healthSyncSettingsSubtitle =>
      'Importer træning fra din sundhedsplatform';

  @override
  String get healthSyncScreenTitle => 'Sundhedssynkronisering';

  @override
  String get healthAccessScreenTitle => 'Sundhedsadgang';

  @override
  String get healthAccessRequestedData => 'Anmodede data';

  @override
  String get healthAccessWorkouts => 'Træning';

  @override
  String get healthAccessWorkoutRoutes => 'Træningsruter';

  @override
  String get healthAccessHeartRate => 'Puls';

  @override
  String get healthAccessWorkoutSummary =>
      'Træningsdistance, kalorier og skridt';

  @override
  String get healthAccessAllowed => 'Tilladt';

  @override
  String get healthAccessNeedsAttention => 'Har brug for opmærksomhed';

  @override
  String get healthAccessManagedBySystem =>
      'Administreret i systemindstillinger';

  @override
  String get healthAccessSystemManagedNotice =>
      'HealthKit oplyser ikke, hvilke data Endurain kan læse. Gennemgå adgangen i Health-appen.';

  @override
  String get healthAccessReview => 'Gennemgå sundhedsadgang';

  @override
  String get healthAccessReviewIos => 'Sådan gennemgår du adgang';

  @override
  String get healthAccessDisconnect => 'Afbryd sundhedsdata';

  @override
  String get healthAccessDisconnectTitle => 'Afbryd sundhedsdata?';

  @override
  String get healthAccessDisconnectMessage =>
      'Automatisk import og lokal importhistorik for denne server nulstilles. Eksisterende aktiviteter forbliver i historikken.';

  @override
  String get healthAccessReviewIosInstructions =>
      'Åbn Health-appen, tryk på dit profilbillede og derefter Apps og tjenester. Vælg Endurain og opdater datakategorierne.';

  @override
  String get healthSyncAuthorize => 'Opret forbindelse til sundhedsdata';

  @override
  String get healthSyncInstallProvider => 'Installer Health Connect';

  @override
  String get healthSyncInstallProviderDescription =>
      'Health Connect er påkrævet for at synkronisere træning. Installer det for at fortsætte.';

  @override
  String get healthSyncUnsupported =>
      'Sundhedssynkronisering er ikke tilgængelig på denne enhed.';

  @override
  String get healthSyncSelectAll => 'Vælg alle';

  @override
  String get healthSyncClearSelection => 'Ryd';

  @override
  String healthSyncImportSelected(int count) {
    return 'Importer valgt ($count)';
  }

  @override
  String healthSyncImportedCount(int count) {
    return 'Importerede $count træning(er).';
  }

  @override
  String get healthSyncNoRouteLabel => 'Ingen GPS-rute';

  @override
  String get healthSyncEmptyState =>
      'Ingen træning fundet i den valgte periode.';

  @override
  String get healthSyncRouteConsentGuidance =>
      'Nogle træningspas blev sprunget over, fordi der ikke blev givet adgang til træningsruten. Åbn Health Connect → Tilladelser og tillad træningsruter for Endurain.';

  @override
  String get healthSyncRouteConsentGuidanceIos =>
      'Nogle træningspas blev sprunget over, fordi Endurain ikke kunne læse deres GPS-ruter. I Health-appen skal du åbne din profil, derefter Apps og tjenester, vælge Endurain og tillade træningsruter.';

  @override
  String get healthSyncReviewAccess => 'Gennemgå adgang';

  @override
  String get healthSyncAutoSyncTitle =>
      'Automatisk synkronisering ved genoptagelse';

  @override
  String get healthSyncAutoSyncSubtitle =>
      'Importer nye træningsprogrammer automatisk, når appen åbner.';

  @override
  String get healthSyncNoRoutesExplanation =>
      'Disse træningspas inkluderer ikke en GPS-rute, så de kan ikke importeres. Nogle apps (som Garmin Connect) optager aktiviteter til Apple Health uden at dele ruten. Træninger optaget med Apple Watch inkluderer ruter og kan importeres.';

  @override
  String get healthSyncBadgeNonImportable => 'Ikke-importabel';

  @override
  String get healthSyncViewAvailable => 'Tilgængelige';

  @override
  String get healthSyncViewImported => 'Importerede';

  @override
  String get healthSyncDateRange => 'Træningsperiode';

  @override
  String get healthSyncRange30Days => 'Seneste 30 dage';

  @override
  String get healthSyncRange3Months => 'Seneste 3 måneder';

  @override
  String get healthSyncRange6Months => 'Seneste 6 måneder';

  @override
  String get healthSyncRangeYear => 'Seneste år';

  @override
  String get healthSyncRangeAll => 'Hele historikken';

  @override
  String get healthSyncRangeCustom => 'Tilpasset periode';

  @override
  String get healthSyncImportedEmpty =>
      'Ingen importerede træninger for denne forbindelse.';

  @override
  String healthSyncImportedAt(String dateTime) {
    return 'Importeret: $dateTime';
  }

  @override
  String get healthSyncRestore => 'Gendan';

  @override
  String get sensorsTitle => 'Sensorer';

  @override
  String get sensorsSettingsSubtitle => 'Pulsmålere og andre eksterne sensorer';

  @override
  String get sensorsHeartRateSection => 'Puls';

  @override
  String get sensorsHeartRateHelp =>
      'Par en Bluetooth-pulsmåler for at se din puls live.';

  @override
  String get sensorsBluetoothOff =>
      'Bluetooth er slået fra. Slå det til for at forbinde en sensor.';

  @override
  String get sensorsBluetoothUnauthorized =>
      'Tillad Bluetooth-adgang for at forbinde en sensor.';

  @override
  String get sensorsBluetoothUnsupported =>
      'Denne enhed understøtter ikke Bluetooth Low Energy.';

  @override
  String get sensorsScan => 'Søg efter sensorer';

  @override
  String get sensorsScanning => 'Søger…';

  @override
  String get sensorsStopScan => 'Stop';

  @override
  String get sensorsNoDevices => 'Ingen pulssensorer fundet endnu.';

  @override
  String get sensorsAvailableSection => 'Tilgængelige sensorer';

  @override
  String get sensorsSavedSection => 'Gemt sensor';

  @override
  String get sensorsConnect => 'Forbind';

  @override
  String get sensorsConnecting => 'Forbinder…';

  @override
  String get sensorsConnected => 'Forbundet';

  @override
  String get sensorsDisconnect => 'Afbryd';

  @override
  String get sensorsForget => 'Glem';

  @override
  String get sensorsConnectionFailed => 'Kunne ikke forbinde. Prøv igen.';

  @override
  String get sensorsPermissionRequired =>
      'Der kræves Bluetooth-tilladelse for at finde sensorer.';

  @override
  String get sensorsUnknownDevice => 'Ukendt sensor';

  @override
  String sensorsBpm(String bpm) {
    return '$bpm bpm';
  }

  @override
  String get sensorsPowerSection => 'Effekt';

  @override
  String get sensorsPowerHelp =>
      'Par en Bluetooth-effektmåler for at se din effekt live.';

  @override
  String get sensorsNoPowerDevices => 'Ingen effektmålere fundet endnu.';

  @override
  String sensorsWatts(String watts) {
    return '$watts W';
  }

  @override
  String get sensorsCadenceSection => 'Kadence';

  @override
  String get sensorsCadenceHelp =>
      'Par en Bluetooth-kadencesensor for at se din kadence live.';

  @override
  String get sensorsNoCadenceDevices => 'Ingen kadencesensorer fundet endnu.';

  @override
  String sensorsRpm(String rpm) {
    return '$rpm rpm';
  }

  @override
  String get diagnosticsRemoteTitle => 'Ekstern nedbrudsrapportering';

  @override
  String get diagnosticsRemoteEnable => 'Send nedbrudsrapporter';

  @override
  String get diagnosticsRemoteEnableSubtitle =>
      'Send nedbruds- og fejlrapporter til en diagnosticeringsserver. Dette er adskilt fra lokal diagnostik; du kan slå begge, én eller ingen til.';

  @override
  String get diagnosticsRemoteActive => 'Crash reports are being sent.';

  @override
  String get diagnosticsRemoteNeedsServer =>
      'Ekstern nedbrudsrapportering er ikke tilgængelig i denne version.';

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
  String get unitsTitle => 'Enheder';

  @override
  String get unitsSubtitle => 'Enheder for distance, hastighed og højde';

  @override
  String get unitsSystemDefault => 'Følg enhedens region';

  @override
  String get unitsMetric => 'Metrisk (km)';

  @override
  String get unitsImperial => 'Imperialt (mi)';

  @override
  String get errorInsecureRedirectRejected =>
      'The server tried to redirect to an insecure connection. The request was blocked to protect your credentials.';

  @override
  String get errorTooManyRedirects =>
      'The server redirected too many times. Check the server address.';

  @override
  String get audioAnnouncementsTitle => 'Lydmeddelelser';

  @override
  String get audioAnnouncementsSubtitle =>
      'Talebeskeder om distance, tid, tempo eller hastighed';

  @override
  String get audioAnnouncementsMasterSwitch => 'Meddel aktivitetens fremgang';

  @override
  String get audioAnnouncementsMasterSwitchSubtitle =>
      'Siger din distance, tid, tempo eller hastighed højt under en optagelse';

  @override
  String get audioAnnouncementsDuckSwitch => 'Dæmp anden lyd, mens der tales';

  @override
  String get audioAnnouncementsDuckSwitchSubtitle =>
      'Sænker midlertidigt lydstyrken for anden lyd under hver meddelelse';

  @override
  String get audioAnnouncementsIntervalsHeader =>
      'Meddelelsesinterval efter aktivitet';

  @override
  String get audioAnnouncementsByDistance => 'Distance';

  @override
  String get audioAnnouncementsByTime => 'Tid';

  @override
  String audioAnnouncementsIntervalDistance(String value, String unit) {
    return 'Hvert $value $unit';
  }

  @override
  String audioAnnouncementsIntervalTime(String minutes) {
    return 'Hvert $minutes min';
  }

  @override
  String get audioAnnouncementsDecreaseInterval => 'Reducer interval';

  @override
  String get audioAnnouncementsIncreaseInterval => 'Øg interval';

  @override
  String get audioAnnouncementsPreview => 'Afspil eksempel';

  @override
  String get audioAnnouncementsPreviewUnavailable =>
      'Eksempel på annoncering er ikke tilgængeligt på denne enhed';

  @override
  String get audioAnnouncementsAppliesNextRecording =>
      'Ændringer træder i kraft ved din næste optagelse.';

  @override
  String audioAnnouncementsSpokenMessage(
    String distance,
    String duration,
    String lapMetric,
    String overallMetric,
  ) {
    return 'Distance $distance. Tid $duration. Omgang: $lapMetric. Samlet: $overallMetric.';
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
