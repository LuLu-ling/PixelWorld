package io.github.zhuzhi09.pcl_pw

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.github.zhuzhi09.pclpw.runtime.GameActivity
import io.github.zhuzhi09.pclpw.runtime.GameRuntime
import java.io.File
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        // 共享存储：游戏文件夹放在 /storage/emulated/0 下，卸载应用后仍然保留
        MethodChannel(messenger, "pclpw/storage").setMethodCallHandler { call, result ->
            when (call.method) {
                "externalRoot" -> result.success(Environment.getExternalStorageDirectory().absolutePath)
                "hasAccess" -> result.success(hasAccess())
                "requestAccess" -> requestAccess(result)
                else -> result.notImplemented()
            }
        }
        // 标题栏显示的电量与网络（启动器全屏时系统状态栏被隐藏）
        MethodChannel(messenger, "pclpw/device").setMethodCallHandler { call, result ->
            if (call.method != "status") return@setMethodCallHandler result.notImplemented()
            val battery = getSystemService(BATTERY_SERVICE) as BatteryManager
            val cm = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
            val caps = cm.getNetworkCapabilities(cm.activeNetwork)
            val network = when {
                caps == null -> "none"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
                else -> "other"
            }
            result.success(
                mapOf(
                    "battery" to battery.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY),
                    "charging" to battery.isCharging,
                    "network" to network,
                ),
            )
        }
        // 游戏运行时（android/runtime 模块）
        MethodChannel(messenger, "pclpw/runtime").setMethodCallHandler { call, result ->
            when (call.method) {
                "prepare" -> background(result) {
                    mapOf(
                        "nativeLibDir" to applicationInfo.nativeLibraryDir,
                        "lwjglClasspath" to GameRuntime.lwjglClasspath(this),
                        "lwjglVersion" to GameRuntime.LWJGL_VERSION,
                    )
                }
                "installJre" -> background(result) {
                    GameRuntime.installJre(this, File(call.argument<String>("archive")!!), File(call.argument<String>("dest")!!))
                    null
                }
                "launch" -> {
                    val intent = Intent(this, GameActivity::class.java)
                        .putExtra(GameActivity.EXTRA_JAVA_HOME, call.argument<String>("javaHome"))
                        .putExtra(GameActivity.EXTRA_GAME_DIR, call.argument<String>("gameDir"))
                        .putExtra(GameActivity.EXTRA_LOG_FILE, call.argument<String>("logFile"))
                        .putExtra(GameActivity.EXTRA_ARGS, call.argument<List<String>>("args")!!.toTypedArray())
                        .putExtra(GameActivity.EXTRA_SCALE, (call.argument<Double>("scale") ?: 1.0).toFloat())
                    GameRuntime.exitFile(this).delete()
                    startActivity(intent)
                    result.success(null)
                }
                "isRunning" -> {
                    val am = getSystemService(ACTIVITY_SERVICE) as android.app.ActivityManager
                    result.success(am.runningAppProcesses?.any { it.processName == "$packageName:game" } == true)
                }
                // 本应用（含游戏进程）自某个时间点以来的系统日志，用于排查游戏进程崩溃
                "logcat" -> background(result) {
                    val since = call.argument<Number>("since")!!.toLong()
                    val t = String.format(java.util.Locale.ROOT, "%d.%03d", since / 1000, since % 1000)
                    val p = ProcessBuilder("logcat", "-d", "-v", "threadtime", "-T", t).redirectErrorStream(true).start()
                    val text = p.inputStream.bufferedReader().readText()
                    p.waitFor()
                    if (text.length > 200_000) text.substring(text.length - 200_000) else text
                }
                "lastExit" -> {
                    val f = GameRuntime.exitFile(this)
                    result.success(if (f.exists()) f.readText().also { f.delete() } else null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /** 在后台线程执行，完成后在主线程返回结果 */
    private fun background(result: MethodChannel.Result, job: () -> Any?) {
        thread {
            try {
                val value = job()
                runOnUiThread { result.success(value) }
            } catch (e: Throwable) {
                runOnUiThread { result.error("runtime", e.message ?: e.toString(), null) }
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
