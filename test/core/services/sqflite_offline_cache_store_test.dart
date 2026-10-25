import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/core/services/sqflite_offline_cache_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  SqfliteOfflineCacheStore makeStore() => SqfliteOfflineCacheStore(
    databaseFactory: databaseFactoryFfi,
    databasePath: inMemoryDatabasePath,
  );

  OfflineCacheEntry entry({
    String profileId = 'https://example.test#account-a',
    String concept = 'activity-list',
    String query = 'page_number=1',
    Object? payload,
    DateTime? fetchedAt,
  }) => OfflineCacheEntry(
    profileId: profileId,
    concept: concept,
    query: query,
    payload: payload ?? const <String, Object?>{'items': [], 'total': 0},
    fetchedAt: fetchedAt ?? DateTime.utc(2026, 10, 25, 8),
  );

  test('write then read returns the raw payload and fetch time', () async {
    final store = makeStore();
    addTearDown(store.close);
    final fetchedAt = DateTime.utc(2026, 10, 25, 8, 30, 12);
    await store.write(
      entry(
        payload: const {
          'items': [
            {'id': '7', 'name': 'Morning run'},
          ],
          'total': 1,
        },
        fetchedAt: fetchedAt,
      ),
    );

    final cached = await store.read(
      profileId: 'https://example.test#account-a',
      concept: 'activity-list',
      query: 'page_number=1',
    );

    expect(cached, isNotNull);
    expect(cached!.payload, const {
      'items': [
        {'id': '7', 'name': 'Morning run'},
      ],
      'total': 1,
    });
    expect(cached.fetchedAt, fetchedAt);
    expect(cached.profileId, 'https://example.test#account-a');
    expect(cached.concept, 'activity-list');
    expect(cached.query, 'page_number=1');
  });

  test('read returns null when nothing was cached for the key', () async {
    final store = makeStore();
    addTearDown(store.close);
    final cached = await store.read(
      profileId: 'https://example.test#account-a',
      concept: 'activity-list',
      query: 'page_number=1',
    );
    expect(cached, isNull);
  });

  test('entries of one identity are invisible to another', () async {
    final store = makeStore();
    addTearDown(store.close);
    await store.write(
      entry(profileId: 'https://a.test#account-a', payload: const {'total': 1}),
    );

    final otherIdentity = await store.read(
      profileId: 'https://b.test#account-a',
      concept: 'activity-list',
      query: 'page_number=1',
    );
    final otherConcept = await store.read(
      profileId: 'https://a.test#account-a',
      concept: 'activity-types',
      query: 'page_number=1',
    );
    final otherQuery = await store.read(
      profileId: 'https://a.test#account-a',
      concept: 'activity-list',
      query: 'page_number=2',
    );

    expect(otherIdentity, isNull);
    expect(otherConcept, isNull);
    expect(otherQuery, isNull);
  });

  test('writing the same key replaces the previous payload', () async {
    final store = makeStore();
    addTearDown(store.close);
    await store.write(entry(payload: const {'total': 1}));
    await store.write(
      entry(payload: const {'total': 2}, fetchedAt: DateTime.utc(2026, 10, 26)),
    );

    final cached = await store.read(
      profileId: 'https://example.test#account-a',
      concept: 'activity-list',
      query: 'page_number=1',
    );

    expect(cached!.payload, const {'total': 2});
    expect(cached.fetchedAt, DateTime.utc(2026, 10, 26));
  });

  test('clearForProfile removes only that identity', () async {
    final store = makeStore();
    addTearDown(store.close);
    await store.write(
      entry(profileId: 'https://a.test#account-a', payload: const {'total': 1}),
    );
    await store.write(
      entry(profileId: 'https://a.test#account-b', payload: const {'total': 2}),
    );
    await store.write(
      entry(profileId: 'https://b.test#account-a', payload: const {'total': 3}),
    );

    final removed = await store.clearForProfile('https://a.test#account-a');

    expect(removed, 1);
    expect(
      await store.read(
        profileId: 'https://a.test#account-a',
        concept: 'activity-list',
        query: 'page_number=1',
      ),
      isNull,
    );
    expect(
      await store.read(
        profileId: 'https://a.test#account-b',
        concept: 'activity-list',
        query: 'page_number=1',
      ),
      isNotNull,
    );
    expect(
      await store.read(
        profileId: 'https://b.test#account-a',
        concept: 'activity-list',
        query: 'page_number=1',
      ),
      isNotNull,
    );
  });

  test('clearAll removes every identity', () async {
    final store = makeStore();
    addTearDown(store.close);
    await store.write(
      entry(profileId: 'https://a.test#account-a', payload: const {'total': 1}),
    );
    await store.write(
      entry(profileId: 'https://b.test#account-b', payload: const {'total': 2}),
    );

    await store.clearAll();

    expect(
      await store.read(
        profileId: 'https://a.test#account-a',
        concept: 'activity-list',
        query: 'page_number=1',
      ),
      isNull,
    );
    expect(
      await store.read(
        profileId: 'https://b.test#account-b',
        concept: 'activity-list',
        query: 'page_number=1',
      ),
      isNull,
    );
  });

  test('cache keys qualify identity, concept, and canonical query', () {
    expect(
      offlineCacheKey(
        profileId: 'https://example.test#account-a',
        concept: 'activity-list',
        query: 'page_number=1&num_records=20',
      ),
      'https://example.test#account-a|activity-list|page_number=1&num_records=20',
    );
  });

  test('canonical query sorts and encodes parameters', () {
    expect(
      canonicalCacheQuery(const {
        'num_records': '20',
        'name': 'trail & mountain',
        'page_number': '1',
      }),
      'name=trail+%26+mountain&num_records=20&page_number=1',
    );
  });
}
