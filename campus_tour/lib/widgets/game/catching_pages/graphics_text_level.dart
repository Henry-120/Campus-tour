import 'discovered_item.dart';

class GraphicsTextLevel {
  // [L-01]
  GraphicsTextLevel({
    this.firstTracePhoto,
    this.descriptionText,
    this.discoveredItem,
    required this.nfcId,
  });

  // [L-02]
  final String? firstTracePhoto;
  final String? descriptionText;
  final DiscoveredItem? discoveredItem;
  final String nfcId;
}
