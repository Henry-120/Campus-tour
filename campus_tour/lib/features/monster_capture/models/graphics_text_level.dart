import 'discovered_item.dart';
import 'plot_level.dart';

class GraphicsTextLevel {
  // [L-01]
  GraphicsTextLevel({
    this.firstTracePhoto,
    this.storyReviewSteps = const [],
    this.discoveredItem,
    required this.nfcId,
  });

  // [L-02]
  final String? firstTracePhoto;
  final List<PlotDialogueStep> storyReviewSteps;
  final DiscoveredItem? discoveredItem;
  final String nfcId;
}
