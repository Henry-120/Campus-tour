import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/audio_service.dart';
import '../controllers/login_controller.dart';
import '../utils/account_data_sync_exception.dart';
import '../widgets/constants/asset_paths.dart';
import '../widgets/constants/responsive.dart';
import '../widgets/common/snackbar_builder.dart';
import '../utils/firebase_auth_error_message.dart';
import '../widgets/login/game_title.dart';
import '../widgets/login/forgot_password_dialog.dart';
import '../widgets/login/wood_login_panel.dart';
import 'after_login.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final LoginController _controller = LoginController();
  final TextEditingController _emailController = TextEditingController(
    text: "",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "",
  );
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final user = await _controller.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        if (!user.emailVerified) {
          SnackBarBuilder.show(
            context,
            'view.login.page.s008'.trParams({
              'email': user.email ?? 'view.login.page.s009'.tr,
            }),
            type: AppToastType.warning,
            duration: const Duration(seconds: 5),
          );
          return;
        }

        navigateAfterLogin(context);
      } else {
        SnackBarBuilder.show(
          context,
          'view.login.page.s002'.tr,
          type: AppToastType.error,
        );
      }
    } on AccountDataSyncException catch (error) {
      debugPrint('[LoginPage] 登入成功，但同步資料失敗: $error');
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        accountDataSyncErrorMessage(error),
        type: AppToastType.error,
        duration: const Duration(seconds: 6),
      );
    } catch (error) {
      debugPrint("[LoginPage] 登入出錯: $error");

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

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await _controller.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        navigateAfterLogin(context);
      } else {
        SnackBarBuilder.show(
          context,
          'utils.firebase.auth.error.message.s033'.tr,
          type: AppToastType.info,
        );
      }
    } on AccountDataSyncException catch (error) {
      debugPrint('[LoginPage] Google 登入成功，但同步資料失敗: $error');
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        accountDataSyncErrorMessage(error),
        type: AppToastType.error,
        duration: const Duration(seconds: 6),
      );
    } catch (error) {
      debugPrint("[LoginPage] Google 登入出錯: $error");

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
        navigateAfterLogin(context);
      } else {
        SnackBarBuilder.show(
          context,
          'utils.firebase.auth.error.message.s011'.tr,
          type: AppToastType.error,
        );
      }
    } on AccountDataSyncException catch (error) {
      debugPrint('[LoginPage] Apple 登入成功，但同步資料失敗: $error');
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        accountDataSyncErrorMessage(error),
        type: AppToastType.error,
        duration: const Duration(seconds: 6),
      );
    } catch (error) {
      debugPrint('[LoginPage] Apple 登入出錯: $error');

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

  Future<void> _showForgotPasswordDialog() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) =>
          ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (email == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await _controller.sendPasswordResetEmail(email);
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        'view.login.page.s010'.tr,
        type: AppToastType.success,
        duration: const Duration(seconds: 4),
      );
    } catch (error) {
      if (!mounted) return;
      SnackBarBuilder.show(
        context,
        firebaseAuthErrorMessage(error),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService().playMainBgm(fileName: 'audio/M01_login.m4a');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService().pauseAllBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().resumeAllBgm();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AssetPaths.loginBg, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 12 * scale),
                    GameTitle(title: "LOGIN"),
                    SizedBox(height: 10 * scale),
                    WoodLoginPanel(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isLoading: _isLoading,
                      onLogin: _login,
                      onRegister: _goToRegister,
                      onGoogleSignIn: _handleGoogleSignIn,
                      onAppleSignIn: _handleAppleSignIn,
                      onForgotPassword: _showForgotPasswordDialog,
                    ),
                    SizedBox(height: 30 * scale),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
