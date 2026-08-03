package com.yupao.demo.yp_flutter_recruitment_demo

import android.app.Application

object NativeStartupInitializer {
    fun init(application: Application) {
        // 生产应用通常在这里初始化隐私、崩溃、推送和广告 SDK。
        // 这里应保持轻量，重任务放到启动页首帧绘制后再开始。
    }
}
