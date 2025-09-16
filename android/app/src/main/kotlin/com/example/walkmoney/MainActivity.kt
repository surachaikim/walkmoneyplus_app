package com.mixproad.walkmoney

import android.content.ContentValues
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    // ตั้งชื่อ Channel ของเรา (ต้องตรงกับฝั่ง Dart)
    private val CHANNEL = "com.mixproad.walkmoney/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            // ตรวจสอบว่าคำสั่งที่ส่งมาคือ 'saveImage' หรือไม่
            if (call.method == "saveImage") {
                val path = call.argument<String>("path")
                if (path != null) {
                    try {
                        saveImageToGallery(path)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", "Failed to save image.", e.message)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "File path is null.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // ฟังก์ชันสำหรับบันทึกรูปภาพลง Gallery
    private fun saveImageToGallery(path: String) {
        val file = File(path)
        val bitmap = BitmapFactory.decodeFile(file.absolutePath)
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, "receipt_${System.currentTimeMillis()}.png")
            put(MediaStore.MediaColumns.MIME_TYPE, "image/png")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.RELATIVE_PATH, "Pictures/WalkMoney")
            }
        }
        val resolver = applicationContext.contentResolver
        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
        uri?.let {
            resolver.openOutputStream(it).use { outputStream ->
                if (outputStream != null) {
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                }
            }
        }
    }
}