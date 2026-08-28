import 'package:campus_tour/styles/app_theme.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const String pageTitle = '關於咚谷粒';

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AppIntroduction(),

                      const SizedBox(height: 80),

                      isWide
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

class _AppIntroduction extends StatelessWidget {
  const _AppIntroduction();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width >= 760 ? 42.0 : 30.0;
    final bodySize = width >= 760 ? 24.0 : 18.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectableText(
          '關於咚谷粒',
          textAlign: TextAlign.center,
          style: AppTheme.titleStyle.copyWith(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 28),

        SelectableText(
          '「咚谷粒－校園導覽」是一款全新打造的中央大學校園導覽 App，'
          '結合多國語言、虛擬情境互動與遊戲化探索，希望讓來自不同國家與地區的使用者，'
          '都能用更有趣、更直覺的方式認識中央大學。\n\n'
          '為推動校園走向國際並提升校園導覽的互動體驗，國際事務處召集並支持學生團隊共同開發設計'
          '「咚谷粒－校園導覽」App。App 以圖鑑收集與校園探索遊戲為核心，'
          '將數位互動與實際走訪結合，鼓勵使用者親自穿梭校園，'
          '在探索與收集的過程中逐步認識中央大學。\n\n'
          '使用者可以透過遊戲化任務走訪校內不同地點，探索各學院與行政單位、'
          '中大十景、特色建築及裝置藝術，並在互動過程中了解相關介紹與校園特色。'
          '透過多國語言內容與虛實整合的導覽方式，讓校園導覽不再只是單向閱讀資訊，'
          '而是一場可以親自參與、探索與收藏的校園冒險。',
          textAlign: TextAlign.justify,
          style: AppTheme.titleStyle.copyWith(
            color: Colors.white,
            fontSize: bodySize,
            fontWeight: FontWeight.w400,
            height: 1.8,
            letterSpacing: 1.2,
          ),
        ),
      ],
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
        _CreditSection(title: '國際合作', lines: ['洗足學園音樂大學']),
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
      lines: ['資管系 郭碩宏', '資工系 蔡佳穎', '資工系 葉芮丞', '經濟系 陸竑甫', '財金系 陳俊嘉', '光電系 羅靖宥'],
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
