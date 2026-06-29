package com.example.shivaay_tailor

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Explicitly clear secure flag to allow taking screenshots across all pages and tabs
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
