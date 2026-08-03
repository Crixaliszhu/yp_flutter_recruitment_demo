package com.yupao.demo.yp_flutter_recruitment_demo

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine {
        return FlutterEngineManager.ensureMainEngine(context)
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false
}
