package com.yupao.demo.yp_flutter_recruitment_demo

import android.app.Application

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        NativeStartupInitializer.init(this)
    }
}
