// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get error => 'Virhe';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Peruuta';

  @override
  String get save => 'Tallenna';

  @override
  String get back => 'Takaisin';

  @override
  String get requiredField => 'Tämä kenttä on pakollinen';

  @override
  String get invalidUrl => 'Anna kelvollinen URL-osoite';

  @override
  String get errorActivityUploadFailed => 'Aktiviteetin lataaminen epäonnistui';

  @override
  String errorActivityUploadFailedWithDetails(String details) {
    return 'Aktiviteetin lataaminen epäonnistui: $details';
  }

  @override
  String get errorActivityUploadNotConfigured =>
      'Aktiviteettien lataamista ei ole vielä määritetty';

  @override
  String get errorActivityGpxCleanupFailed =>
      'Aktiviteetin väliaikaista tiedostoa ei voitu poistaa';

  @override
  String get errorActivityGpxFileWriteFailed =>
      'Aktiviteetin lataustiedostoa ei voitu valmistella';

  @override
  String get errorActivityLocalActivityNotFound =>
      'Tätä paikallista aktiviteettia ei löytynyt';

  @override
  String get errorActivityLocalDeleteFailed =>
      'Paikallista aktiviteettia ei voitu poistaa';

  @override
  String get errorActivityLocalGpxMissing =>
      'Paikallinen GPX-tiedosto ei ole käytettävissä';

  @override
  String get errorActivityLocalLoadFailed =>
      'Paikallisia aktiviteetteja ei voitu ladata';

  @override
  String get errorActivityLocalRecordInvalid =>
      'Tätä aktiviteettia ei voitu tallentaa';

  @override
  String get errorActivityLocalSaveFailed =>
      'Aktiviteettia ei voitu tallentaa paikallisesti';

  @override
  String get errorFetchProvidersFailed =>
      'Kirjautumispalveluntarjoajia ei voitu ladata';

  @override
  String errorFetchProvidersFailedWithDetails(String details) {
    return 'Kirjautumispalveluntarjoajia ei voitu ladata: $details';
  }

  @override
  String get errorFetchServerSettingsFailed =>
      'Palvelinasetuksia ei voitu ladata';

  @override
  String errorFetchServerSettingsFailedWithDetails(String details) {
    return 'Palvelinasetuksia ei voitu ladata: $details';
  }

  @override
  String get errorHealthGpxBuildFailed =>
      'Harjoitusta ei voitu muuntaa GPX:ksi';

  @override
  String get errorHealthImportFailed => 'Harjoitusta ei voitu tuoda';

  @override
  String errorHealthImportFailedWithDetails(String details) {
    return 'Harjoitusta ei voitu tuoda: $details';
  }

  @override
  String get errorHealthPermissionDenied => 'Terveystietoihin pääsy evättiin';

  @override
  String get errorHealthReadFailed => 'Terveystietoja ei voitu lukea';

  @override
  String get errorLoginError => 'Kirjautuminen ei onnistunut';

  @override
  String errorLoginErrorWithDetails(String details) {
    return 'Kirjautuminen ei onnistunut: $details';
  }

  @override
  String get errorLoginFailed => 'Kirjautuminen epäonnistui';

  @override
  String errorLoginFailedWithDetails(String details) {
    return 'Kirjautuminen epäonnistui: $details';
  }

  @override
  String get errorMfaVerificationError => 'MFA-koodia ei voitu vahvistaa';

  @override
  String errorMfaVerificationErrorWithDetails(String details) {
    return 'MFA-koodia ei voitu vahvistaa: $details';
  }

  @override
  String get errorMfaVerificationFailed => 'MFA-vahvistus epäonnistui';

  @override
  String errorMfaVerificationFailedWithDetails(String details) {
    return 'MFA-vahvistus epäonnistui: $details';
  }

  @override
  String get errorNoSessionIdReceived =>
      'Palvelimelta ei saatu istuntotunnusta';

  @override
  String get errorNotAuthenticated => 'Et ole kirjautunut sisään';

  @override
  String get errorPkceVerifierMissingRestartLogin =>
      'Kirjautumisen vahvistajaa ei löytynyt. Aloita kirjautuminen uudelleen.';

  @override
  String get errorServerUrlNotConfigured =>
      'Palvelimen URL-osoitetta ei ole määritetty';

  @override
  String get errorInsecureTransportNotAllowed =>
      'Tämä palvelin edellyttää suojattua (HTTPS-)yhteyttä';

  @override
  String get errorSessionExpired =>
      'Istuntosi on vanhentunut. Kirjaudu sisään uudelleen.';

  @override
  String get errorSsoTokenExchangeError =>
      'SSO-kirjautumista ei voitu suorittaa loppuun';

  @override
  String errorSsoTokenExchangeErrorWithDetails(String details) {
    return 'SSO-kirjautumista ei voitu suorittaa loppuun: $details';
  }

  @override
  String get errorTokenExchangeFailed => 'Tunnusten vaihto epäonnistui';

  @override
  String errorTokenExchangeFailedWithDetails(String details) {
    return 'Tunnusten vaihto epäonnistui: $details';
  }

  @override
  String get errorRequestTimeout =>
      'Pyyntö aikakatkaistiin. Tarkista yhteytesi ja yritä uudelleen.';

  @override
  String get errorSecureStorageDeleteFailed =>
      'Suojatusta tallennustilasta ei voi poistaa. Laitteen tallennustila ei ehkä ole käytettävissä.';

  @override
  String get errorSecureStorageReadFailed =>
      'Suojatusta tallennustilasta ei voi lukea. Laitteen tallennustila ei ehkä ole käytettävissä.';

  @override
  String get errorSecureStorageWriteFailed =>
      'Suojattuun tallennustilaan ei voi kirjoittaa. Laitteen tallennustila ei ehkä ole käytettävissä.';

  @override
  String get errorUnexpectedResponseFormat =>
      'Palvelin palautti odottamattoman vastauksen';

  @override
  String get errorUnsupportedHttpMethod => 'HTTP-menetelmää ei tueta';

  @override
  String errorUnsupportedHttpMethodWithDetails(String details) {
    return 'HTTP-menetelmää ei tueta: $details';
  }

  @override
  String get loginTitle => 'Kirjaudu sisään';

  @override
  String get login => 'Kirjaudu sisään';

  @override
  String get logout => 'Kirjaudu ulos';

  @override
  String get logoutConfirmTitle => 'Kirjaudu ulos';

  @override
  String get logoutConfirmMessage => 'Haluatko varmasti kirjautua ulos?';

  @override
  String get logoutServerFailedWarning =>
      'Palvelimelta ei voitu kirjautua ulos, mutta uloskirjautuminen tehtiin paikallisesti';

  @override
  String get ssoBrowserLaunchFailed =>
      'SSO-kirjautumista ei voitu avata järjestelmän selaimessa';

  @override
  String ssoSignInWith(String provider) {
    return 'Kirjaudu sisään palvelulla $provider';
  }

  @override
  String get ssoOrDivider => 'TAI';

  @override
  String get next => 'Seuraava';

  @override
  String get username => 'Käyttäjätunnus';

  @override
  String get usernameHint => 'Anna käyttäjätunnuksesi';

  @override
  String get password => 'Salasana';

  @override
  String get passwordHint => 'Anna salasanasi';

  @override
  String get showPassword => 'Näytä salasana';

  @override
  String get mfaTitle => 'Kaksivaiheinen todennus';

  @override
  String get mfaCode => 'MFA-koodi';

  @override
  String get mfaCodeHint => 'Anna 6-numeroinen koodi';

  @override
  String get mfaCodeRequired => 'Anna MFA-koodi';

  @override
  String get verify => 'Vahvista';

  @override
  String get activityDiscard => 'Hylkää';

  @override
  String get activityDiscardConfirmMessage =>
      'Tämä poistaa tämän aktiviteetin tallennetut pisteet.';

  @override
  String get activityDiscardConfirmTitle => 'Hylätäänkö aktiviteetti?';

  @override
  String get activityLocationPermissionDenied =>
      'Aktiviteetin tallentaminen edellyttää sijaintilupaa.';

  @override
  String get activityLocationPermissionDeniedForever =>
      'Sijaintilupa on estetty. Avaa asetukset salliaksesi sijainnin käytön.';

  @override
  String get activityLocationServiceDisabled =>
      'Sijaintipalvelut on poistettu käytöstä.';

  @override
  String get activityLocationStreamFailed =>
      'Sijaintipäivitykset pysähtyivät odottamatta.';

  @override
  String get activityGpxGenerationFailed =>
      'Aktiviteetin GPX-tiedostoa ei voitu luoda.';

  @override
  String get activityLocalSaveFailed =>
      'Tätä aktiviteettia ei voitu tallentaa tälle laitteelle.';

  @override
  String get activityOpenSettings => 'Avaa asetukset';

  @override
  String get activityPause => 'Keskeytä';

  @override
  String get activityRecordingEmpty => 'Yhtään GPS-pistettä ei tallennettu.';

  @override
  String get activityRecordingFailed => 'Tallennus epäonnistui.';

  @override
  String get activityResume => 'Jatka';

  @override
  String get activityRetryUpload => 'Yritä latausta uudelleen';

  @override
  String get activityDone => 'Valmis';

  @override
  String get activityViewHistory => 'Näytä historia';

  @override
  String get activityDeleteLocal => 'Poista paikallinen kopio';

  @override
  String get activityExportGpx => 'Jaa GPX-tiedosto';

  @override
  String get activityExportGpxSubject => 'Endurain-aktiviteetin GPX';

  @override
  String get activityDeleteLocalConfirmTitle =>
      'Poistetaanko paikallinen aktiviteetti?';

  @override
  String get activityDeleteLocalConfirmMessage =>
      'Tämä poistaa paikallisen aktiviteettitietueen ja GPX-tiedoston tältä laitteelta.';

  @override
  String get activityStart => 'Aloita';

  @override
  String get activityBackgroundPermissionTitle =>
      'Sallitaanko seuranta taustalla?';

  @override
  String get activityBackgroundPermissionMessage =>
      'Endurain tarvitsee taustasijainnin asetettuna arvoon Aina, jotta tallennus jatkuu, kun sovellus on taustalla, näyttö on lukittu tai vaihdat sovellusta.';

  @override
  String get activityBackgroundPermissionContinue => 'Jatka';

  @override
  String get activityBackgroundPermissionRequired =>
      'Taustaseuranta iPhonessa ja iPadissa edellyttää, että Sijainti on asetettu arvoon Aina.';

  @override
  String get activityBackgroundPermissionSettingsTitle =>
      'Taustaseuranta on pois käytöstä';

  @override
  String get activityBackgroundPermissionSettingsMessage =>
      'Jotta tallennus toimii luotettavasti taustalla tai näytön ollessa lukittuna, avaa Asetukset ja aseta Sijainti arvoon Aina Endurainille.';

  @override
  String get activityTrackingNotificationTitle => 'Tallennetaan aktiviteettia';

  @override
  String get activityTrackingNotificationText =>
      'Endurain seuraa sijaintiasi tämän aktiviteetin tallentamiseksi.';

  @override
  String get activityStatDistance => 'Matka';

  @override
  String get activityStatDuration => 'Aika';

  @override
  String get activityStatSpeed => 'Nopeus';

  @override
  String get activityStatPace => 'Vauhti';

  @override
  String get activityStatMaxSpeed => 'Huippunopeus';

  @override
  String get activityStatElevationGain => 'Nousu';

  @override
  String get activityStatHeartRate => 'Syke';

  @override
  String get activityStatAvgHeartRate => 'Keskisyke';

  @override
  String get activityStatPower => 'Teho';

  @override
  String get activityStatAvgPower => 'Keskiteho';

  @override
  String get activityStatCadence => 'Kadenssi';

  @override
  String get activityStatAvgCadence => 'Keskikadenssi';

  @override
  String get activityStop => 'Lopeta';

  @override
  String get activityStopAndSave => 'Lopeta ja tallenna';

  @override
  String get activityStopConfirmMessage =>
      'Valitse, säilytetäänkö tämä tallenne vai hylätäänkö se.';

  @override
  String get activityStopConfirmTitle => 'Lopetetaanko aktiviteetti?';

  @override
  String get activityStopping => 'Lopetetaan';

  @override
  String get activityTypeHike => 'Vaellus';

  @override
  String get activityTypeLabel => 'Aktiviteetin tyyppi';

  @override
  String get activityTypeOther => 'Muu';

  @override
  String get activityTypeRide => 'Pyöräily';

  @override
  String get activityTypeRun => 'Juoksu';

  @override
  String get activityTypeWalk => 'Kävely';

  @override
  String get activityUploadFailed => 'Lataus epäonnistui';

  @override
  String get activityUploadCleanupFailed =>
      'Ladattu, mutta siivous epäonnistui';

  @override
  String get activityUploadReady => 'Valmis ladattavaksi';

  @override
  String get activityUploaded => 'Ladattu';

  @override
  String get activityUploading => 'Ladataan';

  @override
  String get activityUploadStatusPending => 'Odottaa';

  @override
  String get activityUploadStatusUploaded => 'Ladattu';

  @override
  String get activityUploadStatusFailed => 'Epäonnistui';

  @override
  String get activityHistoryTitle => 'Aktiviteettihistoria';

  @override
  String get activityHistorySettingsSubtitle =>
      'Tälle laitteelle tallennetut valmiit aktiviteetit';

  @override
  String get activityRetainUploadedGpx => 'Säilytä ladatut GPX-tiedostot';

  @override
  String get activityRetainUploadedGpxSubtitle =>
      'Tallentaa valmiit reittitiedostot sovelluksen yksityiseen tallennustilaan latauksen jälkeen.';

  @override
  String get activityHistoryEmpty =>
      'Tälle laitteelle ei ole tallennettu valmiita aktiviteetteja.';

  @override
  String get activityHistoryLoadFailed =>
      'Paikallisia aktiviteetteja ei voitu ladata.';

  @override
  String get activityHistoryRefresh => 'Päivitä';

  @override
  String get activityHistoryLocalActivities => 'Paikalliset aktiviteetit';

  @override
  String activityHistoryEntryTitle(String activityType, String endedAt) {
    return '$activityType • $endedAt';
  }

  @override
  String activityHistoryDuration(String duration) {
    return 'Kesto: $duration';
  }

  @override
  String activityHistoryDistance(String distance) {
    return 'Matka: $distance';
  }

  @override
  String activityHistoryUploadStatus(String status) {
    return 'Lataus: $status';
  }

  @override
  String get activityHistoryLoadMore => 'Lataa lisää';

  @override
  String get activityHistoryDetailsTitle => 'Aktiviteetin tiedot';

  @override
  String get activityHistoryDetailsMissing =>
      'Tämä paikallinen aktiviteetti ei ole enää käytettävissä.';

  @override
  String get activityHistorySummary => 'Yhteenveto';

  @override
  String get activityHistoryActions => 'Toiminnot';

  @override
  String get activityHistoryType => 'Tyyppi';

  @override
  String get activityHistoryStartedAt => 'Aloitettu';

  @override
  String get activityHistoryEndedAt => 'Päättynyt';

  @override
  String get activityHistoryDurationLabel => 'Kesto';

  @override
  String get activityHistoryDistanceLabel => 'Matka';

  @override
  String get activityHistoryAverageSpeed => 'Keskinopeus';

  @override
  String get activityHistoryPointCount => 'GPS-pisteet';

  @override
  String get activityHistoryUploadStatusLabel => 'Lataus';

  @override
  String get activityHistoryGpxStatus => 'GPX-tiedosto';

  @override
  String get activityHistoryGpxAvailable => 'Tallennettu tälle laitteelle';

  @override
  String get activityHistoryGpxMissing => 'Ei käytettävissä tällä laitteella';

  @override
  String get mapTab => 'Kartta';

  @override
  String get myLocation => 'Oma sijainti';

  @override
  String get settingsTab => 'Asetukset';

  @override
  String get endurainTrademarkNotice =>
      'Endurain® on João Vitória Silvan rekisteröity tavaramerkki.';

  @override
  String get settingsScreen => 'Asetukset';

  @override
  String get deviceAccessTitle => 'Laitteen käyttöoikeus';

  @override
  String get deviceAccessSubtitle =>
      'Hallinnoi sijainti- ja terveystietojen käyttöä';

  @override
  String get deviceAccessLocationSection => 'Sijainti';

  @override
  String get deviceAccessHealthSection => 'Terveystiedot';

  @override
  String get deviceAccessLocationTitle => 'Sijainnin käyttöoikeus';

  @override
  String get deviceAccessHealthTitle => 'Terveystietojen käyttöoikeus';

  @override
  String get deviceAccessChecking => 'Tarkistetaan pääsyä…';

  @override
  String get deviceAccessLocationServicesOff =>
      'Sijaintipalvelut on poistettu käytöstä';

  @override
  String get deviceAccessLocationAlways => 'Sallittu koko ajan';

  @override
  String get deviceAccessLocationWhileUsing =>
      'Sallittu sovellusta käytettäessä';

  @override
  String get deviceAccessLocationBlocked => 'Estetty järjestelmäasetuksissa';

  @override
  String get deviceAccessLocationNotAllowed => 'Ei sallittu';

  @override
  String get deviceAccessHealthUnavailable => 'Ei saatavilla tällä laitteella';

  @override
  String get deviceAccessHealthRequired => 'Health Connect vaaditaan';

  @override
  String get deviceAccessHealthSetUp => 'Terveydenhuoltoon pääsy';

  @override
  String get deviceAccessHealthNeedsAttention => 'Pääsy vaatii huomiota';

  @override
  String get deviceAccessHealthNotConnected => 'Ei yhdistetty';

  @override
  String get language => 'Kieli';

  @override
  String get languageSystemDefault => 'Järjestelmän oletus';

  @override
  String get serverSettings => 'Palvelin';

  @override
  String get signInConnectServer => 'Kirjaudu sisään';

  @override
  String get signInConnectServerSubtitle =>
      'Tallenna offline-tilassa nyt ja synkronoi aktiviteettisi myöhemmin';

  @override
  String get serverSettingsTitle => 'Palvelinasetukset';

  @override
  String connectedToServer(String server) {
    return 'Yhdistetty palvelimeen $server';
  }

  @override
  String get loggedIn => 'Kirjautunut sisään';

  @override
  String get notConfigured => 'Ei määritetty';

  @override
  String get notLoggedIn => 'Ei kirjautunut sisään';

  @override
  String get serverUrl => 'Palvelimen URL-osoite';

  @override
  String get serverProtocol => 'pöytäkirja';

  @override
  String get serverUrlHint => 'https://esimerkki.com';

  @override
  String get warnHttpServerUrlTitle => 'Suojaamaton yhteys';

  @override
  String get warnHttpServerUrlMessage =>
      'Tämä palvelimen URL-osoite käyttää salaamatonta HTTP:tä. Kirjautumistietosi ja tietosi lähetetään salaamattomina. Jatka vain, jos ymmärrät ja hyväksyt riskin.';

  @override
  String get warnHttpServerUrlConfirm => 'Jatka silti';

  @override
  String get tileServerUrl => 'Karttalaattapalvelimen URL-osoite';

  @override
  String get tileServerUrlHint => 'https://tile.openstreetmap.org/...';

  @override
  String get tileServerHostWarningTitle => 'Eri laattapalvelimen isäntä';

  @override
  String get tileServerHostWarningMessage =>
      'Laattapalvelimen isäntä on eri kuin Endurain-palvelimesi isäntä. Laatat ladataan kolmannen osapuolen palvelimelta. Haluatko jatkaa?';

  @override
  String get savedSuccessfully => 'Asetukset tallennettu onnistuneesti';

  @override
  String get diagnostics => 'Diagnostiikka';

  @override
  String get diagnosticsSubtitle => 'Paikallinen kaatumiskonteksti';

  @override
  String get sourceCode => 'GitHub';

  @override
  String get sourceCodeSubtitle => 'github.com/endurain-project';

  @override
  String get openLinkFailed => 'Linkkiä ei voitu avata';

  @override
  String get diagnosticsTitle => 'Diagnostiikka';

  @override
  String get diagnosticsCollection => 'Kerääminen';

  @override
  String get diagnosticsEnable => 'Kerää diagnostiikkaa';

  @override
  String get diagnosticsEnableSubtitle =>
      'Tallenna sovelluksen viimeaikaiset tapahtumat ja virheet tähän laitteeseen';

  @override
  String get diagnosticsDisabled =>
      'Diagnostiikan kerääminen on pois päältä. Ota se käyttöön, jotta sovelluksen tapahtumia ja virheitä aletaan tallentaa tähän laitteeseen.';

  @override
  String get diagnosticsEmpty => 'Diagnostiikkatietoja ei ole vielä kerätty.';

  @override
  String get diagnosticsCopy => 'Kopioi';

  @override
  String get diagnosticsCopied => 'Diagnostiikka kopioitu';

  @override
  String get diagnosticsClear => 'Tyhjennä';

  @override
  String get diagnosticsCleared => 'Diagnostiikka tyhjennetty';

  @override
  String get diagnosticsSummary => 'Yhteenveto';

  @override
  String get diagnosticsLastUpdated => 'Viimeksi päivitetty';

  @override
  String diagnosticsEventsCount(int count) {
    return 'Tapahtumat: $count';
  }

  @override
  String diagnosticsErrorsCount(int count) {
    return 'Virheet: $count';
  }

  @override
  String get diagnosticsEvents => 'Tapahtumat';

  @override
  String get diagnosticsNoEvents => 'Ei kerättyjä tapahtumia';

  @override
  String diagnosticsEventTitle(String event) {
    return 'Tapahtuma: $event';
  }

  @override
  String get diagnosticsErrors => 'Virheet';

  @override
  String diagnosticsErrorTitle(String type) {
    return 'Virhe: $type';
  }

  @override
  String get diagnosticsActions => 'Toiminnot';

  @override
  String get diagnosticsRawReport => 'Raakaraportti';

  @override
  String get healthSyncSettingsTitle => 'Terveyssynkronointi';

  @override
  String get healthSyncSettingsSubtitle =>
      'Tuo harjoitukset terveysalustaltasi';

  @override
  String get healthSyncScreenTitle => 'Terveyssynkronointi';

  @override
  String get healthAccessScreenTitle => 'Terveyden pääsy';

  @override
  String get healthAccessRequestedData => 'Pyydetyt tiedot';

  @override
  String get healthAccessWorkouts => 'Harjoitukset';

  @override
  String get healthAccessWorkoutRoutes => 'Harjoitusreitit';

  @override
  String get healthAccessHeartRate => 'Syke';

  @override
  String get healthAccessWorkoutSummary =>
      'Harjoituksen matka, kalorit ja askeleet';

  @override
  String get healthAccessAllowed => 'Sallittu';

  @override
  String get healthAccessNeedsAttention => 'Vaatii huomiota';

  @override
  String get healthAccessManagedBySystem => 'Hallittu järjestelmäasetuksissa';

  @override
  String get healthAccessSystemManagedNotice =>
      'HealthKit ei paljasta, mitä tietoja Endurain voi lukea. Tarkista pääsy Terveys-sovelluksessa.';

  @override
  String get healthAccessReview => 'Tarkista terveydenhuoltoon pääsy';

  @override
  String get healthAccessReviewIos => 'Käyttöoikeuden tarkistaminen';

  @override
  String get healthAccessDisconnect => 'Katkaise terveystietojen yhteys';

  @override
  String get healthAccessDisconnectTitle =>
      'Katkaistaanko terveystietojen yhteys?';

  @override
  String get healthAccessDisconnectMessage =>
      'Tämän palvelimen automaattinen tuonti ja paikallinen tuontihistoria nollataan. Olemassa olevat aktiviteetit säilyvät historiassa.';

  @override
  String get healthAccessReviewIosInstructions =>
      'Avaa Terveys-sovellus, napauta profiilikuvaasi ja sitten Sovellukset ja palvelut. Valitse Endurain ja päivitä tietoluokat.';

  @override
  String get healthSyncAuthorize => 'Yhdistä terveystietoihin';

  @override
  String get healthSyncInstallProvider => 'Asenna Health Connect';

  @override
  String get healthSyncInstallProviderDescription =>
      'Health Connect tarvitaan harjoitusten synkronoimiseen. Asenna se jatkaaksesi.';

  @override
  String get healthSyncUnsupported =>
      'Terveyssynkronointi ei ole käytettävissä tällä laitteella.';

  @override
  String get healthSyncSelectAll => 'Valitse kaikki';

  @override
  String get healthSyncClearSelection => 'Selkeä';

  @override
  String healthSyncImportSelected(int count) {
    return 'Tuo valitut ($count)';
  }

  @override
  String healthSyncImportedCount(int count) {
    return 'Tuotu $count harjoitusta.';
  }

  @override
  String get healthSyncNoRouteLabel => 'Ei GPS-reittiä';

  @override
  String get healthSyncEmptyState =>
      'Valitulta ajanjaksolta ei löytynyt harjoituksia.';

  @override
  String get healthSyncRouteConsentGuidance =>
      'Jotkut harjoitukset jätettiin väliin, koska harjoitusreitin käyttöoikeutta ei myönnetty. Avaa Health Connect → Permissions ja salli harjoitusreitit Endurainille.';

  @override
  String get healthSyncRouteConsentGuidanceIos =>
      'Jotkut harjoitukset jäivät väliin, koska Endurain ei voinut lukea heidän GPS-reittejään. Avaa Health-sovelluksessa profiilisi, sitten Apps and Services, valitse Endurain ja salli harjoitusreitit.';

  @override
  String get healthSyncReviewAccess => 'Tarkista käyttöoikeudet';

  @override
  String get healthSyncAutoSyncTitle => 'Automaattinen synkronointi jatkuessa';

  @override
  String get healthSyncAutoSyncSubtitle =>
      'Tuo uudet harjoitukset automaattisesti, kun sovellus avautuu.';

  @override
  String get healthSyncNoRoutesExplanation =>
      'Nämä harjoitukset eivät sisällä GPS-reittiä, joten niitä ei voi tuoda. Jotkut sovellukset (kuten Garmin Connect) tallentavat toimintoja Apple Healthille jakamatta reittiä. Apple Watchilla tallennetut harjoitukset sisältävät reittejä ja ne voidaan tuoda.';

  @override
  String get healthSyncBadgeNonImportable => 'Ei tuoda maahan';

  @override
  String get healthSyncViewAvailable => 'Saatavilla';

  @override
  String get healthSyncViewImported => 'Tuodut';

  @override
  String get healthSyncDateRange => 'Harjoitusten aikaväli';

  @override
  String get healthSyncRange30Days => 'Viimeiset 30 päivää';

  @override
  String get healthSyncRange3Months => 'Viimeiset 3 kuukautta';

  @override
  String get healthSyncRange6Months => 'Viimeiset 6 kuukautta';

  @override
  String get healthSyncRangeYear => 'Viime vuosi';

  @override
  String get healthSyncRangeAll => 'Koko historia';

  @override
  String get healthSyncRangeCustom => 'Mukautettu aikaväli';

  @override
  String get healthSyncImportedEmpty =>
      'Tälle yhteydelle ei ole tuotuja harjoituksia.';

  @override
  String healthSyncImportedAt(String dateTime) {
    return 'Tuotu: $dateTime';
  }

  @override
  String get healthSyncRestore => 'Palauta';

  @override
  String get sensorsTitle => 'Anturit';

  @override
  String get sensorsSettingsSubtitle => 'Sykemittarit ja muut ulkoiset anturit';

  @override
  String get sensorsHeartRateSection => 'Syke';

  @override
  String get sensorsHeartRateHelp =>
      'Yhdistä Bluetooth-sykemittari nähdäksesi sykkeesi reaaliajassa.';

  @override
  String get sensorsBluetoothOff =>
      'Bluetooth on pois päältä. Ota se käyttöön yhdistääksesi anturin.';

  @override
  String get sensorsBluetoothUnauthorized =>
      'Salli Bluetooth-käyttöoikeus yhdistääksesi anturin.';

  @override
  String get sensorsBluetoothUnsupported =>
      'Tämä laite ei tue Bluetooth Low Energyä.';

  @override
  String get sensorsScan => 'Etsi antureita';

  @override
  String get sensorsScanning => 'Etsitään…';

  @override
  String get sensorsStopScan => 'Pysäytä';

  @override
  String get sensorsNoDevices => 'Sykeantureita ei löytynyt vielä.';

  @override
  String get sensorsAvailableSection => 'Saatavilla olevat anturit';

  @override
  String get sensorsSavedSection => 'Tallennettu anturi';

  @override
  String get sensorsConnect => 'Yhdistä';

  @override
  String get sensorsConnecting => 'Yhdistetään…';

  @override
  String get sensorsConnected => 'Yhdistetty';

  @override
  String get sensorsDisconnect => 'Katkaise yhteys';

  @override
  String get sensorsForget => 'Unohda';

  @override
  String get sensorsConnectionFailed =>
      'Yhdistäminen epäonnistui. Yritä uudelleen.';

  @override
  String get sensorsPermissionRequired =>
      'Antureiden etsimiseen tarvitaan Bluetooth-lupa.';

  @override
  String get sensorsUnknownDevice => 'Tuntematon anturi';

  @override
  String sensorsBpm(String bpm) {
    return '$bpm bpm';
  }

  @override
  String get sensorsPowerSection => 'Teho';

  @override
  String get sensorsPowerHelp =>
      'Yhdistä Bluetooth-tehomittari nähdäksesi tehosi reaaliajassa.';

  @override
  String get sensorsNoPowerDevices => 'Tehomittareita ei löytynyt vielä.';

  @override
  String sensorsWatts(String watts) {
    return '$watts W';
  }

  @override
  String get sensorsCadenceSection => 'Kadenssi';

  @override
  String get sensorsCadenceHelp =>
      'Yhdistä Bluetooth-kadenssianturi nähdäksesi kadenssisi reaaliajassa.';

  @override
  String get sensorsNoCadenceDevices => 'Kadenssiantureita ei löytynyt vielä.';

  @override
  String sensorsRpm(String rpm) {
    return '$rpm rpm';
  }

  @override
  String get diagnosticsRemoteTitle => 'Etäkaatumisraportointi';

  @override
  String get diagnosticsRemoteEnable => 'Lähetä kaatumisraportteja';

  @override
  String get diagnosticsRemoteEnableSubtitle =>
      'Lähetä kaatumis- ja virheraportteja diagnostiikkapalvelimelle. Tämä on erillään paikallisesta diagnostiikasta; voit ottaa käyttöön molemmat, toisen tai ei kumpaakaan.';

  @override
  String get diagnosticsRemoteActive => 'Crash reports are being sent.';

  @override
  String get diagnosticsRemoteNeedsServer =>
      'Etäkaatumisraportointi ei ole käytettävissä tässä versiossa.';

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
  String get unitsTitle => 'Yksiköt';

  @override
  String get unitsSubtitle => 'Matkan, nopeuden ja korkeuden yksiköt';

  @override
  String get unitsSystemDefault => 'Seuraa laitteen aluetta';

  @override
  String get unitsMetric => 'Metrinen (km)';

  @override
  String get unitsImperial => 'Brittiläinen (mi)';

  @override
  String get errorInsecureRedirectRejected =>
      'The server tried to redirect to an insecure connection. The request was blocked to protect your credentials.';

  @override
  String get errorTooManyRedirects =>
      'The server redirected too many times. Check the server address.';

  @override
  String get audioAnnouncementsTitle => 'Ääni-ilmoitukset';

  @override
  String get audioAnnouncementsSubtitle =>
      'Ääni-ilmoitukset matkasta, ajasta, vauhdista tai nopeudesta';

  @override
  String get audioAnnouncementsMasterSwitch =>
      'Ilmoita harjoituksen edistyminen';

  @override
  String get audioAnnouncementsMasterSwitchSubtitle =>
      'Kertoo ääneen matkasi, aikasi, vauhtisi tai nopeutesi tallennuksen aikana';

  @override
  String get audioAnnouncementsDuckSwitch =>
      'Vaimenna muu ääni puhumisen ajaksi';

  @override
  String get audioAnnouncementsDuckSwitchSubtitle =>
      'Vähentää tilapäisesti muun äänen voimakkuutta jokaisen ilmoituksen aikana';

  @override
  String get audioAnnouncementsIntervalsHeader => 'Ilmoitusväli lajin mukaan';

  @override
  String get audioAnnouncementsByDistance => 'Matka';

  @override
  String get audioAnnouncementsByTime => 'Aika';

  @override
  String audioAnnouncementsIntervalDistance(String value, String unit) {
    return 'Joka $value $unit';
  }

  @override
  String audioAnnouncementsIntervalTime(String minutes) {
    return 'Joka $minutes min';
  }

  @override
  String get audioAnnouncementsDecreaseInterval => 'Pienennä väliä';

  @override
  String get audioAnnouncementsIncreaseInterval => 'Kasvata väliä';

  @override
  String get audioAnnouncementsPreview => 'Kuuntele esimerkki';

  @override
  String get audioAnnouncementsPreviewUnavailable =>
      'Ilmoituksen esikuuntelu ei ole käytettävissä tässä laitteessa';

  @override
  String get audioAnnouncementsAppliesNextRecording =>
      'Muutokset tulevat voimaan seuraavassa tallennuksessa.';

  @override
  String audioAnnouncementsSpokenMessage(
    String distance,
    String duration,
    String lapMetric,
    String overallMetric,
  ) {
    return 'Matka $distance. Aika $duration. Kierros: $lapMetric. Yhteensä: $overallMetric.';
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
}
