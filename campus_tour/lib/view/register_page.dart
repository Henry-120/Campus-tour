import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import '../widgets/login/login_text_form_field.dart';
import '../view/login_page.dart';

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

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final nickname = _nicknameController.text;

      final user = await _controller.register(email, password, nickname);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("註冊成功！歡迎 $nickname")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("註冊失敗，請再試一次")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("註冊")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              LoginTextFormField(
                controller: _emailController,
                label: "Email",
                validator: (value) =>
                value!.contains("@") ? null : "請輸入有效的 Email",
              ),
              LoginTextFormField(
                controller: _passwordController,
                label: "密碼",
                obscure: true,
                validator: (value) =>
                value!.length >= 6 ? null : "密碼至少 6 位數",
              ),
              LoginTextFormField(
                controller: _confirmController,
                label: "確認密碼",
                obscure: true,
                validator: (value) =>
                value == _passwordController.text ? null : "密碼不一致",
              ),
              LoginTextFormField(
                controller: _nicknameController,
                label: "暱稱",
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text("註冊"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
