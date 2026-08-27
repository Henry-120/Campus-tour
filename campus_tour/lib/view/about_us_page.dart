import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const String pageTitle = '關於我們';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(pageTitle),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 64 : 28,
                vertical: isWide ? 42 : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isWide
                      ? const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _OrganizationCredits()),
                            SizedBox(width: 80),
                            Expanded(child: _DevelopmentCredits()),
                          ],
                        )
                      : const Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _OrganizationCredits(),
                            SizedBox(height: 52),
                            _DevelopmentCredits(),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrganizationCredits extends StatelessWidget {
  const _OrganizationCredits();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CreditSection(title: '發行單位', lines: ['國立中央大學國際處']),
        SizedBox(height: 64),
        _CreditSection(title: '指導監製', lines: ['王聖翔 老師']),
        SizedBox(height: 64),
        _CreditSection(title: '國際合作', lines: ['涉足學園音樂大學']),
      ],
    );
  }
}

class _DevelopmentCredits extends StatelessWidget {
  const _DevelopmentCredits();

  @override
  Widget build(BuildContext context) {
    return const _CreditSection(
      title: '遊戲App開發製作',
      lines: ['資管系 郭碩宏', '資工系 蔡佳穎', '資工系 葉芮丞', '經濟系 陸乾甫', '財金系 陳俊嘉', '光電系 羅靖宥'],
    );
  }
}

class _CreditSection extends StatelessWidget {
  const _CreditSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width >= 760 ? 46.0 : 32.0;
    final bodySize = width >= 760 ? 38.0 : 25.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectableText(
          title,
          textAlign: TextAlign.center,
          style: AppTheme.titleStyle.copyWith(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: SelectableText(
              line,
              textAlign: TextAlign.center,
              style: AppTheme.titleStyle.copyWith(
                color: Colors.white,
                fontSize: bodySize,
                fontWeight: FontWeight.w400,
                height: 1.28,
                letterSpacing: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}
