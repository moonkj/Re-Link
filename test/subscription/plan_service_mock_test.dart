/// PlanService 실제 코드 테스트 (MockInAppPurchase + MockAuthHttpClient)
/// 커버: plan_service.dart — completePurchaseWithVerification, verifyReceipt,
///        retryPendingReceipts, getSubscriptionExpiry, dispose
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_link/core/services/auth/auth_http_client.dart';
import 'package:re_link/core/services/auth/auth_token_storage.dart';
import 'package:re_link/core/services/plan/plan_service.dart';
import 'package:re_link/shared/repositories/settings_repository.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class FakeTokenStorage implements AuthTokenStorage {
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {}

  @override
  Future<String?> getAccessToken() async => 'test_token';

  @override
  Future<String?> getRefreshToken() async => 'test_refresh';

  @override
  Future<String?> getUserId() async => null;

  @override
  Future<void> clearTokens() async {}

  @override
  Future<void> updateAccessToken(String accessToken) async {}
}

class FakePurchaseDetails extends Fake implements PurchaseDetails {
  @override
  final String productID;

  @override
  final PurchaseVerificationData verificationData;

  FakePurchaseDetails({
    required this.productID,
    required String serverVerificationData,
  }) : verificationData = PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: serverVerificationData,
          source: '',
        );
}

void main() {
  late MockInAppPurchase mockIap;
  late MockSettingsRepository mockSettings;
  late AuthHttpClient authHttpClient;

  setUpAll(() {
    registerFallbackValue(FakePurchaseDetails(
      productID: 'test',
      serverVerificationData: 'test',
    ));
  });

  setUp(() {
    mockIap = MockInAppPurchase();
    mockSettings = MockSettingsRepository();
  });

  AuthHttpClient createAuthHttpClient(http.Client httpClient) {
    return AuthHttpClient(
      tokenStorage: FakeTokenStorage(),
      baseUrl: 'https://api.test.com',
      httpClient: httpClient,
    );
  }

  group('PlanService constructor', () {
    test('creates with InAppPurchase', () {
      final service = PlanService(mockIap);
      expect(service, isNotNull);
    });

    test('creates with all optional params', () {
      authHttpClient = createAuthHttpClient(
        MockClient((r) async => http.Response('{}', 200)),
      );
      final service = PlanService(
        mockIap,
        authHttpClient: authHttpClient,
        settingsRepository: mockSettings,
      );
      expect(service, isNotNull);
    });
  });

  group('PlanService.isAvailable', () {
    test('delegates to IAP', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => true);
      final service = PlanService(mockIap);
      expect(await service.isAvailable(), isTrue);
    });

    test('returns false when unavailable', () async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => false);
      final service = PlanService(mockIap);
      expect(await service.isAvailable(), isFalse);
    });
  });

  group('PlanService.completePurchase', () {
    test('delegates to IAP', () async {
      final details = FakePurchaseDetails(
        productID: PlanProductIds.plus,
        serverVerificationData: 'receipt',
      );
      when(() => mockIap.completePurchase(any())).thenAnswer((_) async {});
      final service = PlanService(mockIap);
      await service.completePurchase(details);
      verify(() => mockIap.completePurchase(any())).called(1);
    });
  });

  group('PlanService.restorePurchases', () {
    test('delegates to IAP', () async {
      when(() => mockIap.restorePurchases()).thenAnswer((_) async {});
      final service = PlanService(mockIap);
      await service.restorePurchases();
      verify(() => mockIap.restorePurchases()).called(1);
    });
  });

  group('PlanService.dispose', () {
    test('does not throw', () {
      final service = PlanService(mockIap);
      expect(() => service.dispose(), returnsNormally);
    });
  });

  group('PlanService.getSubscriptionExpiry', () {
    test('no settings → returns null', () async {
      final service = PlanService(mockIap);
      final result = await service.getSubscriptionExpiry();
      expect(result, isNull);
    });

    test('empty stored value → returns null', () async {
      when(() => mockSettings.get('subscription_expires_at'))
          .thenAnswer((_) async => '');
      final service = PlanService(
        mockIap,
        settingsRepository: mockSettings,
      );
      final result = await service.getSubscriptionExpiry();
      expect(result, isNull);
    });

    test('null stored value → returns null', () async {
      when(() => mockSettings.get('subscription_expires_at'))
          .thenAnswer((_) async => null);
      final service = PlanService(
        mockIap,
        settingsRepository: mockSettings,
      );
      final result = await service.getSubscriptionExpiry();
      expect(result, isNull);
    });

    test('valid date string → returns DateTime', () async {
      when(() => mockSettings.get('subscription_expires_at'))
          .thenAnswer((_) async => '2027-01-15T00:00:00.000');
      final service = PlanService(
        mockIap,
        settingsRepository: mockSettings,
      );
      final result = await service.getSubscriptionExpiry();
      expect(result, isNotNull);
      expect(result!.year, 2027);
      expect(result.month, 1);
      expect(result.day, 15);
    });
  });

  group('PlanService.loadProducts', () {
    test('returns map of ProductDetails', () async {
      when(() => mockIap.queryProductDetails(any())).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: [],
          notFoundIDs: [],
        ),
      );
      final service = PlanService(mockIap);
      final products = await service.loadProducts();
      expect(products, isEmpty);
    });
  });

  group('PlanService.purchaseStream', () {
    test('delegates to IAP', () {
      when(() => mockIap.purchaseStream).thenAnswer(
        (_) => const Stream.empty(),
      );
      final service = PlanService(mockIap);
      expect(service.purchaseStream, isNotNull);
    });
  });

  group('PlanService.completePurchaseWithVerification', () {
    test('verification valid + no expiry → completes purchase', () async {
      final details = FakePurchaseDetails(
        productID: PlanProductIds.plus,
        serverVerificationData: 'receipt',
      );

      when(() => mockIap.completePurchase(any())).thenAnswer((_) async {});

      // No http client → local-first mode (always valid)
      final service = PlanService(mockIap);
      final success = await service.completePurchaseWithVerification(details);
      expect(success, isTrue);
      verify(() => mockIap.completePurchase(any())).called(1);
    });

    test('verification valid + expiry → saves expiry and completes', () async {
      final details = FakePurchaseDetails(
        productID: PlanProductIds.familyMonthly,
        serverVerificationData: 'receipt',
      );

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/purchase/verify') {
          return http.Response(
            jsonEncode({
              'data': {
                'valid': true,
                'expires_at': '2027-06-01T00:00:00.000',
              }
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      authHttpClient = createAuthHttpClient(mockHttpClient);
      when(() => mockIap.completePurchase(any())).thenAnswer((_) async {});
      when(() => mockSettings.set(any(), any())).thenAnswer((_) async {});

      final service = PlanService(
        mockIap,
        authHttpClient: authHttpClient,
        settingsRepository: mockSettings,
      );
      final success = await service.completePurchaseWithVerification(details);
      expect(success, isTrue);
      // Verify subscription_expires_at saved
      verify(() => mockSettings.set(
            'subscription_expires_at',
            any(that: contains('2027')),
          )).called(1);
    });

    test('verification rejected → returns false', () async {
      final details = FakePurchaseDetails(
        productID: PlanProductIds.plus,
        serverVerificationData: 'bad_receipt',
      );

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/purchase/verify') {
          return http.Response('{"error":"invalid"}', 403);
        }
        return http.Response('{}', 200);
      });

      authHttpClient = createAuthHttpClient(mockHttpClient);
      when(() => mockIap.completePurchase(any())).thenAnswer((_) async {});

      final service = PlanService(
        mockIap,
        authHttpClient: authHttpClient,
      );
      final success = await service.completePurchaseWithVerification(details);
      expect(success, isFalse);
    });
  });

  group('PlanService.verifyReceipt', () {
    test('no http client → returns valid (local-first)', () async {
      final service = PlanService(mockIap);
      final details = FakePurchaseDetails(
        productID: PlanProductIds.plus,
        serverVerificationData: 'receipt_data',
      );
      final result = await service.verifyReceipt(details);
      expect(result.isValid, isTrue);
    });

    test('server returns 200 with valid → returns valid result', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/purchase/verify') {
          return http.Response(
            jsonEncode({
              'data': {
                'valid': true,
                'expires_at': '2027-06-01T00:00:00.000',
              }
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      authHttpClient = createAuthHttpClient(mockHttpClient);
      final service = PlanService(
        mockIap,
        authHttpClient: authHttpClient,
        settingsRepository: mockSettings,
      );

      final details = FakePurchaseDetails(
        productID: PlanProductIds.familyMonthly,
        serverVerificationData: 'receipt_data',
      );
      final result = await service.verifyReceipt(details);
      expect(result.isValid, isTrue);
      expect(result.expiresAt, isNotNull);
      expect(result.expiresAt!.year, 2027);
    });

    test('server returns 403 → explicit rejection', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('{"error":"invalid"}', 403);
      });

      authHttpClient = createAuthHttpClient(mockHttpClient);
      final service = PlanService(
        mockIap,
        authHttpClient: authHttpClient,
      );

      final details = FakePurchaseDetails(
        productID: PlanProductIds.plus,
        serverVerificationData: 'bad_receipt',
      );
      final result = await service.verifyReceipt(details);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('server returns 500 → saves pending receipt, returns valid', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response('error', 500);
      });

      authHttpClient = createAuthHttpClient(mockHttpClient);

      when(() => mockSettings.set(any(), any())).thenAnswer((_) async {});

      final service = PlanService(
        mockIap,
        authHttpClient: authHttpClient,
        settingsRepository: mockSettings,
      );

      final details = FakePurchaseDetails(
        productID: PlanProductIds.familyMonthly,
        serverVerificationData: 'receipt_data',
      );
      final result = await service.verifyReceipt(details);
      // Should return valid (offline-first)
      expect(result.isValid, isTrue);
    });

    test('network error → saves pending receipt, returns valid', () async {
      final mockHttpClient = MockClient((request) async {
        throw Exception('No network');
      });

      authHttpClient = createAuthHttpClient(mockHttpClient);

      when(() => mockSettings.set(any(), any())).thenAnswer((_) async {});

      final service = PlanService(
        mockIap,
        authHttpClient: authHttpClient,
        settingsRepository: mockSettings,
      );

      final details = FakePurchaseDetails(
        productID: PlanProductIds.plus,
        serverVerificationData: 'receipt',
      );
      final result = await service.verifyReceipt(details);
      expect(result.isValid, isTrue);
    });
  });

  group('PlanService.retryPendingReceipts', () {
    test('no settings or client → returns immediately', () async {
      final service = PlanService(mockIap);
      // Should not throw
      await service.retryPendingReceipts();
    });

    test('retries pending receipt — success clears it', () async {
      final pendingJson = jsonEncode(PendingReceipt(
        receipt: 'pending_receipt',
        productId: PlanProductIds.familyMonthly,
        platform: 'ios',
        createdAt: DateTime(2026, 4, 1),
      ).toJson());

      // Set up mock settings to return pending receipt for familyMonthly
      when(() => mockSettings.get(any())).thenAnswer((invocation) async {
        final key = invocation.positionalArguments[0] as String;
        if (key == 'pending_receipt_${PlanProductIds.familyMonthly}') {
          return pendingJson;
        }
        return null;
      });
      when(() => mockSettings.set(any(), any())).thenAnswer((_) async {});

      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/purchase/verify') {
          return http.Response(jsonEncode({'data': {'valid': true}}), 200);
        }
        return http.Response('{}', 200);
      });

      authHttpClient = createAuthHttpClient(mockHttpClient);

      final service = PlanService(
        mockIap,
        authHttpClient: authHttpClient,
        settingsRepository: mockSettings,
      );

      await service.retryPendingReceipts();

      // Should have cleared the pending receipt
      verify(() => mockSettings.set(
            'pending_receipt_${PlanProductIds.familyMonthly}',
            '',
          )).called(1);
    });
  });
}
