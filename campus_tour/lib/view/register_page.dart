import 'package:flutter/material.dart';

import '../controllers/login_controller.dart';
import '../styles/app_theme.dart';
import '../widgets/constants/asset_paths.dart';
import '../widgets/constants/responsive.dart';
import '../widgets/common/snackbar_builder.dart';
import '../utils/account_data_sync_exception.dart';
import '../utils/firebase_auth_error_message.dart';
import '../widgets/login/game_link_text.dart';
import '../widgets/login/game_title.dart';
import '../widgets/login/legal_document_links.dart';
import '../widgets/login/wood_register_panel.dart';
import 'after_login.dart';
import 'login_page.dart';

import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoginController _controller = LoginController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      SnackBarBuilder.show(
        context,
        'view.register.page.s001'.tr,
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _controller.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        SnackBarBuilder.show(
          context,
          'view.register.page.s002'.trParams({
            'email': user.email ?? 'view.login.page.s009'.tr,
          }),
          type: AppToastType.success,
        );

        _goBackToLogin();
      } else {
        SnackBarBuilder.show(
          context,
          'view.register.page.s003'.tr,
          type: AppToastType.error,
        );
      }
    } on AccountDataSyncException catch (error) {
      debugPrint('[RegisterPage] 帳號建立成功，但初始化資料失敗: $error');
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        accountDataSyncErrorMessage(error),
        type: AppToastType.error,
        duration: const Duration(seconds: 6),
      );
      _goBackToLogin();
    } catch (error) {
      debugPrint("[RegisterPage] 註冊出錯: $error");

      if (!mounted) return;

      SnackBarBuilder.show(
        context,
        firebaseAuthErrorMessage(error),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await _controller.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        SnackBarBuilder.show(
          context,
          'view.register.page.s006'.tr,
          type: AppToastType.success,
        );

        navigateAfterLogin(context);
      } else {
        SnackBarBuilder.show(
          context,
          'utils.firebase.auth.error.message.s033'.tr,
          type: AppToastType.info,
        );
      }
    } on AccountDataSyncException catch (error) {
      debugPrint('[RegisterPage] Google 登入成功，但同步資料失敗: $error');
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        accountDataSyncErrorMessage(error),
        type: AppToastType.error,
        duration: const Duration(seconds: 6),
      );
    } catch (error) {
      debugPrint("[RegisterPage] Google 登入失敗: $error");

      if (!mounted) return;

      SnackBarBuilder.show(
        context,
        googleAuthErrorMessage(error),
        type: isGoogleSignInCancellation(error)
            ? AppToastType.info
            : AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await _controller.signInWithApple();

      if (!mounted) return;

      if (user != null) {
        SnackBarBuilder.show(
          context,
          'view.register.page.s010'.tr,
          type: AppToastType.success,
        );

        navigateAfterLogin(context);
      } else {
        SnackBarBuilder.show(
          context,
          'utils.firebase.auth.error.message.s011'.tr,
          type: AppToastType.error,
        );
      }
    } on AccountDataSyncException catch (error) {
      debugPrint('[RegisterPage] Apple 登入成功，但同步資料失敗: $error');
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        accountDataSyncErrorMessage(error),
        type: AppToastType.error,
        duration: const Duration(seconds: 6),
      );
    } catch (error) {
      debugPrint('[RegisterPage] Apple 登入失敗: $error');

      if (!mounted) return;

      SnackBarBuilder.show(
        context,
        appleAuthErrorMessage(error),
        type: isAppleSignInCancellation(error)
            ? AppToastType.info
            : AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goBackToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AssetPaths.loginBg, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12 * scale),
                      GameTitle(title: "REGISTER"),
                      SizedBox(height: 10 * scale),
                      WoodRegisterPanel(
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmController: _confirmController,
                        isLoading: _isLoading,
                        onRegister: _register,
                        onGoogleSignIn: _handleGoogleSignIn,
                        onAppleSignIn: _handleAppleSignIn,
                        onBackToLogin: _goBackToLogin,
                      ),
                      GameLinkText(
                        text: "Already have account?",
                        onTap: () {},
                        fontSize: 14 * scale,
                        color: AppTheme.loginGlowColor,
                      ),
                      GameLinkText(
                        text: "Return to Login",
                        onTap: _isLoading ? () {} : _goBackToLogin,
                        fontSize: 14 * scale,
                        color: AppTheme.loginGlowColor,
                      ),
                      const LegalDocumentLinks(),
                      SizedBox(height: 24 * scale),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
