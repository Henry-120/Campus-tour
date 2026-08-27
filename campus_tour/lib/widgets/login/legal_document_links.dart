import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalDocumentLinks extends StatelessWidget {
  const LegalDocumentLinks({super.key, this.darkText = false});

  final bool darkText;

  static final Uri _termsUri = Uri.parse(
    'https://campus-tour-679e9.web.app/terms.html',
  );
  static final Uri _privacyUri = Uri.parse(
    'https://campus-tour-679e9.web.app/privacy.html',
  );
  static final Uri _supportUri = Uri.parse(
    'https://campus-tour-679e9.web.app/support.html',
  );

  Future<void> _openDocument(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('widgets.login.legal.document.links.s001'.tr)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkColor = darkText ? const Color(0xFF5A3825) : Colors.white;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: linkColor,
      decoration: TextDecoration.underline,
      decorationColor: linkColor,
    );

    return Semantics(
      container: true,
      label: 'widgets.login.legal.document.links.s004'.tr,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          TextButton(
            onPressed: () => _openDocument(context, _termsUri),
            child: Text(
              'widgets.login.legal.document.links.s002'.tr,
              style: textStyle,
            ),
          ),
          Text('｜', style: textStyle),
          TextButton(
            onPressed: () => _openDocument(context, _privacyUri),
            child: Text(
              'widgets.login.legal.document.links.s003'.tr,
              style: textStyle,
            ),
          ),
          Text('｜', style: textStyle),
          TextButton(
            onPressed: () => _openDocument(context, _supportUri),
            child: Text(
              'widgets.login.legal.document.links.s005'.tr,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
