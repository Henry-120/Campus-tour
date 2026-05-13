import 'strategy_book_level.dart';

class GraphicsTextLevel {
  // [L-01]
  GraphicsTextLevel({
    this.firstTracePhoto,
    this.descriptionText,
    this.strategyBookLevel,
    required this.nfcId,
  });

  // [L-02]
  final String? firstTracePhoto;
  final String? descriptionText;
  final StrategyBookLevel? strategyBookLevel;
  final String nfcId;
}
