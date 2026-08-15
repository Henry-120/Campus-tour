import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalDocumentLinks extends StatelessWidget {
  const LegalDocumentLinks({super.key, this.darkText = false});

  final bool darkText;

  static final Uri _termsUri = Uri.parse(
    'https://docs.google.com/document/d/e/2PACX-1vSBgzOKiCsxdOe5BK7ULYseQyDZa90fKM0CaD0OnM8Cc-dCBT69btKADHXW0HxxDG8-P58HiCakcJ9o/pub',
  );
  static final Uri _privacyUri = Uri.parse(
    'https://docs.google.com/document/d/e/2PACX-1vSdO9T6huExJudyozQkozmICXjwx1JunvHA1CXKV894CMDbbsgK4TFXPVMp7i6RQIh8asPwTtbCj1Zg/pub',
  );

  Future<void> _openDocument(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('無法開啟文件，請稍後再試')));
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
      label: '法律文件',
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          TextButton(
            onPressed: () => _openDocument(context, _termsUri),
            child: Text('使用者服務協議', style: textStyle),
          ),
          Text('｜', style: textStyle),
          TextButton(
            onPressed: () => _openDocument(context, _privacyUri),
            child: Text('隱私權政策', style: textStyle),
          ),
        ],
      ),
    );
  }
}
