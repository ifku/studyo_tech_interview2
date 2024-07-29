package com.ifkusyoba.studyo_tech_interview2

import android.media.MediaMetadataRetriever
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val deviceInfoChannelName = "get-device-info"
    private val videoInfoChannelName = "get-video-info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val deviceInfoChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceInfoChannelName)
        val videoInfoChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, videoInfoChannelName)

        deviceInfoChannel.setMethodCallHandler { call, result ->
            if (call.method == "getDeviceInfo") {
                val deviceInfo = getDeviceInfo()
                result.success(deviceInfo)
            } else {
                result.notImplemented()
            }
        }

        videoInfoChannel.setMethodCallHandler { call, result ->
            if (call.method == "getVideoInfo") {
                val videoPath = call.argument<String>("videoPath")
                if (videoPath != null) {
                    val videoInfo = getVideoInfo(videoPath)
                    result.success(videoInfo)
                } else {
                    result.error("INVALID_ARGUMENT", "Video path is required", null)
                }
            } else {
                result.notImplemented();
            }
        }
    }

    private fun getDeviceInfo(): Map<String, String> {
        return mapOf(
            "model" to Build.MODEL,
            "brand" to Build.BRAND,
            "device" to Build.DEVICE,
            "manufacturer" to Build.MANUFACTURER,
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkVersion" to Build.VERSION.SDK_INT.toString()
        )
    }

    private fun getVideoInfo(videoPath: String): Map<String, String> {
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(videoPath)
            val width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
            val height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
            val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            val bitrate = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)

            return mapOf(
                "width" to (width ?: "Unknown"),
                "height" to (height ?: "Unknown"),
                "duration" to (duration ?: "Unknown"),
                "bitrate" to (bitrate ?: "Unknown")
            )
        } finally {
            retriever.release();
        }
    }
}