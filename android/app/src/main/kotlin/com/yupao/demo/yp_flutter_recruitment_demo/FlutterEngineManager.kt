package com.yupao.demo.yp_flutter_recruitment_demo

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * 统一管理 Flutter 主引擎。
 *
 * Application、启动页和 Flutter 容器页只关心“拿到可用引擎”，
 * 引擎创建、插件注册、Dart 入口执行和缓存细节都收敛在这里。
 */
object FlutterEngineManager {
    private const val MAIN_ENGINE_ID = "main_engine"

    fun ensureMainEngine(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        cache.get(MAIN_ENGINE_ID)?.let { return it }

        synchronized(this) {
            cache.get(MAIN_ENGINE_ID)?.let { return it }

            val engine = FlutterEngine(context.applicationContext)
            GeneratedPluginRegistrant.registerWith(engine)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault(),
            )
            cache.put(MAIN_ENGINE_ID, engine)
            return engine
        }
    }
}
