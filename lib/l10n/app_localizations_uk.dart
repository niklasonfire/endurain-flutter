// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get error => 'Помилка';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get back => 'Назад';

  @override
  String get requiredField => 'Це поле обов\'язкове';

  @override
  String get invalidUrl => 'Введіть дійсний URL';

  @override
  String get errorActivityUploadFailed => 'Не вдалося завантажити активність';

  @override
  String errorActivityUploadFailedWithDetails(String details) {
    return 'Не вдалося завантажити активність: $details';
  }

  @override
  String get errorActivityUploadNotConfigured =>
      'Завантаження активностей ще не налаштовано';

  @override
  String get errorActivityGpxCleanupFailed =>
      'Не вдалося видалити тимчасовий файл активності';

  @override
  String get errorActivityGpxFileWriteFailed =>
      'Не вдалося підготувати файл для завантаження активності';

  @override
  String get errorActivityLocalActivityNotFound =>
      'Не вдалося знайти цю локальну активність';

  @override
  String get errorActivityLocalDeleteFailed =>
      'Не вдалося видалити локальну активність';

  @override
  String get errorActivityLocalGpxMissing => 'Локальний файл GPX недоступний';

  @override
  String get errorActivityLocalLoadFailed =>
      'Не вдалося завантажити локальні активності';

  @override
  String get errorActivityLocalRecordInvalid =>
      'Не вдалося зберегти цю активність';

  @override
  String get errorActivityLocalSaveFailed =>
      'Не вдалося зберегти активність локально';

  @override
  String get errorFetchProvidersFailed =>
      'Не вдалося завантажити постачальників входу';

  @override
  String errorFetchProvidersFailedWithDetails(String details) {
    return 'Не вдалося завантажити постачальників входу: $details';
  }

  @override
  String get errorFetchServerSettingsFailed =>
      'Не вдалося завантажити налаштування сервера';

  @override
  String errorFetchServerSettingsFailedWithDetails(String details) {
    return 'Не вдалося завантажити налаштування сервера: $details';
  }

  @override
  String get errorHealthGpxBuildFailed =>
      'Не вдалося конвертувати тренування в GPX';

  @override
  String get errorHealthImportFailed => 'Не вдалося імпортувати тренування';

  @override
  String errorHealthImportFailedWithDetails(String details) {
    return 'Не вдалося імпортувати тренування: $details';
  }

  @override
  String get errorHealthPermissionDenied =>
      'У доступі до даних про здоров’я відмовлено';

  @override
  String get errorHealthReadFailed =>
      'Не вдалося прочитати дані про стан здоров\'я';

  @override
  String get errorLoginError => 'Не вдалося увійти';

  @override
  String errorLoginErrorWithDetails(String details) {
    return 'Не вдалося увійти: $details';
  }

  @override
  String get errorLoginFailed => 'Помилка входу';

  @override
  String errorLoginFailedWithDetails(String details) {
    return 'Помилка входу: $details';
  }

  @override
  String get errorMfaVerificationError => 'Не вдалося перевірити код MFA';

  @override
  String errorMfaVerificationErrorWithDetails(String details) {
    return 'Не вдалося перевірити код MFA: $details';
  }

  @override
  String get errorMfaVerificationFailed => 'Помилка перевірки MFA';

  @override
  String errorMfaVerificationFailedWithDetails(String details) {
    return 'Помилка перевірки MFA: $details';
  }

  @override
  String get errorNoSessionIdReceived =>
      'Сервер не повернув ідентифікатор сеансу';

  @override
  String get errorNotAuthenticated => 'Ви не ввійшли';

  @override
  String get errorPkceVerifierMissingRestartLogin =>
      'Верифікатор входу не знайдено. Почніть вхід знову.';

  @override
  String get errorServerUrlNotConfigured => 'URL сервера не налаштовано';

  @override
  String get errorInsecureTransportNotAllowed =>
      'Цей сервер потребує безпечного (HTTPS) з\'єднання';

  @override
  String get errorSessionExpired => 'Ваш сеанс завершився. Увійдіть знову.';

  @override
  String get errorSsoTokenExchangeError =>
      'Не вдалося завершити вхід через SSO';

  @override
  String errorSsoTokenExchangeErrorWithDetails(String details) {
    return 'Не вдалося завершити вхід через SSO: $details';
  }

  @override
  String get errorTokenExchangeFailed => 'Помилка обміну токенів';

  @override
  String errorTokenExchangeFailedWithDetails(String details) {
    return 'Помилка обміну токенів: $details';
  }

  @override
  String get errorRequestTimeout =>
      'Час очікування запиту вичерпано. Перевірте з\'єднання й повторіть спробу.';

  @override
  String get errorSecureStorageDeleteFailed =>
      'Не вдалося видалити з безпечного сховища. Сховище пристрою може бути недоступним.';

  @override
  String get errorSecureStorageReadFailed =>
      'Не вдалося прочитати з безпечного сховища. Сховище пристрою може бути недоступним.';

  @override
  String get errorSecureStorageWriteFailed =>
      'Не вдалося записати в безпечне сховище. Сховище пристрою може бути недоступним.';

  @override
  String get errorUnexpectedResponseFormat =>
      'Сервер повернув неочікувану відповідь';

  @override
  String get errorUnsupportedHttpMethod => 'Непідтримуваний метод HTTP';

  @override
  String errorUnsupportedHttpMethodWithDetails(String details) {
    return 'Непідтримуваний метод HTTP: $details';
  }

  @override
  String get loginTitle => 'Вхід';

  @override
  String get login => 'Увійти';

  @override
  String get logout => 'Вийти';

  @override
  String get logoutConfirmTitle => 'Вийти';

  @override
  String get logoutConfirmMessage => 'Ви впевнені, що хочете вийти?';

  @override
  String get logoutServerFailedWarning =>
      'Не вдалося вийти із сервера, але вихід виконано локально';

  @override
  String get ssoBrowserLaunchFailed =>
      'Не вдалося відкрити вхід через SSO у системному браузері';

  @override
  String ssoSignInWith(String provider) {
    return 'Увійти через $provider';
  }

  @override
  String get ssoOrDivider => 'АБО';

  @override
  String get next => 'Далі';

  @override
  String get username => 'Ім\'я користувача';

  @override
  String get usernameHint => 'Введіть своє ім\'я користувача';

  @override
  String get password => 'Пароль';

  @override
  String get passwordHint => 'Введіть свій пароль';

  @override
  String get showPassword => 'Показати пароль';

  @override
  String get mfaTitle => 'Двофакторна автентифікація';

  @override
  String get mfaCode => 'Код MFA';

  @override
  String get mfaCodeHint => 'Введіть 6-значний код';

  @override
  String get mfaCodeRequired => 'Введіть код MFA';

  @override
  String get verify => 'Перевірити';

  @override
  String get activityDiscard => 'Відхилити';

  @override
  String get activityDiscardConfirmMessage =>
      'Це видалить записані точки цієї активності.';

  @override
  String get activityDiscardConfirmTitle => 'Відхилити активність?';

  @override
  String get activityLocationPermissionDenied =>
      'Для запису активності потрібен дозвіл на доступ до геопозиції.';

  @override
  String get activityLocationPermissionDeniedForever =>
      'Дозвіл на геопозицію заблоковано. Відкрийте налаштування, щоб дозволити доступ до геопозиції.';

  @override
  String get activityLocationServiceDisabled => 'Служби геопозиції вимкнено.';

  @override
  String get activityLocationStreamFailed =>
      'Оновлення геопозиції несподівано припинилися.';

  @override
  String get activityGpxGenerationFailed =>
      'Не вдалося створити файл GPX активності.';

  @override
  String get activityLocalSaveFailed =>
      'Не вдалося зберегти цю активність на цьому пристрої.';

  @override
  String get activityOpenSettings => 'Відкрити налаштування';

  @override
  String get activityPause => 'Пауза';

  @override
  String get activityRecordingEmpty => 'Жодної точки GPS не записано.';

  @override
  String get activityRecordingFailed => 'Помилка запису.';

  @override
  String get activityResume => 'Продовжити';

  @override
  String get activityRetryUpload => 'Повторити завантаження';

  @override
  String get activityDone => 'Готово';

  @override
  String get activityViewHistory => 'Переглянути історію';

  @override
  String get activityDeleteLocal => 'Видалити локальну копію';

  @override
  String get activityExportGpx => 'Поділитися файлом GPX';

  @override
  String get activityExportGpxSubject => 'GPX активності Endurain';

  @override
  String get activityDeleteLocalConfirmTitle => 'Видалити локальну активність?';

  @override
  String get activityDeleteLocalConfirmMessage =>
      'Це видалить запис локальної активності та файл GPX із цього пристрою.';

  @override
  String get activityStart => 'Почати';

  @override
  String get activityBackgroundPermissionTitle =>
      'Дозволити відстеження у фоновому режимі?';

  @override
  String get activityBackgroundPermissionMessage =>
      'Endurain потребує, щоб фонова геопозиція була встановлена на «Завжди», щоб запис тривав, коли застосунок у фоні, екран заблоковано або ви перемикаєте застосунки.';

  @override
  String get activityBackgroundPermissionContinue => 'Продовжити';

  @override
  String get activityBackgroundPermissionRequired =>
      'Відстеження у фоновому режимі на iPhone та iPad потребує геопозиції, встановленої на «Завжди».';

  @override
  String get activityBackgroundPermissionSettingsTitle =>
      'Фонове відстеження вимкнено';

  @override
  String get activityBackgroundPermissionSettingsMessage =>
      'Щоб надійно записувати у фоновому режимі або із заблокованим екраном, відкрийте Налаштування та встановіть Геопозицію на «Завжди» для Endurain.';

  @override
  String get activityTrackingNotificationTitle => 'Запис активності';

  @override
  String get activityTrackingNotificationText =>
      'Endurain відстежує вашу геопозицію, щоб записати цю активність.';

  @override
  String get activityStatDistance => 'Відстань';

  @override
  String get activityStatDuration => 'Час';

  @override
  String get activityStatSpeed => 'Швидкість';

  @override
  String get activityStatPace => 'Темп';

  @override
  String get activityStatMaxSpeed => 'Макс. швидкість';

  @override
  String get activityStatElevationGain => 'Набір висоти';

  @override
  String get activityStatHeartRate => 'Пульс';

  @override
  String get activityStatAvgHeartRate => 'Сер. пульс';

  @override
  String get activityStatPower => 'Потужність';

  @override
  String get activityStatAvgPower => 'Сер. потужність';

  @override
  String get activityStatCadence => 'Каденс';

  @override
  String get activityStatAvgCadence => 'Сер. каденс';

  @override
  String get activityStop => 'Зупинити';

  @override
  String get activityStopAndSave => 'Зупинити та зберегти';

  @override
  String get activityStopConfirmMessage =>
      'Виберіть, чи зберегти цей запис, чи відхилити його.';

  @override
  String get activityStopConfirmTitle => 'Завершити активність?';

  @override
  String get activityStopping => 'Зупинка';

  @override
  String get activityTypeHike => 'Похід';

  @override
  String get activityTypeLabel => 'Тип активності';

  @override
  String get activityTypeOther => 'Інше';

  @override
  String get activityTypeRide => 'Велосипед';

  @override
  String get activityTypeRun => 'Біг';

  @override
  String get activityTypeWalk => 'Ходьба';

  @override
  String get activityUploadFailed => 'Помилка завантаження';

  @override
  String get activityUploadCleanupFailed =>
      'Завантажено, але не вдалося очистити';

  @override
  String get activityUploadReady => 'Готово до завантаження';

  @override
  String get activityUploaded => 'Завантажено';

  @override
  String get activityUploading => 'Завантаження';

  @override
  String get activityUploadStatusPending => 'Очікує';

  @override
  String get activityUploadStatusUploaded => 'Завантажено';

  @override
  String get activityUploadStatusFailed => 'Не вдалося';

  @override
  String get activityHistoryTitle => 'Історія активностей';

  @override
  String get activityHistorySettingsSubtitle =>
      'Завершені активності, збережені на цьому пристрої';

  @override
  String get activityRetainUploadedGpx => 'Зберігати завантажені файли GPX';

  @override
  String get activityRetainUploadedGpxSubtitle =>
      'Зберігає завершені файли маршрутів у приватному сховищі застосунку після завантаження.';

  @override
  String get activityHistoryEmpty =>
      'На цьому пристрої немає збережених завершених активностей.';

  @override
  String get activityHistoryLoadFailed =>
      'Не вдалося завантажити локальні активності.';

  @override
  String get activityHistoryRefresh => 'Оновити';

  @override
  String get activityHistoryLocalActivities => 'Локальні активності';

  @override
  String activityHistoryEntryTitle(String activityType, String endedAt) {
    return '$activityType • $endedAt';
  }

  @override
  String activityHistoryDuration(String duration) {
    return 'Тривалість: $duration';
  }

  @override
  String activityHistoryDistance(String distance) {
    return 'Відстань: $distance';
  }

  @override
  String activityHistoryUploadStatus(String status) {
    return 'Завантаження: $status';
  }

  @override
  String get activityHistoryLoadMore => 'Завантажити ще';

  @override
  String get activityHistoryDetailsTitle => 'Деталі активності';

  @override
  String get activityHistoryDetailsMissing =>
      'Ця локальна активність більше недоступна.';

  @override
  String get activityHistorySummary => 'Підсумок';

  @override
  String get activityHistoryActions => 'Дії';

  @override
  String get activityHistoryType => 'Тип';

  @override
  String get activityHistoryStartedAt => 'Початок';

  @override
  String get activityHistoryEndedAt => 'Завершення';

  @override
  String get activityHistoryDurationLabel => 'Тривалість';

  @override
  String get activityHistoryDistanceLabel => 'Відстань';

  @override
  String get activityHistoryAverageSpeed => 'Середня швидкість';

  @override
  String get activityHistoryPointCount => 'Точки GPS';

  @override
  String get activityHistoryUploadStatusLabel => 'Завантаження';

  @override
  String get activityHistoryGpxStatus => 'Файл GPX';

  @override
  String get activityHistoryGpxAvailable => 'Збережено на цьому пристрої';

  @override
  String get activityHistoryGpxMissing => 'Недоступно на цьому пристрої';

  @override
  String get mapTab => 'Мапа';

  @override
  String get myLocation => 'Моє місцеположення';

  @override
  String get settingsTab => 'Налаштування';

  @override
  String get endurainTrademarkNotice =>
      'Endurain® є зареєстрованою торговельною маркою João Vitória Silva';

  @override
  String get settingsScreen => 'Налаштування';

  @override
  String get deviceAccessTitle => 'Доступ до пристрою';

  @override
  String get deviceAccessSubtitle =>
      'Керуйте доступом до даних про місцезнаходження та здоров’я';

  @override
  String get deviceAccessLocationSection => 'Розташування';

  @override
  String get deviceAccessHealthSection => 'Дані про здоров\'я';

  @override
  String get deviceAccessLocationTitle => 'Доступ до місцезнаходження';

  @override
  String get deviceAccessHealthTitle => 'Доступ до даних про здоров\'я';

  @override
  String get deviceAccessChecking => 'Перевірка доступу…';

  @override
  String get deviceAccessLocationServicesOff => 'Служби локації вимкнено';

  @override
  String get deviceAccessLocationAlways => 'Дозволено весь час';

  @override
  String get deviceAccessLocationWhileUsing =>
      'Дозволено під час використання програми';

  @override
  String get deviceAccessLocationBlocked =>
      'Заблоковано в системних налаштуваннях';

  @override
  String get deviceAccessLocationNotAllowed => 'Не допускається';

  @override
  String get deviceAccessHealthUnavailable => 'Недоступно на цьому пристрої';

  @override
  String get deviceAccessHealthRequired => 'Потрібен Health Connect';

  @override
  String get deviceAccessHealthSetUp => 'Оздоровчий доступ налаштований';

  @override
  String get deviceAccessHealthNeedsAttention => 'Доступ потребує уваги';

  @override
  String get deviceAccessHealthNotConnected => 'Не підключено';

  @override
  String get language => 'Мова';

  @override
  String get languageSystemDefault => 'Системна за замовчуванням';

  @override
  String get serverSettings => 'Сервер';

  @override
  String get signInConnectServer => 'Увійти';

  @override
  String get signInConnectServerSubtitle =>
      'Записуйте офлайн зараз і синхронізуйте активності пізніше';

  @override
  String get serverSettingsTitle => 'Налаштування сервера';

  @override
  String connectedToServer(String server) {
    return 'Підключено до $server';
  }

  @override
  String get loggedIn => 'Ви ввійшли';

  @override
  String get notConfigured => 'Не налаштовано';

  @override
  String get notLoggedIn => 'Ви не ввійшли';

  @override
  String get serverUrl => 'URL сервера';

  @override
  String get serverProtocol => 'Протокол';

  @override
  String get serverUrlHint => 'https://example.com';

  @override
  String get warnHttpServerUrlTitle => 'Незахищене з\'єднання';

  @override
  String get warnHttpServerUrlMessage =>
      'Цей URL сервера використовує звичайний HTTP. Ваші облікові дані та дані передаватимуться без шифрування. Продовжуйте, лише якщо ви розумієте й приймаєте ризик.';

  @override
  String get warnHttpServerUrlConfirm => 'Усе одно продовжити';

  @override
  String get tileServerUrl => 'URL сервера картографічних плиток';

  @override
  String get tileServerUrlHint => 'https://tile.openstreetmap.org/...';

  @override
  String get tileServerHostWarningTitle => 'Інший хост сервера плиток';

  @override
  String get tileServerHostWarningMessage =>
      'Хост сервера плиток відрізняється від хоста вашого сервера Endurain. Плитки завантажуватимуться зі стороннього сервера. Продовжити?';

  @override
  String get savedSuccessfully => 'Налаштування успішно збережено';

  @override
  String get diagnostics => 'Діагностика';

  @override
  String get diagnosticsSubtitle => 'Локальний контекст збоїв';

  @override
  String get sourceCode => 'GitHub';

  @override
  String get sourceCodeSubtitle => 'github.com/endurain-project';

  @override
  String get openLinkFailed => 'Не вдалося відкрити посилання';

  @override
  String get diagnosticsTitle => 'Діагностика';

  @override
  String get diagnosticsCollection => 'Збір';

  @override
  String get diagnosticsEnable => 'Збирати діагностику';

  @override
  String get diagnosticsEnableSubtitle =>
      'Зберігати останні події та помилки застосунку на цьому пристрої';

  @override
  String get diagnosticsDisabled =>
      'Збір діагностики вимкнено. Увімкніть його, щоб почати фіксувати події та помилки застосунку на цьому пристрої.';

  @override
  String get diagnosticsEmpty => 'Ще не зібрано жодних діагностичних даних.';

  @override
  String get diagnosticsCopy => 'Копіювати';

  @override
  String get diagnosticsCopied => 'Діагностику скопійовано';

  @override
  String get diagnosticsClear => 'Очистити';

  @override
  String get diagnosticsCleared => 'Діагностику очищено';

  @override
  String get diagnosticsSummary => 'Підсумок';

  @override
  String get diagnosticsLastUpdated => 'Останнє оновлення';

  @override
  String diagnosticsEventsCount(int count) {
    return 'Події: $count';
  }

  @override
  String diagnosticsErrorsCount(int count) {
    return 'Помилки: $count';
  }

  @override
  String get diagnosticsEvents => 'Події';

  @override
  String get diagnosticsNoEvents => 'Подій не зафіксовано';

  @override
  String diagnosticsEventTitle(String event) {
    return 'Подія: $event';
  }

  @override
  String get diagnosticsErrors => 'Помилки';

  @override
  String diagnosticsErrorTitle(String type) {
    return 'Помилка: $type';
  }

  @override
  String get diagnosticsActions => 'Дії';

  @override
  String get diagnosticsRawReport => 'Необроблений звіт';

  @override
  String get healthSyncSettingsTitle => 'Синхронізація здоров\'я';

  @override
  String get healthSyncSettingsSubtitle =>
      'Імпортуйте тренування зі своєї платформи здоров’я';

  @override
  String get healthSyncScreenTitle => 'Синхронізація здоров\'я';

  @override
  String get healthAccessScreenTitle => 'Оздоровчий доступ';

  @override
  String get healthAccessRequestedData => 'Запитувані дані';

  @override
  String get healthAccessWorkouts => 'Тренування';

  @override
  String get healthAccessWorkoutRoutes => 'Маршрути тренувань';

  @override
  String get healthAccessHeartRate => 'ЧСС';

  @override
  String get healthAccessWorkoutSummary =>
      'Відстань, калорії та кроки тренування';

  @override
  String get healthAccessAllowed => 'Дозволено';

  @override
  String get healthAccessNeedsAttention => 'Потребує уваги';

  @override
  String get healthAccessManagedBySystem => 'Керується в налаштуваннях системи';

  @override
  String get healthAccessSystemManagedNotice =>
      'HealthKit не розкриває, які дані може читати Endurain. Переглянути доступ у додатку Health.';

  @override
  String get healthAccessReview => 'Перегляньте доступ до охорони здоров’я';

  @override
  String get healthAccessReviewIos => 'Як перевірити доступ';

  @override
  String get healthAccessDisconnect => 'Від’єднати дані про здоров’я';

  @override
  String get healthAccessDisconnectTitle => 'Від’єднати дані про здоров’я?';

  @override
  String get healthAccessDisconnectMessage =>
      'Автоматичний імпорт і локальну історію імпорту для цього сервера буде скинуто. Наявні активності залишаться в історії.';

  @override
  String get healthAccessReviewIosInstructions =>
      'Відкрийте програму «Здоров’я», торкніться свого зображення профілю, а потім «Програми та служби». Виберіть Endurain і оновіть категорії даних.';

  @override
  String get healthSyncAuthorize => 'Підключіться до даних про здоров’я';

  @override
  String get healthSyncInstallProvider => 'Встановіть Health Connect';

  @override
  String get healthSyncInstallProviderDescription =>
      'Для синхронізації тренувань потрібен Health Connect. Встановіть його, щоб продовжити.';

  @override
  String get healthSyncUnsupported =>
      'Синхронізація здоров\'я недоступна на цьому пристрої.';

  @override
  String get healthSyncSelectAll => 'Вибрати все';

  @override
  String get healthSyncClearSelection => 'ясно';

  @override
  String healthSyncImportSelected(int count) {
    return 'Імпорт вибраного ($count)';
  }

  @override
  String healthSyncImportedCount(int count) {
    return 'Імпортовано $count тренувань.';
  }

  @override
  String get healthSyncNoRouteLabel => 'Немає маршруту GPS';

  @override
  String get healthSyncEmptyState =>
      'Не знайдено тренувань за вибраний період.';

  @override
  String get healthSyncRouteConsentGuidance =>
      'Деякі тренування було пропущено, оскільки не було надано доступ до маршруту вправ. Відкрийте Health Connect → Дозволи та дозвольте маршрути вправ для Endurain.';

  @override
  String get healthSyncRouteConsentGuidanceIos =>
      'Деякі тренування було пропущено, оскільки Endurain не міг прочитати їхні маршрути GPS. У програмі Health відкрийте свій профіль, потім Apps and Services, виберіть Endurain і дозвольте Workout Routes.';

  @override
  String get healthSyncReviewAccess => 'Огляд доступу';

  @override
  String get healthSyncAutoSyncTitle =>
      'Автоматична синхронізація під час відновлення';

  @override
  String get healthSyncAutoSyncSubtitle =>
      'Імпортувати нові тренування автоматично, коли відкривається програма.';

  @override
  String get healthSyncNoRoutesExplanation =>
      'Ці тренування не включають GPS-маршрут, тому їх не можна імпортувати. Деякі програми (наприклад, Garmin Connect) записують дії в Apple Health, не повідомляючи маршрут. Тренування, записані за допомогою Apple Watch, містять маршрути та можуть бути імпортовані.';

  @override
  String get healthSyncBadgeNonImportable => 'Неімпортний';

  @override
  String get healthSyncViewAvailable => 'Доступні';

  @override
  String get healthSyncViewImported => 'Імпортовані';

  @override
  String get healthSyncDateRange => 'Період тренувань';

  @override
  String get healthSyncRange30Days => 'Останні 30 днів';

  @override
  String get healthSyncRange3Months => 'Останні 3 місяці';

  @override
  String get healthSyncRange6Months => 'Останні 6 місяців';

  @override
  String get healthSyncRangeYear => 'Останній рік';

  @override
  String get healthSyncRangeAll => 'Уся історія';

  @override
  String get healthSyncRangeCustom => 'Власний період';

  @override
  String get healthSyncImportedEmpty =>
      'Немає імпортованих тренувань для цього підключення.';

  @override
  String healthSyncImportedAt(String dateTime) {
    return 'Імпортовано: $dateTime';
  }

  @override
  String get healthSyncRestore => 'Відновити';

  @override
  String get sensorsTitle => 'Датчики';

  @override
  String get sensorsSettingsSubtitle =>
      'Монітори пульсу та інші зовнішні датчики';

  @override
  String get sensorsHeartRateSection => 'Пульс';

  @override
  String get sensorsHeartRateHelp =>
      'Підключіть Bluetooth-монітор пульсу, щоб бачити свій пульс у реальному часі.';

  @override
  String get sensorsBluetoothOff =>
      'Bluetooth вимкнено. Увімкніть його, щоб підключити датчик.';

  @override
  String get sensorsBluetoothUnauthorized =>
      'Дозвольте доступ до Bluetooth, щоб підключити датчик.';

  @override
  String get sensorsBluetoothUnsupported =>
      'Цей пристрій не підтримує Bluetooth Low Energy.';

  @override
  String get sensorsScan => 'Шукати датчики';

  @override
  String get sensorsScanning => 'Пошук…';

  @override
  String get sensorsStopScan => 'Зупинити';

  @override
  String get sensorsNoDevices => 'Датчиків пульсу ще не знайдено.';

  @override
  String get sensorsAvailableSection => 'Доступні датчики';

  @override
  String get sensorsSavedSection => 'Збережений датчик';

  @override
  String get sensorsConnect => 'Підключити';

  @override
  String get sensorsConnecting => 'Підключення…';

  @override
  String get sensorsConnected => 'Підключено';

  @override
  String get sensorsDisconnect => 'Відключити';

  @override
  String get sensorsForget => 'Забути';

  @override
  String get sensorsConnectionFailed =>
      'Не вдалося підключитися. Спробуйте ще раз.';

  @override
  String get sensorsPermissionRequired =>
      'Для пошуку датчиків потрібен дозвіл на Bluetooth.';

  @override
  String get sensorsUnknownDevice => 'Невідомий датчик';

  @override
  String sensorsBpm(String bpm) {
    return '$bpm bpm';
  }

  @override
  String get sensorsPowerSection => 'Потужність';

  @override
  String get sensorsPowerHelp =>
      'Підключіть Bluetooth-вимірювач потужності, щоб бачити свою потужність у реальному часі.';

  @override
  String get sensorsNoPowerDevices => 'Вимірювачів потужності ще не знайдено.';

  @override
  String sensorsWatts(String watts) {
    return '$watts W';
  }

  @override
  String get sensorsCadenceSection => 'Каденс';

  @override
  String get sensorsCadenceHelp =>
      'Підключіть Bluetooth-датчик каденсу, щоб бачити свій каденс у реальному часі.';

  @override
  String get sensorsNoCadenceDevices => 'Датчиків каденсу ще не знайдено.';

  @override
  String sensorsRpm(String rpm) {
    return '$rpm rpm';
  }

  @override
  String get diagnosticsRemoteTitle => 'Віддалене звітування про збої';

  @override
  String get diagnosticsRemoteEnable => 'Надсилати звіти про збої';

  @override
  String get diagnosticsRemoteEnableSubtitle =>
      'Надсилайте звіти про збої та помилки на діагностичний сервер. Це незалежно від локальної діагностики; можна ввімкнути обидва, одне або жодного.';

  @override
  String get diagnosticsRemoteActive => 'Crash reports are being sent.';

  @override
  String get diagnosticsRemoteNeedsServer =>
      'Віддалене звітування про збої недоступне в цій версії.';

  @override
  String unitMeter(String value) {
    return '$value м';
  }

  @override
  String unitKilometer(String value) {
    return '$value км';
  }

  @override
  String unitFoot(String value) {
    return '$value фут';
  }

  @override
  String unitMile(String value) {
    return '$value ми';
  }

  @override
  String unitKilometersPerHour(String value) {
    return '$value км/год';
  }

  @override
  String unitMilesPerHour(String value) {
    return '$value ми/год';
  }

  @override
  String unitMinutesPerKilometer(String value) {
    return '$value хв/км';
  }

  @override
  String unitMinutesPerMile(String value) {
    return '$value хв/ми';
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
  String get unitsTitle => 'Одиниці виміру';

  @override
  String get unitsSubtitle => 'Одиниці відстані, швидкості та висоти';

  @override
  String get unitsSystemDefault => 'За регіоном пристрою';

  @override
  String get unitsMetric => 'Метричні (км)';

  @override
  String get unitsImperial => 'Імперські (ми)';

  @override
  String get errorInsecureRedirectRejected =>
      'The server tried to redirect to an insecure connection. The request was blocked to protect your credentials.';

  @override
  String get errorTooManyRedirects =>
      'The server redirected too many times. Check the server address.';

  @override
  String get audioAnnouncementsTitle => 'Голосові оголошення';

  @override
  String get audioAnnouncementsSubtitle =>
      'Голосові оновлення про відстань, час, темп або швидкість';

  @override
  String get audioAnnouncementsMasterSwitch => 'Оголошувати прогрес активності';

  @override
  String get audioAnnouncementsMasterSwitchSubtitle =>
      'Вимовляє вашу відстань, час, темп або швидкість під час запису';

  @override
  String get audioAnnouncementsDuckSwitch =>
      'Приглушувати інший звук під час озвучення';

  @override
  String get audioAnnouncementsDuckSwitchSubtitle =>
      'Тимчасово знижує гучність іншого звуку під час кожного оголошення';

  @override
  String get audioAnnouncementsIntervalsHeader =>
      'Інтервал оголошень за видом активності';

  @override
  String get audioAnnouncementsByDistance => 'Відстань';

  @override
  String get audioAnnouncementsByTime => 'Час';

  @override
  String audioAnnouncementsIntervalDistance(String value, String unit) {
    return 'Кожні $value $unit';
  }

  @override
  String audioAnnouncementsIntervalTime(String minutes) {
    return 'Кожні $minutes хв';
  }

  @override
  String get audioAnnouncementsDecreaseInterval => 'Зменшити інтервал';

  @override
  String get audioAnnouncementsIncreaseInterval => 'Збільшити інтервал';

  @override
  String get audioAnnouncementsPreview => 'Прослухати приклад';

  @override
  String get audioAnnouncementsPreviewUnavailable =>
      'Попереднє відтворення оголошення недоступне на цьому пристрої';

  @override
  String get audioAnnouncementsAppliesNextRecording =>
      'Зміни застосуються до наступного запису.';

  @override
  String audioAnnouncementsSpokenMessage(
    String distance,
    String duration,
    String lapMetric,
    String overallMetric,
  ) {
    return 'Відстань $distance. Час $duration. Коло: $lapMetric. Загалом: $overallMetric.';
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
