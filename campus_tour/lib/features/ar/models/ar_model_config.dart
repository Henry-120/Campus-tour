class ArModelConfig {
  const ArModelConfig({
    required this.arRef,
    required this.androidAssetPath,
    required this.targetHeightMeters,
  });

  final String arRef;
  final String androidAssetPath;
  final double targetHeightMeters;

  static const androidCatalog = <ArModelConfig>[
    ArModelConfig(
      arRef: 'NCU_Lake.usdz',
      androidAssetPath: 'ar/models/monsters/NCU_Lake.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Hakka.usdz',
      androidAssetPath: 'ar/models/monsters/Hakka.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'ES.usdz',
      androidAssetPath: 'ar/models/monsters/ES.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Elephant.usdz',
      androidAssetPath: 'ar/models/monsters/Elephant.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Rock.usdz',
      androidAssetPath: 'ar/models/monsters/Rock.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Mechanic.usdz',
      androidAssetPath: 'ar/models/monsters/Mechanic.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'language.usdz',
      androidAssetPath: 'ar/models/monsters/language.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Recycle.usdz',
      androidAssetPath: 'ar/models/monsters/Recycle.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Math.usdz',
      androidAssetPath: 'ar/models/monsters/Math.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'SE.usdz',
      androidAssetPath: 'ar/models/monsters/SE.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'flower_river.usdz',
      androidAssetPath: 'ar/models/monsters/flower_river.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Management.usdz',
      androidAssetPath: 'ar/models/monsters/Management.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Infor_Engineer.usdz',
      androidAssetPath: 'ar/models/monsters/Infor_Engineer.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'DNA.usdz',
      androidAssetPath: 'ar/models/monsters/DNA.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Feather.usdz',
      androidAssetPath: 'ar/models/monsters/Feather.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'Sit_on_the_cloud.usdz',
      androidAssetPath: 'ar/models/monsters/Sit_on_the_cloud.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'sit_and_listen.usdz',
      androidAssetPath: 'ar/models/monsters/sit_and_listen.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'qmark.usdz',
      androidAssetPath: 'ar/models/monsters/qmark.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'clound.usdz',
      androidAssetPath: 'ar/models/monsters/clound.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'circle_90.usdz',
      androidAssetPath: 'ar/models/monsters/circle_90.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'squirrel.usdz',
      androidAssetPath: 'ar/models/monsters/squirrel.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'global_bboy.usdz',
      androidAssetPath: 'ar/models/monsters/global_bboy.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'school_landing.usdz',
      androidAssetPath: 'ar/models/monsters/school_landing.glb',
      targetHeightMeters: 0.08,
    ),
    ArModelConfig(
      arRef: 'pine_cone.usdz',
      androidAssetPath: 'ar/models/monsters/pine_cone.glb',
      targetHeightMeters: 0.08,
    ),
  ];

  static ArModelConfig? fromArRef(String? reference) {
    if (reference == null || reference.trim().isEmpty) return null;
    final normalized = reference
        .trim()
        .replaceAll('\\', '/')
        .split('/')
        .last
        .toLowerCase();
    for (final model in androidCatalog) {
      if (model.arRef.toLowerCase() == normalized) return model;
    }
    return null;
  }
}
