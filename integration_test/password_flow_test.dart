// End-to-end test of the phone + password login, driven on a simulator
// against a LOCAL backend that uses the fake SMS provider (code 1234):
//
//   OTP_PROVIDER=fake OTP_RESEND_COOLDOWN_SECONDS=0 \
//   OTP_REVIEW_PHONE=+2250102030405 OTP_REVIEW_CODE=2572 uvicorn app.main:app --port 8096
//   flutter test integration_test/password_flow_test.dart -d <simulator> \
//     --dart-define=API_BASE_URL=http://localhost:8096
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:rabais_ci/main.dart' as app;
import 'package:rabais_ci/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:rabais_ci/presentation/features/auth/bloc/auth_event.dart';
import 'package:rabais_ci/presentation/pages/auth/login_page.dart';
import 'package:rabais_ci/presentation/pages/auth/otp_verification_page.dart';
import 'package:rabais_ci/presentation/pages/auth/password_pages.dart';
import 'package:rabais_ci/presentation/pages/auth/profile_completion_page.dart';
import 'package:rabais_ci/presentation/pages/customer_home_page.dart';

const phoneDigits = '0700000001';
const reviewDigits = '0102030405';

Future<void> pumpUntil(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 25)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

Future<void> settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

AuthBloc blocOf(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).first).read<AuthBloc>();

Future<void> logout(WidgetTester tester) async {
  blocOf(tester).add(const LogoutEvent());
  await pumpUntil(tester, find.byType(LoginPage));
  await settle(tester);
}

Future<void> submitPhone(WidgetTester tester, String digits) async {
  await pumpUntil(tester, find.byType(IntlPhoneField));
  final field = find.descendant(of: find.byType(IntlPhoneField), matching: find.byType(TextField));
  await tester.enterText(field, digits);
  await settle(tester);
  await tester.tap(find.descendant(of: find.byType(LoginPage), matching: find.byType(ElevatedButton)));
}

Future<void> enterOtp(WidgetTester tester, String code) async {
  await pumpUntil(tester, find.byType(OtpVerificationPage));
  await settle(tester);
  final boxes = find.descendant(of: find.byType(OtpVerificationPage), matching: find.byType(TextField));
  for (var i = 0; i < code.length; i++) {
    await tester.enterText(boxes.at(i), code[i]);
    await tester.pump(const Duration(milliseconds: 150));
  }
  await tester.tap(find.descendant(of: find.byType(OtpVerificationPage), matching: find.byType(ElevatedButton)));
}

Future<void> fillPasswords(WidgetTester tester, Type page, List<String> values) async {
  final fields = find.descendant(of: find.byType(page), matching: find.byType(TextField));
  for (var i = 0; i < values.length; i++) {
    await tester.enterText(fields.at(i), values[i]);
    await tester.pump(const Duration(milliseconds: 150));
    // The test text input can't re-attach to a field it already left; type
    // through the controller instead (same as the user typing).
    final controller = tester.widget<TextField>(fields.at(i)).controller!;
    if (controller.text != values[i]) {
      controller.text = values[i];
      final onChanged = tester.widget<TextField>(fields.at(i)).onChanged;
      onChanged?.call(values[i]);
    }
  }
  await settle(tester);
}

Future<void> tapPrimary(WidgetTester tester, Type page) async {
  // Hide the keyboard and the error snackbar, then make sure the button is on screen.
  FocusManager.instance.primaryFocus?.unfocus();
  final scaffold = find.byType(ScaffoldMessenger);
  if (scaffold.evaluate().isNotEmpty) {
    tester.state<ScaffoldMessengerState>(scaffold.first).hideCurrentSnackBar();
  }
  await settle(tester, 6);
  final button = find.descendant(of: find.byType(page), matching: find.byType(ElevatedButton)).last;
  await tester.ensureVisible(button);
  await settle(tester, 4);
  await tester.tap(button, warnIfMissed: true);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phone + password login, forgot password, change password, review phone', (tester) async {
    app.main();
    await pumpUntil(tester, find.byType(LoginPage), timeout: const Duration(seconds: 40));
    await settle(tester);

    // 1. First login: SMS code, then the password must be created.
    await submitPhone(tester, phoneDigits);
    await enterOtp(tester, '1234');
    await pumpUntil(tester, find.byType(CreatePasswordPage));
    // Weak password keeps the button disabled.
    await fillPasswords(tester, CreatePasswordPage, ['abc', 'abc']);
    final save = tester.widget<ElevatedButton>(
        find.descendant(of: find.byType(CreatePasswordPage), matching: find.byType(ElevatedButton)));
    expect(save.onPressed, isNull, reason: 'weak password must not be accepted');
    await fillPasswords(tester, CreatePasswordPage, ['Rabais2026', 'Rabais2026']);
    await tapPrimary(tester, CreatePasswordPage);
    // New customer continues to the profile form.
    await pumpUntil(tester, find.byType(ProfileCompletionPage));

    // 2. Next login asks for the password (no SMS).
    await logout(tester);
    await submitPhone(tester, phoneDigits);
    await pumpUntil(tester, find.byType(PasswordLoginPage));
    await fillPasswords(tester, PasswordLoginPage, ['Wrong2026x']);
    await tapPrimary(tester, PasswordLoginPage);
    await pumpUntil(tester, find.textContaining('incorrect'));
    expect(find.byType(PasswordLoginPage), findsOneWidget);
    await fillPasswords(tester, PasswordLoginPage, ['Rabais2026']);
    await tapPrimary(tester, PasswordLoginPage);
    await pumpUntil(tester, find.byType(CustomerHomePage));

    // 3. "Change number" goes back to the phone screen.
    await logout(tester);
    await submitPhone(tester, phoneDigits);
    await pumpUntil(tester, find.byType(PasswordLoginPage));
    await tester.tap(find.byIcon(Icons.phone_iphone_rounded));
    await pumpUntil(tester, find.byType(LoginPage));
    await settle(tester);

    // 4. Forgot password: SMS code, then a new password.
    await submitPhone(tester, phoneDigits);
    await pumpUntil(tester, find.byType(PasswordLoginPage));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(PasswordLoginPage), matching: find.byType(TextButton)).first);
    await enterOtp(tester, '1234');
    await pumpUntil(tester, find.byType(CreatePasswordPage));
    await fillPasswords(tester, CreatePasswordPage, ['Nouveau2026', 'Nouveau2026']);
    await tapPrimary(tester, CreatePasswordPage);
    await pumpUntil(tester, find.byType(CustomerHomePage));

    // 5. Change password from Settings: signs out, new password works.
    final nav = Navigator.of(tester.element(find.byType(CustomerHomePage)));
    nav.push(MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
    await pumpUntil(tester, find.byType(ChangePasswordPage));
    await settle(tester);
    await fillPasswords(tester, ChangePasswordPage, ['Nouveau2026', 'Change2026ok', 'Change2026ok']);
    await tapPrimary(tester, ChangePasswordPage);
    await pumpUntil(tester, find.byType(LoginPage));
    await settle(tester);
    await submitPhone(tester, phoneDigits);
    await pumpUntil(tester, find.byType(PasswordLoginPage));
    await fillPasswords(tester, PasswordLoginPage, ['Change2026ok']);
    await tapPrimary(tester, PasswordLoginPage);
    await pumpUntil(tester, find.byType(CustomerHomePage));

    // 6. Store-review phone: fixed SMS code, never asked for a password.
    await logout(tester);
    await submitPhone(tester, reviewDigits);
    await enterOtp(tester, '2572');
    await pumpUntil(tester, find.byType(ProfileCompletionPage));
    expect(find.byType(CreatePasswordPage), findsNothing);
  });
}
