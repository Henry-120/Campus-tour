import 'package:campus_tour/widgets/constants/asset_paths.dart';

class StrategyBookLevel {
  // [L-01]
  static const String defaultTitle = '意外收穫！你找到了攻略秘集';
  static const String defaultNoteText = '詳見金屬指示牌';
  static const String defaultButtonText = '好好研究它';
  static const String defaultImagePath = AssetPaths.book;

  // [L-02]
  final String title;
  final String noteText;
  final String imagePath;
  final String buttonText;

  // [L-03]
  const StrategyBookLevel({
    this.title = defaultTitle,
    this.noteText = defaultNoteText,
    this.imagePath = defaultImagePath,
    this.buttonText = defaultButtonText,
  });
}
