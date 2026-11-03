package io.github.zhuzhi09.pcl_pw

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** 共享存储：游戏文件夹放在 /storage/emulated/0 下，卸载应用后仍然保留 */
class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pclpw/storage").setMethodCallHandler { call, result ->
            when (call.method) {
                "externalRoot" -> result.success(Environment.getExternalStorageDirectory().absolutePath)
                "hasAccess" -> result.success(hasAccess())
                "requestAccess" -> requestAccess(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun hasAccess(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }

    private fun requestAccess(result: MethodChannel.Result) {
        if (hasAccess()) return result.success(true)
        pending?.success(false)
        pending = result
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11 起需要在系统设置里打开「所有文件访问权限」，回到应用时再检查
            try {
                startActivity(Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION, Uri.parse("package:$packageName")))
            } catch (_: Exception) {
                startActivity(Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION))
            }
        } else {
            requestPermissions(
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE),
                REQUEST_STORAGE,
            )
        }
    }

    override fun onResume() {
        super.onResume()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            pending?.success(hasAccess())
            pending = null
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_STORAGE) {
            pending?.success(hasAccess())
            pending = null
        }
    }

    companion object {
        private const val REQUEST_STORAGE = 1001
    }
}
