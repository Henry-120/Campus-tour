import 'dart:math' as math;

import 'package:campus_tour/controllers/shock_controllers.dart';
import 'package:campus_tour/styles/level_style.dart';
import 'package:campus_tour/widgets/game/catching_pages/cryptography_level.dart';
import 'package:campus_tour/widgets/game/catching_pages/monster_model_cry.dart';
import 'package:flutter/material.dart';

class CryptographyLevelPage extends StatefulWidget {
  const CryptographyLevelPage({
    super.key,
    required this.level,
    required this.monsterModel,
    required this.nextFunction,
    required this.finishFunction,
    required this.loseingFunction,
  });

  final CryptographyLevel level;
  final MonsterModelCry monsterModel;
  final VoidCallback nextFunction;
  final VoidCallback finishFunction;
  final VoidCallback loseingFunction;

  @override
  State<CryptographyLevelPage> createState() => _CryptographyLevelPageState();
}

class _CryptographyLevelPageState extends State<CryptographyLevelPage> {
  final ShockController _shockController = const ShockController();

  late int _playerHp;
  late int _enemyHp;
  int _questionIndex = 0;
  int? _selectedChoiceIndex;
  bool _isAnswerLocked = false;
  bool _isAnswerCorrect = false;
  String? _feedbackText;

  @override
  void initState() {
    super.initState();
    _playerHp = CryptographyLevel.playerMaxHp;
    _enemyHp =
        widget.level.questionSet.length *
        CryptographyLevel.enemyDamageOnCorrect;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LevelStyle.battleThemeForType(widget.monsterModel.type);
    final choices = widget.level.choiceSet[_questionIndex];

    return Scaffold(
      body: Container(
        decoration: LevelStyle.battlePageDecoration(theme),
        child: SafeArea(
          child: Padding(
            padding: LevelStyle.cryptographyPagePadding,
            child: Container(
              width: double.infinity,
              decoration: LevelStyle.battleShellDecoration(theme),
              clipBehavior: Clip.antiAlias, //子類抗鋸齒圓角設計
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final heroHeight = math.min(
                    360.0, //上限 360
                    math.max(
                      260.0,
                      constraints.maxHeight * 0.42,
                    ), //下限 260 或 42% 的高度，取較大者
                  );

                  return SingleChildScrollView(
                    //使有辦法滾動，避免在小螢幕或大量內容時溢出
                    child: ConstrainedBox(
                      //給定大小範圍的工具，可以設定最大最小值
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight, //最小高度為可用高度，確保內容不足時仍然填滿整個區域
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonsterHero(theme, heroHeight),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildQuestionCard(theme, choices),
                                const SizedBox(
                                  height: LevelStyle.battleSectionSpacing,
                                ),
                                _buildPlayerPanel(theme),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonsterHero(BattleLevelTheme theme, double height) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildMonsterImage(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  theme.primary.withValues(alpha: 0.16),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: math.min(320, MediaQuery.sizeOf(context).width - 88),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: _buildHpSection(
                  theme: theme,
                  currentHp: _enemyHp,
                  maxHp:
                      widget.level.questionSet.length *
                      CryptographyLevel.enemyDamageOnCorrect,
                  label: widget.monsterModel.name,
                  invertTextColor: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BattleLevelTheme theme, List<String> choices) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: LevelStyle.questionCardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.level.questionSet[_questionIndex],
            style: LevelStyle.questionStyle(theme),
          ),
          const SizedBox(height: 18),
          ...List.generate(choices.length, (index) {
            final selected = _selectedChoiceIndex == index;
            final correctAnswer = widget.level.answerSet[_questionIndex];
            final isCorrect =
                _isAnswerLocked && selected && choices[index] == correctAnswer;
            final isWrong = _isAnswerLocked && selected && !isCorrect;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == choices.length - 1
                    ? 0
                    : LevelStyle.choiceSpacing,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAnswerLocked
                      ? null
                      : () => _submitAnswer(index),
                  style: LevelStyle.answerButtonStyle(
                    theme,
                    isSelected: selected,
                    isCorrect: isCorrect,
                    isWrong: isWrong,
                  ),
                  child: Text(choices[index], textAlign: TextAlign.center),
                ),
              ),
            );
          }),
          if (_feedbackText != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                _feedbackText!,
                style: LevelStyle.feedbackStyle(
                  theme,
                  success: _isAnswerCorrect,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerPanel(BattleLevelTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: LevelStyle.infoCardDecoration(theme),
      child: _buildHpSection(
        theme: theme,
        currentHp: _playerHp,
        maxHp: CryptographyLevel.playerMaxHp,
        label: 'You',
      ),
    );
  }

  Widget _buildHpSection({
    required BattleLevelTheme theme,
    required int currentHp,
    required int maxHp,
    required String label,
    bool invertTextColor = false,
  }) {
    final clampedHp = currentHp.clamp(0, maxHp);
    final ratio = maxHp == 0 ? 0.0 : clampedHp / maxHp;
    final labelStyle = invertTextColor
        ? LevelStyle.hpLabelStyle(theme).copyWith(color: Colors.white)
        : LevelStyle.hpLabelStyle(theme);
    final valueStyle = invertTextColor
        ? LevelStyle.hpValueStyle(theme).copyWith(color: Colors.white)
        : LevelStyle.hpValueStyle(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: labelStyle),
            Text('$clampedHp / $maxHp', style: valueStyle),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          child: SizedBox(
            height: LevelStyle.hpBarHeight,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: LevelStyle.hpTrackDecoration(theme),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    decoration: LevelStyle.hpFillDecoration(theme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonsterImage() {
    final imagePath = widget.monsterModel.imageUrl.trim();
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (imagePath.isEmpty) {
      return _buildImageFallback();
    }

    return isNetworkImage
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => _buildImageFallback(),
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => _buildImageFallback(),
          );
  }

  Widget _buildImageFallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: const Icon(Icons.auto_awesome, size: 52, color: Colors.white),
    );
  }

  Future<void> _submitAnswer(int index) async {
    final selectedChoice = widget.level.choiceSet[_questionIndex][index];
    final correctAnswer = widget.level.answerSet[_questionIndex];
    final isCorrect = selectedChoice == correctAnswer;

    setState(() {
      _selectedChoiceIndex = index;
      _isAnswerLocked = true;
      _isAnswerCorrect = isCorrect;
      _feedbackText = isCorrect
          ? CryptographyLevel.correctMessage
          : '${CryptographyLevel.wrongMessage}，${CryptographyLevel.retryHint}';
      if (isCorrect) {
        _enemyHp = math.max(
          0,
          _enemyHp - CryptographyLevel.enemyDamageOnCorrect,
        );
      } else {
        _playerHp = math.max(
          0,
          _playerHp - CryptographyLevel.playerDamageOnWrong,
        );
      }
    });

    if (!isCorrect) {
      await _shockController.wrongAnswerShock();
    }

    await Future<void>.delayed(CryptographyLevel.feedbackDuration);
    if (!mounted) {
      return;
    }

    if (!isCorrect && _playerHp <= 0) {
      widget.loseingFunction();
      return;
    }

    if (!isCorrect) {
      setState(() {
        _selectedChoiceIndex = null;
        _isAnswerLocked = false;
        _feedbackText = null;
      });
      return;
    }

    widget.nextFunction();

    if (_questionIndex >= widget.level.questionSet.length - 1 ||
        _enemyHp <= 0) {
      setState(() {
        _feedbackText = CryptographyLevel.finishMessage;
      });
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        widget.finishFunction();
      }
      return;
    }

    setState(() {
      _questionIndex += 1;
      _selectedChoiceIndex = null;
      _isAnswerLocked = false;
      _feedbackText = null;
    });
  }
}
