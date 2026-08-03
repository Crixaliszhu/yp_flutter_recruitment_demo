package com.yupao.demo.yp_flutter_recruitment_demo

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.TextView

class SplashActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(createSplashView())

        window.decorView.post {
            FlutterEngineManager.ensureMainEngine(this)
            showNativeSplashAdThenOpenFlutter()
        }
    }

    private fun createSplashView(): FrameLayout {
        val root = FrameLayout(this)
        root.setBackgroundColor(Color.parseColor("#1677FF"))

        val title = TextView(this)
        title.text = "渔泡招聘"
        title.setTextColor(Color.WHITE)
        title.textSize = 28f
        title.gravity = Gravity.CENTER

        root.addView(
            title,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )
        return root
    }

    private fun showNativeSplashAdThenOpenFlutter() {
        // 模拟原生开屏广告位。真实应用在这里调用 Android 广告 SDK，
        // 等成功、失败、跳过或超时后再继续进入 Flutter。
        handler.postDelayed({ openFlutter() }, 1200)
    }

    private fun openFlutter() {
        startActivity(Intent(this, MainActivity::class.java))
        finish()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }
}
