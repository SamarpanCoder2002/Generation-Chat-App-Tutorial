package com.youtubetutorial.generation

import android.content.Context
import android.database.Cursor
import android.graphics.Bitmap
import android.media.ThumbnailUtils
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.time.LocalDateTime

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.youtubetutorial.generation/nativeCallBack"

    companion object {
        val TAG: String = MainActivity::class.java.simpleName
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

//        // for Screenshot Restriction
//        getWindow().setFlags(
//            WindowManager.LayoutParams.FLAG_SECURE,
//            WindowManager.LayoutParams.FLAG_SECURE
//        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "makeVideoThumbnail") {
                val takeVideoPath: String? = call.argument("videoPath")

                takeVideoPath?.let {
                    result.success(makeVideoThumbnail(takeVideoPath.toString()))
                }

            } else {
                result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun makeVideoThumbnail(videoPath: String): String {
        val bitmap: Bitmap? = ThumbnailUtils.createVideoThumbnail(
            File(videoPath).path.toString(),
            MediaStore.Video.Thumbnails.MICRO_KIND
        )


        bitmap?.let {
            // CALL THIS METHOD TO GET THE URI FROM THE BITMAP
            val tempUri: Uri? = getImageUri(applicationContext, bitmap)

            // CALL THIS METHOD TO GET THE ACTUAL PATH
            val finalFile = File(getRealPathFromURI(tempUri))

            return finalFile.absolutePath;
        }

        return "";
    }

    /// Bitmap to Uri
    @RequiresApi(Build.VERSION_CODES.O)
    private fun getImageUri(inContext: Context, bitmapImage: Bitmap): Uri? {
        val path = MediaStore.Images.Media.insertImage(
            inContext.contentResolver,
            bitmapImage,
            LocalDateTime.now().toString(),
            null
        )

        return Uri.parse(path)
    }

    /// Uri to Actual Location Path
    private fun getRealPathFromURI(uri: Uri?): String {
        var path = ""

        try {
            uri?.let {
                contentResolver?.let {
                    val cursor: Cursor? = contentResolver.query(uri, null, null, null, null)

                    cursor?.let {
                        cursor.moveToFirst()
                        val index: Int = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA)
                        path = cursor.getString(index)
                        cursor.close()
                    }
                }
            }
        } catch (e: java.lang.Exception) {
            Log.i(TAG, "Error in Get Real Path From Uri: $uri")


        }
        return path

    }
}
