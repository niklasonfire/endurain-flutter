// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get error => 'Errore';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get back => 'Indietro';

  @override
  String get requiredField => 'Questo campo è obbligatorio';

  @override
  String get invalidUrl => 'Inserisci un URL valido';

  @override
  String cacheLastUpdated(String time) {
    return 'Ultimo aggiornamento: $time';
  }

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
  String get errorActivityUploadFailed => 'Impossibile caricare l\'attività';

  @override
  String errorActivityUploadFailedWithDetails(String details) {
    return 'Impossibile caricare l\'attività: $details';
  }

  @override
  String get errorActivityIngestionUnsupportedFormat =>
      'Il formato del file non è supportato';

  @override
  String get errorActivityIngestionInvalidFile =>
      'Il file è danneggiato o non è stato possibile leggerlo';

  @override
  String get errorActivityIngestionNoActivitiesFound =>
      'Nessuna attività trovata nel file';

  @override
  String get errorActivityIngestionProcessingFailed =>
      'Si è verificato un errore durante l\'importazione dell\'attività. Riprova.';

  @override
  String get errorActivityIngestionProviderUnavailable =>
      'Il fornitore di attività non è al momento disponibile. Riprova più tardi.';

  @override
  String get errorActivityUploadNotConfigured =>
      'Il caricamento delle attività non è ancora configurato';

  @override
  String get errorActivityGpxCleanupFailed =>
      'Impossibile eliminare il file temporaneo dell\'attività';

  @override
  String get errorActivityGpxFileWriteFailed =>
      'Impossibile preparare il file di caricamento dell\'attività';

  @override
  String get errorActivityLocalActivityNotFound =>
      'Impossibile trovare questa attività locale';

  @override
  String get errorActivityLocalDeleteFailed =>
      'Impossibile eliminare l\'attività locale';

  @override
  String get errorActivityLocalGpxMissing =>
      'Il file GPX locale non è disponibile';

  @override
  String get errorActivityLocalLoadFailed =>
      'Impossibile caricare le attività locali';

  @override
  String get errorActivityLocalRecordInvalid =>
      'Impossibile salvare questa attività';

  @override
  String get errorActivityLocalSaveFailed =>
      'Impossibile salvare l\'attività localmente';

  @override
  String get errorFetchProvidersFailed =>
      'Impossibile caricare i provider di accesso';

  @override
  String errorFetchProvidersFailedWithDetails(String details) {
    return 'Impossibile caricare i provider di accesso: $details';
  }

  @override
  String get errorFetchServerSettingsFailed =>
      'Impossibile caricare le impostazioni del server';

  @override
  String errorFetchServerSettingsFailedWithDetails(String details) {
    return 'Impossibile caricare le impostazioni del server: $details';
  }

  @override
  String get errorHealthGpxBuildFailed =>
      'Impossibile convertire l\'allenamento in GPX';

  @override
  String get errorHealthImportFailed => 'Impossibile importare l\'allenamento';

  @override
  String errorHealthImportFailedWithDetails(String details) {
    return 'Impossibile importare l\'allenamento: $details';
  }

  @override
  String get errorHealthPermissionDenied =>
      'L\'accesso ai dati sanitari è stato negato';

  @override
  String get errorHealthReadFailed => 'Impossibile leggere i dati sanitari';

  @override
  String get errorLoginError => 'Impossibile accedere';

  @override
  String errorLoginErrorWithDetails(String details) {
    return 'Impossibile accedere: $details';
  }

  @override
  String get errorLoginFailed => 'Accesso non riuscito';

  @override
  String errorLoginFailedWithDetails(String details) {
    return 'Accesso non riuscito: $details';
  }

  @override
  String get errorMfaVerificationError =>
      'Impossibile verificare il codice MFA';

  @override
  String errorMfaVerificationErrorWithDetails(String details) {
    return 'Impossibile verificare il codice MFA: $details';
  }

  @override
  String get errorMfaVerificationFailed => 'Verifica MFA non riuscita';

  @override
  String errorMfaVerificationFailedWithDetails(String details) {
    return 'Verifica MFA non riuscita: $details';
  }

  @override
  String get errorNoSessionIdReceived =>
      'Nessun ID di sessione ricevuto dal server';

  @override
  String get errorNotAuthenticated => 'Non hai effettuato l\'accesso';

  @override
  String get errorPkceVerifierMissingRestartLogin =>
      'Verificatore di accesso non trovato. Riavvia l\'accesso.';

  @override
  String get errorServerUrlNotConfigured =>
      'L\'URL del server non è configurato';

  @override
  String get errorInsecureTransportNotAllowed =>
      'Questo server richiede una connessione sicura (HTTPS)';

  @override
  String get errorSessionExpired =>
      'La tua sessione è scaduta. Effettua di nuovo l\'accesso.';

  @override
  String get errorSsoTokenExchangeError =>
      'Impossibile completare l\'accesso SSO';

  @override
  String errorSsoTokenExchangeErrorWithDetails(String details) {
    return 'Impossibile completare l\'accesso SSO: $details';
  }

  @override
  String get errorTokenExchangeFailed => 'Scambio di token non riuscito';

  @override
  String errorTokenExchangeFailedWithDetails(String details) {
    return 'Scambio di token non riuscito: $details';
  }

  @override
  String get errorRequestTimeout =>
      'La richiesta è scaduta. Controlla la connessione e riprova.';

  @override
  String get errorSecureStorageDeleteFailed =>
      'Impossibile eliminare dall\'archivio sicuro. L\'archivio del dispositivo potrebbe non essere disponibile.';

  @override
  String get errorSecureStorageReadFailed =>
      'Impossibile leggere dall\'archivio sicuro. L\'archivio del dispositivo potrebbe non essere disponibile.';

  @override
  String get errorSecureStorageWriteFailed =>
      'Impossibile scrivere nell\'archivio sicuro. L\'archivio del dispositivo potrebbe non essere disponibile.';

  @override
  String get errorUnexpectedResponseFormat =>
      'Il server ha restituito una risposta imprevista';

  @override
  String get errorUnsupportedHttpMethod => 'Metodo HTTP non supportato';

  @override
  String errorUnsupportedHttpMethodWithDetails(String details) {
    return 'Metodo HTTP non supportato: $details';
  }

  @override
  String get loginTitle => 'Accesso';

  @override
  String get login => 'Accedi';

  @override
  String get logout => 'Esci';

  @override
  String get logoutConfirmTitle => 'Esci';

  @override
  String get logoutConfirmMessage => 'Vuoi davvero uscire?';

  @override
  String get logoutServerFailedWarning =>
      'Impossibile uscire dal server, ma disconnessione locale effettuata';

  @override
  String get ssoBrowserLaunchFailed =>
      'Impossibile aprire l\'accesso SSO nel browser di sistema';

  @override
  String ssoSignInWith(String provider) {
    return 'Accedi con $provider';
  }

  @override
  String get ssoOrDivider => 'OPPURE';

  @override
  String get next => 'Avanti';

  @override
  String get username => 'Nome utente';

  @override
  String get usernameHint => 'Inserisci il tuo nome utente';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Inserisci la tua password';

  @override
  String get showPassword => 'Mostra password';

  @override
  String get mfaTitle => 'Autenticazione a due fattori';

  @override
  String get mfaCode => 'Codice MFA';

  @override
  String get mfaCodeHint => 'Inserisci il codice a 6 cifre';

  @override
  String get mfaCodeRequired => 'Inserisci il codice MFA';

  @override
  String get verify => 'Verifica';

  @override
  String get activityDiscard => 'Elimina';

  @override
  String get activityDiscardConfirmMessage =>
      'Questo eliminerà i punti registrati di questa attività.';

  @override
  String get activityDiscardConfirmTitle => 'Eliminare l\'attività?';

  @override
  String get activityLocationPermissionDenied =>
      'L\'autorizzazione alla posizione è necessaria per registrare un\'attività.';

  @override
  String get activityLocationPermissionDeniedForever =>
      'L\'autorizzazione alla posizione è bloccata. Apri le impostazioni per consentire l\'accesso alla posizione.';

  @override
  String get activityLocationServiceDisabled =>
      'I servizi di localizzazione sono disattivati.';

  @override
  String get activityLocationStreamFailed =>
      'Gli aggiornamenti della posizione si sono interrotti in modo imprevisto.';

  @override
  String get activityGpxGenerationFailed =>
      'Impossibile creare il file GPX dell\'attività.';

  @override
  String get activityLocalSaveFailed =>
      'Impossibile salvare questa attività su questo dispositivo.';

  @override
  String get activityOpenSettings => 'Apri impostazioni';

  @override
  String get activityPause => 'Pausa';

  @override
  String get activityRecordingEmpty => 'Nessun punto GPS registrato.';

  @override
  String get activityRecordingFailed => 'Registrazione non riuscita.';

  @override
  String get activityResume => 'Riprendi';

  @override
  String get activityRetryUpload => 'Riprova caricamento';

  @override
  String get activityDone => 'Fatto';

  @override
  String get activityViewHistory => 'Visualizza cronologia';

  @override
  String get activityDeleteLocal => 'Elimina copia locale';

  @override
  String get activityExportGpx => 'Condividi file GPX';

  @override
  String get activityExportGpxSubject => 'GPX attività Endurain';

  @override
  String get activityDeleteLocalConfirmTitle => 'Eliminare l\'attività locale?';

  @override
  String get activityDeleteLocalConfirmMessage =>
      'Questo rimuove il record dell\'attività locale e il file GPX da questo dispositivo.';

  @override
  String get activityStart => 'Avvia';

  @override
  String get activityBackgroundPermissionTitle =>
      'Consentire il tracciamento in background?';

  @override
  String get activityBackgroundPermissionMessage =>
      'Endurain necessita della posizione in background impostata su Sempre affinché la registrazione continui quando l\'app è in background, lo schermo è bloccato o cambi app.';

  @override
  String get activityBackgroundPermissionContinue => 'Continua';

  @override
  String get activityBackgroundPermissionRequired =>
      'Il tracciamento in background su iPhone e iPad richiede la posizione impostata su Sempre.';

  @override
  String get activityBackgroundPermissionSettingsTitle =>
      'Il tracciamento in background è disattivato';

  @override
  String get activityBackgroundPermissionSettingsMessage =>
      'Per registrare in modo affidabile in background o con lo schermo bloccato, apri Impostazioni e imposta la Posizione su Sempre per Endurain.';

  @override
  String get activityTrackingNotificationTitle =>
      'Registrazione dell\'attività';

  @override
  String get activityTrackingNotificationText =>
      'Endurain sta tracciando la tua posizione per registrare questa attività.';

  @override
  String get activityStatDistance => 'Distanza';

  @override
  String get activityStatDuration => 'Tempo';

  @override
  String get activityStatSpeed => 'Velocità';

  @override
  String get activityStatPace => 'Ritmo';

  @override
  String get activityStatMaxSpeed => 'Velocità massima';

  @override
  String get activityStatElevationGain => 'Dislivello positivo';

  @override
  String get activityStatHeartRate => 'Frequenza cardiaca';

  @override
  String get activityStatAvgHeartRate => 'Freq. cardiaca media';

  @override
  String get activityStatPower => 'Potenza';

  @override
  String get activityStatAvgPower => 'Potenza media';

  @override
  String get activityStatCadence => 'Cadenza';

  @override
  String get activityStatAvgCadence => 'Cadenza media';

  @override
  String get activityStop => 'Ferma';

  @override
  String get activityStopAndSave => 'Ferma e salva';

  @override
  String get activityStopConfirmMessage =>
      'Scegli se conservare questa registrazione o eliminarla.';

  @override
  String get activityStopConfirmTitle => 'Terminare l\'attività?';

  @override
  String get activityStopping => 'Arresto in corso';

  @override
  String get activityTypeHike => 'Escursione';

  @override
  String get activityTypeLabel => 'Tipo di attività';

  @override
  String get activityTypeOther => 'Altro';

  @override
  String get activityTypeRide => 'Bici';

  @override
  String get activityTypeRun => 'Corsa';

  @override
  String get activityTypeWalk => 'Camminata';

  @override
  String get activityUploadFailed => 'Caricamento non riuscito';

  @override
  String get activityUploadCleanupFailed => 'Caricato, ma pulizia non riuscita';

  @override
  String get activityUploadReady => 'Pronto per il caricamento';

  @override
  String get activityUploaded => 'Caricato';

  @override
  String get activityUploading => 'Caricamento in corso';

  @override
  String get activityUploadStatusPending => 'In attesa';

  @override
  String get activityUploadStatusUploaded => 'Caricato';

  @override
  String get activityUploadStatusFailed => 'Non riuscito';

  @override
  String get activityHistoryTitle => 'Cronologia attività';

  @override
  String get activityHistorySettingsSubtitle =>
      'Attività completate salvate su questo dispositivo';

  @override
  String get activityRetainUploadedGpx => 'Conserva i file GPX caricati';

  @override
  String get activityRetainUploadedGpxSubtitle =>
      'Salva i file di percorso completati nell\'archivio privato dell\'app dopo il caricamento.';

  @override
  String get activityAutoPauseTitle => 'Pausa automatica';

  @override
  String get activityAutoPauseSubtitle =>
      'Mette in pausa automaticamente quando smetti di muoverti';

  @override
  String get activityAutoPauseToggleLabel => 'Pausa automatica';

  @override
  String get activityAutoPauseToggleDescription =>
      'Mette in pausa la registrazione quando smetti di muoverti e la riprende non appena ricominci a muoverti.';

  @override
  String get activityAutoPauseDelayHelperText =>
      'Scegli per quanto tempo senza movimento attendere prima di mettere in pausa.';

  @override
  String activityAutoPauseDelayOptionLabel(int seconds) {
    return '$seconds secondi';
  }

  @override
  String get activityAutoPausedIndicator => 'In pausa automatica';

  @override
  String get audioAnnouncementsAutoPaused => 'Registrazione in pausa';

  @override
  String get audioAnnouncementsAutoResumed => 'Registrazione ripresa';

  @override
  String get activityHistoryEmpty =>
      'Nessuna attività completata salvata su questo dispositivo.';

  @override
  String get activityHistoryLoadFailed =>
      'Impossibile caricare le attività locali.';

  @override
  String get activityHistoryRefresh => 'Aggiorna';

  @override
  String get activityHistoryLocalActivities => 'Attività locali';

  @override
  String activityHistoryEntryTitle(String activityType, String endedAt) {
    return '$activityType • $endedAt';
  }

  @override
  String activityHistoryDuration(String duration) {
    return 'Durata: $duration';
  }

  @override
  String activityHistoryDistance(String distance) {
    return 'Distanza: $distance';
  }

  @override
  String activityHistoryUploadStatus(String status) {
    return 'Caricamento: $status';
  }

  @override
  String get activityHistoryLoadMore => 'Carica altro';

  @override
  String get activityHistoryDetailsTitle => 'Dettagli attività';

  @override
  String get activityHistoryDetailsMissing =>
      'Questa attività locale non è più disponibile.';

  @override
  String get activityHistorySummary => 'Riepilogo';

  @override
  String get activityHistoryActions => 'Azioni';

  @override
  String get activityHistoryType => 'Tipo';

  @override
  String get activityHistoryStartedAt => 'Inizio';

  @override
  String get activityHistoryEndedAt => 'Fine';

  @override
  String get activityHistoryDurationLabel => 'Durata';

  @override
  String get activityHistoryDistanceLabel => 'Distanza';

  @override
  String get activityHistoryAverageSpeed => 'Velocità media';

  @override
  String get activityHistoryPointCount => 'Punti GPS';

  @override
  String get activityHistoryUploadStatusLabel => 'Caricamento';

  @override
  String get activityHistoryGpxStatus => 'File GPX';

  @override
  String get activityHistoryGpxAvailable => 'Salvato su questo dispositivo';

  @override
  String get activityHistoryGpxMissing =>
      'Non disponibile su questo dispositivo';

  @override
  String get mapTab => 'Mappa';

  @override
  String get myLocation => 'La mia posizione';

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
  String get settingsTab => 'Impostazioni';

  @override
  String get endurainTrademarkNotice =>
      'Endurain® è un marchio registrato di João Vitória Silva';

  @override
  String get settingsScreen => 'Impostazioni';

  @override
  String get settingsClearOfflineData => 'Cancella i dati offline';

  @override
  String get settingsClearOfflineDataSubtitle =>
      'Rimuove la copia offline dei dati del server da questo dispositivo';

  @override
  String get settingsClearOfflineDataConfirmTitle =>
      'Cancellare i dati offline?';

  @override
  String get settingsClearOfflineDataConfirmMessage =>
      'Tutte le copie offline dei dati del server salvate su questo dispositivo verranno rimosse. Nessun dato salvato sul server viene eliminato.';

  @override
  String get settingsClearOfflineDataDone => 'Dati offline cancellati';

  @override
  String get settingsClearOfflineDataFailed =>
      'Impossibile cancellare i dati offline. Riprova.';

  @override
  String get deviceAccessTitle => 'Accesso al dispositivo';

  @override
  String get deviceAccessSubtitle =>
      'Gestisci la posizione e l\'accesso ai dati sanitari';

  @override
  String get deviceAccessLocationSection => 'Posizione';

  @override
  String get deviceAccessHealthSection => 'Dati sanitari';

  @override
  String get deviceAccessLocationTitle => 'Accesso alla posizione';

  @override
  String get deviceAccessHealthTitle => 'Accesso ai dati sanitari';

  @override
  String get deviceAccessChecking => 'Verifica dell\'accesso…';

  @override
  String get deviceAccessLocationServicesOff =>
      'I servizi di localizzazione sono disattivati';

  @override
  String get deviceAccessLocationAlways => 'Permesso tutto il tempo';

  @override
  String get deviceAccessLocationWhileUsing =>
      'Consentito durante l\'utilizzo dell\'app';

  @override
  String get deviceAccessLocationBlocked =>
      'Bloccato nelle impostazioni di sistema';

  @override
  String get deviceAccessLocationNotAllowed => 'Non consentito';

  @override
  String get deviceAccessHealthUnavailable =>
      'Non disponibile su questo dispositivo';

  @override
  String get deviceAccessHealthRequired => 'È richiesto Connessione Salute';

  @override
  String get deviceAccessHealthSetUp => 'Istituito l\'accesso sanitario';

  @override
  String get deviceAccessHealthNeedsAttention =>
      'L\'accesso richiede attenzione';

  @override
  String get deviceAccessHealthNotConnected => 'Non connesso';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystemDefault => 'Predefinita del sistema';

  @override
  String get serverSettings => 'Server';

  @override
  String get signInConnectServer => 'Accedi';

  @override
  String get signInConnectServerSubtitle =>
      'Registra offline ora e sincronizza le tue attività più tardi';

  @override
  String get serverSettingsTitle => 'Impostazioni del server';

  @override
  String connectedToServer(String server) {
    return 'Connesso a $server';
  }

  @override
  String get loggedIn => 'Connesso';

  @override
  String get notConfigured => 'Non configurato';

  @override
  String get notLoggedIn => 'Non connesso';

  @override
  String get serverUrl => 'URL del server';

  @override
  String get serverProtocol => 'Protocollo';

  @override
  String get serverUrlHint => 'https://esempio.com';

  @override
  String get warnHttpServerUrlTitle => 'Connessione non sicura';

  @override
  String get warnHttpServerUrlMessage =>
      'Questo URL del server usa HTTP non cifrato. Le tue credenziali e i tuoi dati saranno trasmessi senza crittografia. Continua solo se comprendi e accetti il rischio.';

  @override
  String get warnHttpServerUrlConfirm => 'Continua comunque';

  @override
  String get tileServerUrl => 'URL del server dei tasselli della mappa';

  @override
  String get tileServerUrlHint => 'https://tile.openstreetmap.org/...';

  @override
  String get tileServerHostWarningTitle =>
      'Host del server dei tasselli diverso';

  @override
  String get tileServerHostWarningMessage =>
      'L\'host del server dei tasselli è diverso dall\'host del tuo server Endurain. I tasselli saranno caricati da un server di terze parti. Vuoi continuare?';

  @override
  String get savedSuccessfully => 'Impostazioni salvate correttamente';

  @override
  String get diagnostics => 'Diagnostica';

  @override
  String get diagnosticsSubtitle => 'Contesto locale degli arresti anomali';

  @override
  String get sourceCode => 'GitHub';

  @override
  String get sourceCodeSubtitle => 'github.com/endurain-project';

  @override
  String get openLinkFailed => 'Impossibile aprire il collegamento';

  @override
  String get diagnosticsTitle => 'Diagnostica';

  @override
  String get diagnosticsCollection => 'Raccolta';

  @override
  String get diagnosticsEnable => 'Raccogli diagnostica';

  @override
  String get diagnosticsEnableSubtitle =>
      'Memorizza gli eventi e gli errori recenti dell\'app su questo dispositivo';

  @override
  String get diagnosticsDisabled =>
      'La raccolta della diagnostica è disattivata. Attivala per iniziare a registrare eventi ed errori dell\'app su questo dispositivo.';

  @override
  String get diagnosticsEmpty => 'Nessun dato diagnostico ancora acquisito.';

  @override
  String get diagnosticsCopy => 'Copia';

  @override
  String get diagnosticsCopied => 'Diagnostica copiata';

  @override
  String get diagnosticsClear => 'Cancella';

  @override
  String get diagnosticsCleared => 'Diagnostica cancellata';

  @override
  String get diagnosticsSummary => 'Riepilogo';

  @override
  String get diagnosticsLastUpdated => 'Ultimo aggiornamento';

  @override
  String diagnosticsEventsCount(int count) {
    return 'Eventi: $count';
  }

  @override
  String diagnosticsErrorsCount(int count) {
    return 'Errori: $count';
  }

  @override
  String get diagnosticsEvents => 'Eventi';

  @override
  String get diagnosticsNoEvents => 'Nessun evento acquisito';

  @override
  String diagnosticsEventTitle(String event) {
    return 'Evento: $event';
  }

  @override
  String get diagnosticsErrors => 'Errori';

  @override
  String diagnosticsErrorTitle(String type) {
    return 'Errore: $type';
  }

  @override
  String get diagnosticsActions => 'Azioni';

  @override
  String get diagnosticsRawReport => 'Report non elaborato';

  @override
  String get healthSyncSettingsTitle => 'Sincronizzazione della salute';

  @override
  String get healthSyncSettingsSubtitle =>
      'Importa allenamenti dalla tua piattaforma sanitaria';

  @override
  String get healthSyncScreenTitle => 'Sincronizzazione della salute';

  @override
  String get healthAccessScreenTitle => 'Accesso alla sanità';

  @override
  String get healthAccessRequestedData => 'Dati richiesti';

  @override
  String get healthAccessWorkouts => 'Allenamenti';

  @override
  String get healthAccessWorkoutRoutes => 'Percorsi di allenamento';

  @override
  String get healthAccessHeartRate => 'Frequenza cardiaca';

  @override
  String get healthAccessWorkoutSummary =>
      'Distanza, calorie e passi dell\'allenamento';

  @override
  String get healthAccessAllowed => 'Consentito';

  @override
  String get healthAccessNeedsAttention => 'Ha bisogno di attenzione';

  @override
  String get healthAccessManagedBySystem =>
      'Gestito nelle impostazioni di sistema';

  @override
  String get healthAccessSystemManagedNotice =>
      'HealthKit non rivela quali dati Endurain può leggere. Controlla l\'accesso nell\'app Salute.';

  @override
  String get healthAccessReview => 'Rivedere l\'accesso sanitario';

  @override
  String get healthAccessReviewIos => 'Come verificare l\'accesso';

  @override
  String get healthAccessDisconnect => 'Disconnetti i dati sanitari';

  @override
  String get healthAccessDisconnectTitle => 'Disconnettere i dati sanitari?';

  @override
  String get healthAccessDisconnectMessage =>
      'L\'importazione automatica e la cronologia locale delle importazioni per questo server verranno reimpostate. Le attività esistenti rimarranno nella cronologia.';

  @override
  String get healthAccessReviewIosInstructions =>
      'Apri l\'app Salute, tocca la tua immagine del profilo, quindi App e servizi. Seleziona Endurain e aggiorna le categorie di dati.';

  @override
  String get healthSyncAuthorize => 'Connettiti ai dati sanitari';

  @override
  String get healthSyncInstallProvider => 'Installa Connessione Salute';

  @override
  String get healthSyncInstallProviderDescription =>
      'Per sincronizzare gli allenamenti è necessario Health Connect. Installalo per continuare.';

  @override
  String get healthSyncUnsupported =>
      'La sincronizzazione della salute non è disponibile su questo dispositivo.';

  @override
  String get healthSyncSelectAll => 'Seleziona tutto';

  @override
  String get healthSyncClearSelection => 'Chiaro';

  @override
  String healthSyncImportSelected(int count) {
    return 'Importa selezionata ($count)';
  }

  @override
  String healthSyncImportedCount(int count) {
    return '$count allenamento/i importati/i.';
  }

  @override
  String get healthSyncNoRouteLabel => 'Nessun percorso GPS';

  @override
  String get healthSyncEmptyState =>
      'Nessun allenamento trovato nell\'intervallo selezionato.';

  @override
  String get healthSyncRouteConsentGuidance =>
      'Alcuni allenamenti sono stati saltati perché non è stato concesso l\'accesso al percorso di allenamento. Apri Health Connect → Autorizzazioni e consenti percorsi di allenamento per Endurain.';

  @override
  String get healthSyncRouteConsentGuidanceIos =>
      'Alcuni allenamenti sono stati saltati perché Endurain non riusciva a leggere i percorsi GPS. Nell\'app Salute, apri il tuo profilo, quindi App e servizi, seleziona Endurain e consenti Percorsi di allenamento.';

  @override
  String get healthSyncReviewAccess => 'Controlla l\'accesso';

  @override
  String get healthSyncAutoSyncTitle =>
      'Sincronizzazione automatica al ripristino';

  @override
  String get healthSyncAutoSyncSubtitle =>
      'Importa automaticamente nuovi allenamenti all\'apertura dell\'app.';

  @override
  String get healthSyncNoRoutesExplanation =>
      'Questi allenamenti non includono un percorso GPS, quindi non possono essere importati. Alcune app (come Garmin Connect) registrano le attività su Apple Health senza condividere il percorso. Gli allenamenti registrati con Apple Watch includono percorsi e possono essere importati.';

  @override
  String get healthSyncBadgeNonImportable => 'Non importabile';

  @override
  String get healthSyncViewAvailable => 'Disponibili';

  @override
  String get healthSyncViewImported => 'Importati';

  @override
  String get healthSyncDateRange => 'Periodo allenamenti';

  @override
  String get healthSyncRange30Days => 'Ultimi 30 giorni';

  @override
  String get healthSyncRange3Months => 'Ultimi 3 mesi';

  @override
  String get healthSyncRange6Months => 'Ultimi 6 mesi';

  @override
  String get healthSyncRangeYear => 'Ultimo anno';

  @override
  String get healthSyncRangeAll => 'Tutta la cronologia';

  @override
  String get healthSyncRangeCustom => 'Periodo personalizzato';

  @override
  String get healthSyncImportedEmpty =>
      'Nessun allenamento importato per questa connessione.';

  @override
  String healthSyncImportedAt(String dateTime) {
    return 'Importato: $dateTime';
  }

  @override
  String get healthSyncRestore => 'Ripristina';

  @override
  String get sensorsTitle => 'Sensori';

  @override
  String get sensorsSettingsSubtitle =>
      'Cardiofrequenzimetri e altri sensori esterni';

  @override
  String get sensorsHeartRateSection => 'Frequenza cardiaca';

  @override
  String get sensorsHeartRateHelp =>
      'Abbina un cardiofrequenzimetro Bluetooth per vedere la frequenza cardiaca in tempo reale.';

  @override
  String get sensorsBluetoothOff =>
      'Il Bluetooth è disattivato. Attivalo per connettere un sensore.';

  @override
  String get sensorsBluetoothUnauthorized =>
      'Consenti l\'accesso al Bluetooth per connettere un sensore.';

  @override
  String get sensorsBluetoothUnsupported =>
      'Questo dispositivo non supporta il Bluetooth Low Energy.';

  @override
  String get sensorsScan => 'Cerca sensori';

  @override
  String get sensorsScanning => 'Ricerca…';

  @override
  String get sensorsStopScan => 'Ferma';

  @override
  String get sensorsNoDevices =>
      'Nessun sensore di frequenza cardiaca trovato.';

  @override
  String get sensorsAvailableSection => 'Sensori disponibili';

  @override
  String get sensorsSavedSection => 'Sensore salvato';

  @override
  String get sensorsConnect => 'Connetti';

  @override
  String get sensorsConnecting => 'Connessione…';

  @override
  String get sensorsConnected => 'Connesso';

  @override
  String get sensorsDisconnect => 'Disconnetti';

  @override
  String get sensorsForget => 'Dimentica';

  @override
  String get sensorsConnectionFailed => 'Connessione non riuscita. Riprova.';

  @override
  String get sensorsPermissionRequired =>
      'È necessaria l\'autorizzazione Bluetooth per trovare i sensori.';

  @override
  String get sensorsUnknownDevice => 'Sensore sconosciuto';

  @override
  String sensorsBpm(String bpm) {
    return '$bpm bpm';
  }

  @override
  String get sensorsPowerSection => 'Potenza';

  @override
  String get sensorsPowerHelp =>
      'Abbina un misuratore di potenza Bluetooth per vedere la potenza in tempo reale.';

  @override
  String get sensorsNoPowerDevices => 'Nessun misuratore di potenza trovato.';

  @override
  String sensorsWatts(String watts) {
    return '$watts W';
  }

  @override
  String get sensorsCadenceSection => 'Cadenza';

  @override
  String get sensorsCadenceHelp =>
      'Abbina un sensore di cadenza Bluetooth per vedere la cadenza in tempo reale.';

  @override
  String get sensorsNoCadenceDevices => 'Nessun sensore di cadenza trovato.';

  @override
  String sensorsRpm(String rpm) {
    return '$rpm rpm';
  }

  @override
  String get diagnosticsRemoteTitle => 'Segnalazione arresti anomali da remoto';

  @override
  String get diagnosticsRemoteEnable => 'Invia segnalazioni di arresto anomalo';

  @override
  String get diagnosticsRemoteEnableSubtitle =>
      'Invia segnalazioni di arresti anomali ed errori a un server di diagnostica. È indipendente dalla diagnostica locale; puoi attivare entrambe, una o nessuna.';

  @override
  String get diagnosticsRemoteActive => 'Crash reports are being sent.';

  @override
  String get diagnosticsRemoteNeedsServer =>
      'La segnalazione di arresti anomali da remoto non è disponibile in questa versione.';

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
  String get unitsTitle => 'Unità';

  @override
  String get unitsSubtitle => 'Unità di distanza, velocità e altitudine';

  @override
  String get unitsSystemDefault => 'Segui la regione del dispositivo';

  @override
  String get unitsMetric => 'Metrico (km)';

  @override
  String get unitsImperial => 'Imperiale (mi)';

  @override
  String get errorInsecureRedirectRejected =>
      'Il server ha tentato di reindirizzare a una connessione non sicura. La richiesta è stata bloccata per proteggere le tue credenziali.';

  @override
  String get errorTooManyRedirects =>
      'Il server ha reindirizzato troppe volte. Controlla l\'indirizzo del server.';

  @override
  String get audioAnnouncementsTitle => 'Annunci vocali';

  @override
  String get audioAnnouncementsSubtitle =>
      'Aggiornamenti vocali su distanza, tempo, ritmo o velocità';

  @override
  String get audioAnnouncementsMasterSwitch =>
      'Annuncia i progressi dell\'attività';

  @override
  String get audioAnnouncementsMasterSwitchSubtitle =>
      'Annuncia a voce la distanza, il tempo, il ritmo o la velocità durante una registrazione';

  @override
  String get audioAnnouncementsDuckSwitch =>
      'Abbassa altri audio durante l\'annuncio';

  @override
  String get audioAnnouncementsDuckSwitchSubtitle =>
      'Riduce temporaneamente il volume di altri audio durante ogni annuncio';

  @override
  String get audioAnnouncementsIntervalsHeader =>
      'Intervallo di annuncio per attività';

  @override
  String get audioAnnouncementsByDistance => 'Distanza';

  @override
  String get audioAnnouncementsByTime => 'Tempo';

  @override
  String audioAnnouncementsIntervalDistance(String value, String unit) {
    return 'Ogni $value $unit';
  }

  @override
  String audioAnnouncementsIntervalTime(String minutes) {
    return 'Ogni $minutes min';
  }

  @override
  String get audioAnnouncementsDecreaseInterval => 'Riduci intervallo';

  @override
  String get audioAnnouncementsIncreaseInterval => 'Aumenta intervallo';

  @override
  String get audioAnnouncementsPreview => 'Ascolta un esempio';

  @override
  String get audioAnnouncementsPreviewUnavailable =>
      'L\'anteprima dell\'annuncio non è disponibile su questo dispositivo';

  @override
  String get audioAnnouncementsAppliesNextRecording =>
      'Le modifiche si applicano alla prossima registrazione.';

  @override
  String audioAnnouncementsSpokenMessage(
    String distance,
    String duration,
    String lapMetric,
    String overallMetric,
  ) {
    return 'Distanza $distance. Tempo $duration. Giro: $lapMetric. Complessivo: $overallMetric.';
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
