import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../controllers/login_controller.dart';
import 'login_page.dart';
import 'game_main_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final LoginController _controller = LoginController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = await _controller.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nicknameController.text.trim(),
        );

        if (!mounted) return;

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("註冊成功！歡迎加入冒險之旅")));
          // 註冊成功後直接進入遊戲主頁
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const GameMainPage()),
            (route) => false, // 清除導覽堆疊
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("註冊失敗，該 Email 可能已被使用或網路異常")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _controller.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const GameMainPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google 登入失敗: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.warmGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text("建立勇者帳號", style: AppTheme.titleStyle.copyWith(fontSize: 36)),
                const SizedBox(height: 10),
                const Text("填寫資料以開啟你的校園圖鑑", style: TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 35),
                
                Container(
                  padding: const EdgeInsets.all(AppTheme.cardPadding * 1.5),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nicknameController,
                        decoration: AppTheme.inputDecoration("冒險者暱稱", Icons.person_outline),
                        validator: (v) => v!.isEmpty ? "請輸入暱稱" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: AppTheme.inputDecoration("電子郵件", Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v != null && v.contains("@")) ? null : "Email 格式不正確",
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: AppTheme.inputDecoration("密碼 (至少 6 位)", Icons.lock_outline),
                        validator: (v) => (v != null && v.length >= 6) ? null : "密碼長度不足",
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: AppTheme.inputDecoration("確認密碼", Icons.verified_user_outlined),
                        validator: (v) => v == _passwordController.text ? null : "兩次輸入的密碼不一致",
                      ),
                      const SizedBox(height: 35),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("開啟旅程", style: AppTheme.buttonTextStyle),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("或使用", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // 使用圖標取代 SVG 網址避免顯示錯誤
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: const Icon(Icons.login, color: Colors.redAccent), // 改用通用圖標
                        label: const Text("Google 快速註冊", style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          side: const BorderSide(color: AppTheme.accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                  child: const Text("已經有冒險帳號？回登入頁面", style: AppTheme.linkTextStyle),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
