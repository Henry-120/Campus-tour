package com.example.campus_tour.ar

import android.content.Context
import org.json.JSONObject

data class AndroidArModelConfig(
    val arRef: String,
    val assetPath: String,
    val targetHeightMeters: Float,
    val sourceHeightUnits: Float,
    val sourceCenterXUnits: Float,
) {
    val scale: Float
        get() = targetHeightMeters / sourceHeightUnits

    val centeredX: Float
        get() = -sourceCenterXUnits * scale
}

/** Resolves Firestore ARRef values to Android-only GLB assets. */
class ArModelCatalog(context: Context) {
    private val modelsByReference: Map<String, AndroidArModelConfig> =
        context.assets.open(CATALOG_PATH).bufferedReader().use { reader ->
            val root = JSONObject(reader.readText())
            root.getJSONArray("models").let { models ->
                buildMap {
                    for (index in 0 until models.length()) {
                        val item = models.getJSONObject(index)
                        val config = AndroidArModelConfig(
                            arRef = item.getString("arRef"),
                            assetPath = item.getString("assetPath"),
                            targetHeightMeters = item.optDouble("targetHeightMeters", 0.08).toFloat(),
                            sourceHeightUnits = item.optDouble("sourceHeightUnits", 1.0).toFloat(),
                            sourceCenterXUnits = item.optDouble("sourceCenterXUnits", 0.0).toFloat(),
                        )
                        put(normalize(config.arRef), config)
                        item.optJSONArray("aliases")?.let { aliases ->
                            for (aliasIndex in 0 until aliases.length()) {
                                put(normalize(aliases.getString(aliasIndex)), config)
                            }
                        }
                    }
                }
            }
        }

    fun resolve(arRef: String?): AndroidArModelConfig? =
        arRef?.let { modelsByReference[normalize(it)] }

    companion object {
        private const val CATALOG_PATH = "ar/model_catalog.json"

        private fun normalize(reference: String): String =
            reference.trim().replace('\\', '/').substringAfterLast('/').lowercase()
    }
}
