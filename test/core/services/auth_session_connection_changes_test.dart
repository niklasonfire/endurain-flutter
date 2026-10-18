import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test(
    'account changes and logout emit identity; token refresh preserves it',
    () async {
      final store = AuthSessionStore(storage: SecureStorageService());
      final identities = <String?>[];
      store.connectionChanges.addListener(
        () => identities.add(store.connectionChanges.value),
      );
      await store.saveSession(
        origin: 'https://example.test',
        accessToken: 'a',
        refreshToken: 'r',
        sessionId: 's',
        accountId: '1',
        expiresInSeconds: 3600,
      );
      final session = (await store.readSession())!;
      await store.replaceSessionIfCurrent(
        expected: session,
        accessToken: 'new',
        refreshToken: 'new-r',
        sessionId: 'new-s',
        expiresInSeconds: 3600,
      );
      expect(identities, ['https://example.test#1']);
      await store.saveSession(
        origin: 'https://example.test',
        accessToken: 'b',
        refreshToken: 'r',
        sessionId: 's',
        accountId: '2',
        expiresInSeconds: 3600,
      );
      await store.clear();
      expect(identities, [
        'https://example.test#1',
        'https://example.test#2',
        null,
      ]);
    },
  );
}
