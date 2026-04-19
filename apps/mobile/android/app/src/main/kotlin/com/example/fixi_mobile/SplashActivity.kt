package com.example.fixi_mobile

import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.VideoView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class SplashActivity : android.app.Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val videoView = VideoView(this).apply {
            setBackgroundColor(android.graphics.Color.BLACK)
            val uri = Uri.parse("android.resource://$packageName/${R.raw.crab_video}")
            setVideoURI(uri)
            setOnPreparedListener { mp ->
                mp.isLooping = true
                start()
            }
        }
        setContentView(videoView)

        val engine = FlutterEngine(this)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put("helpy_engine", engine)

        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(
                FlutterActivity
                    .withCachedEngine("helpy_engine")
                    .build(this)
            )
            finish()
        }, 1200)
    }
}
