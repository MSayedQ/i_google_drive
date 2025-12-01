import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:i_google_drive/i_google_drive.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks: flutter pub run build_runner build
@GenerateMocks([GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication])
import 'google_drive_service_test.mocks.dart';

void main() {
  late GoogleDriveService driveService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late MockGoogleSignInAuthentication mockAuth;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    mockAuth = MockGoogleSignInAuthentication();
    driveService = GoogleDriveService(googleSignIn: mockGoogleSignIn);
  });

  group('GoogleDriveService - Authentication', () {
    test('signIn should succeed when user signs in', () async {
      when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.email).thenReturn('test@example.com');
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn('test-access-token');
      when(mockAuth.idToken).thenReturn('test-id-token');

      final result = await driveService.signIn();

      expect(result, mockAccount);
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockAccount.authentication).called(1);
    });

    test('signIn should throw AuthenticationException when user cancels',
        () async {
      when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      expect(
        () => driveService.signIn(),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test(
        'signIn should throw AuthenticationException when access token is null',
        () async {
      when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.email).thenReturn('test@example.com');
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn(null);

      expect(
        () => driveService.signIn(),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('signOut should succeed', () async {
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());

      await driveService.signOut();

      verify(mockGoogleSignIn.signOut()).called(1);
    });

    test('isSignedIn should return true when user is signed in', () async {
      when(mockGoogleSignIn.signInSilently())
          .thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn('test-access-token');

      final result = await driveService.isSignedIn();

      expect(result, isTrue);
      verify(mockGoogleSignIn.signInSilently()).called(1);
    });

    test('isSignedIn should return false when user is not signed in', () async {
      when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);

      final result = await driveService.isSignedIn();

      expect(result, isFalse);
      verify(mockGoogleSignIn.signInSilently()).called(1);
    });

    test('getCurrentUser should return user when signed in', () async {
      when(mockGoogleSignIn.signInSilently())
          .thenAnswer((_) async => mockAccount);
      when(mockAccount.email).thenReturn('test@example.com');

      final result = await driveService.getCurrentUser();

      expect(result, mockAccount);
      verify(mockGoogleSignIn.signInSilently()).called(1);
    });

    test('getCurrentUser should return null when not signed in', () async {
      when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);

      final result = await driveService.getCurrentUser();

      expect(result, isNull);
      verify(mockGoogleSignIn.signInSilently()).called(1);
    });
  });

  group('GoogleDriveService - File Operations', () {
    setUp(() {
      // Setup authentication for file operations
      when(mockGoogleSignIn.signInSilently())
          .thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.accessToken).thenReturn('test-access-token');
    });

    // Note: Full integration tests for file operations would require
    // http client injection or integration test setup with actual Google Drive API
    // These tests focus on authentication which is the core dependency
  });
}
