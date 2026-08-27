import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('widgets.login.forgot.password.dialog.s001'.tr),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'widgets.login.forgot.password.dialog.s002'.tr,
            hintText: 'widgets.login.forgot.password.dialog.s003'.tr,
            prefixIcon: const Icon(Icons.email_rounded),
          ),
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) {
              return 'widgets.login.forgot.password.dialog.s004'.tr;
            }
            if (!email.contains('@')) {
              return 'widgets.login.forgot.password.dialog.s005'.tr;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('widgets.login.forgot.password.dialog.s006'.tr),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text('widgets.login.forgot.password.dialog.s007'.tr),
        ),
      ],
    );
  }
}
