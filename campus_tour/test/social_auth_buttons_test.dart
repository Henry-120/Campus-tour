import 'package:campus_tour/l10n/app_translations.dart';
import 'package:campus_tour/widgets/login/official_apple_sign_in_button.dart';
import 'package:campus_tour/widgets/login/social_image_button.dart';
import 'package:campus_tour/widgets/login/forgot_password_dialog.dart';
import 'package:campus_tour/widgets/login/wood_login_panel.dart';
import 'package:campus_tour/widgets/login/wood_register_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  Future<void> setPhoneSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 914));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  void expectOfficialSocialButtonLayout(
    WidgetTester tester,
    Finder panelFinder,
  ) {
    final googleButton = find.descendant(
      of: panelFinder,
      matching: find.byType(SocialImageButton),
    );
    final appleButton = find.descendant(
      of: panelFinder,
      matching: find.byType(OfficialAppleSignInButton),
    );
    expect(googleButton, findsOneWidget);
    expect(appleButton, findsOneWidget);

    final panelRect = tester.getRect(panelFinder);
    final googleRect = tester.getRect(googleButton);
    final appleRect = tester.getRect(appleButton);

    expect(appleRect.size, googleRect.size);
    expect(googleRect.center.dx, lessThan(appleRect.center.dx));
    expect(
      googleRect.left - panelRect.left,
      closeTo(panelRect.right - appleRect.right, 0.01),
    );
  }

  testWidgets('login panel centers equal Google and Apple buttons', (
    tester,
  ) async {
    await setPhoneSurface(tester);
    var appleTapped = false;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh'),
        home: Scaffold(
          body: Center(
            child: WoodLoginPanel(
              emailController: TextEditingController(),
              passwordController: TextEditingController(),
              isLoading: false,
              onLogin: () {},
              onRegister: () {},
              onGoogleSignIn: () {},
              onAppleSignIn: () => appleTapped = true,
              onForgotPassword: () {},
            ),
          ),
        ),
      ),
    );

    expectOfficialSocialButtonLayout(tester, find.byType(WoodLoginPanel));
    await tester.tap(
      find.descendant(
        of: find.byType(WoodLoginPanel),
        matching: find.byType(OfficialAppleSignInButton),
      ),
    );
    expect(appleTapped, isTrue);
  });

  testWidgets('register panel centers equal Google and Apple buttons', (
    tester,
  ) async {
    await setPhoneSurface(tester);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh'),
        home: Scaffold(
          body: Center(
            child: WoodRegisterPanel(
              nameController: TextEditingController(),
              emailController: TextEditingController(),
              passwordController: TextEditingController(),
              confirmController: TextEditingController(),
              isLoading: false,
              onRegister: () {},
              onGoogleSignIn: () {},
              onAppleSignIn: () {},
              onBackToLogin: () {},
            ),
          ),
        ),
      ),
    );

    expectOfficialSocialButtonLayout(tester, find.byType(WoodRegisterPanel));
  });

  testWidgets('forgot-password dialog follows the selected language', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('ja'),
        home: const Scaffold(body: ForgotPasswordDialog()),
      ),
    );

    expect(find.text('パスワードを忘れた場合'), findsOneWidget);
    expect(find.text('登録時に使用したメールアドレスを入力してください'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('再設定メールを送信'), findsOneWidget);
  });
}
