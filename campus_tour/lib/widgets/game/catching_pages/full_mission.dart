import 'camara_level.dart';
import 'cryptography_level.dart';
import 'graphics_text_level.dart';
import 'trace_levle.dart';

/// FullMission represents exactly one of the four available level types
/// in this folder. It stores a `levelType` string and four nullable fields
/// (one for each level). Exactly one of those four fields must be non-null.
///
/// Patterned after `NfcResponse`'s guarded accessors: trying to access the
/// wrong level will throw a `StateError`.
class FullMission {
  final String levelType;

  final CamaraLevel? camaraLevel;
  final CryptographyLevel? cryptographyLevel;
  final GraphicsTextLevel? graphicsTextLevel;
  final TraceLevle? traceLevel;

  /// Public constructor — accepts already-initialized child level objects.
  /// Exactly one of the level fields must be non-null. The fields are
  /// `final` so callers must provide pre-built instances when constructing
  /// a `FullMission`.
  FullMission({
    required this.levelType,
    this.camaraLevel,
    this.cryptographyLevel,
    this.graphicsTextLevel,
    this.traceLevel,
  }) {
    final nonNullCount = [
      camaraLevel,
      cryptographyLevel,
      graphicsTextLevel,
      traceLevel,
    ].where((e) => e != null).length;

    if (nonNullCount != 1) {
      throw ArgumentError(
        'A FullMission must contain exactly one non-null level.',
      );
    }
  }

  // Convenience predicates
  bool get isCamara => camaraLevel != null;
  bool get isCryptography => cryptographyLevel != null;
  bool get isGraphicsText => graphicsTextLevel != null;
  bool get isTrace => traceLevel != null;

  // Guarded getters: accessing a different level than the one stored
  // throws a StateError — similar to NfcResponse.data behavior.
  CamaraLevel get camara {
    if (camaraLevel == null)
      throw StateError('Not a Camara level FullMission.');
    return camaraLevel!;
  }

  CryptographyLevel get cryptography {
    if (cryptographyLevel == null)
      throw StateError('Not a Cryptography level FullMission.');
    return cryptographyLevel!;
  }

  GraphicsTextLevel get graphicsText {
    if (graphicsTextLevel == null)
      throw StateError('Not a GraphicsText level FullMission.');
    return graphicsTextLevel!;
  }

  TraceLevle get trace {
    if (traceLevel == null) throw StateError('Not a Trace level FullMission.');
    return traceLevel!;
  }
}
