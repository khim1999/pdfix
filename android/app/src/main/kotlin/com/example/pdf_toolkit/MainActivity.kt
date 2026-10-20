package com.example.pdf_toolkit

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val TAG = "PDFIX_SHARE"
    private val CHANNEL = "com.ttfc.pdfix/direct_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.i(TAG, "configureFlutterEngine called, registering channel $CHANNEL")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.i(TAG, "Received method call: ${call.method} with args: ${call.arguments}")
            when (call.method) {
                "shareDirect" -> {
                    val filePath = call.argument<String>("filePath")
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
                    val title = call.argument<String>("title") ?: "Share file"

                    Log.i(TAG, "shareDirect: path=$filePath, packages=$packages, mime=$mimeType")

                    if (filePath == null) {
                        Log.e(TAG, "filePath is null")
                        result.error("INVALID_PATH", "File path cannot be null", null)
                        return@setMethodCallHandler
                    }

                    val file = File(filePath)
                    if (!file.exists()) {
                        Log.e(TAG, "file does not exist: $filePath")
                        result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                        return@setMethodCallHandler
                    }

                    // Check if any candidate package is installed
                    val targetPackage = packages.firstOrNull { pkg ->
                        try {
                            packageManager.getPackageInfo(pkg, 0)
                            Log.i(TAG, "Package $pkg is installed!")
                            true
                        } catch (e: Exception) {
                            Log.d(TAG, "Package $pkg not installed: ${e.message}")
                            false
                        }
                    }

                    if (targetPackage == null && packages.isNotEmpty()) {
                        Log.w(TAG, "None of the candidate packages are installed: $packages")
                        result.success(false) // Target not installed
                        return@setMethodCallHandler
                    }

                    try {
                        val authority = "${applicationContext.packageName}.fileprovider"
                        val uri: Uri = FileProvider.getUriForFile(this, authority, file)
                        Log.i(TAG, "Generated URI: $uri with authority $authority")

                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = mimeType
                            putExtra(Intent.EXTRA_STREAM, uri)
                            putExtra(Intent.EXTRA_SUBJECT, title)
                            clipData = android.content.ClipData.newRawUri(title, uri)
                            if (targetPackage != null) {
                                setPackage(targetPackage)
                            }
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }

                        // Explicitly resolve matching activity inside target package
                        if (targetPackage != null) {
                            applicationContext.grantUriPermission(targetPackage, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            val resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
                            val matched = resolveInfos.firstOrNull { it.activityInfo.packageName == targetPackage }
                                ?: packageManager.queryIntentActivities(intent, 0).firstOrNull { it.activityInfo.packageName == targetPackage }

                            if (matched != null) {
                                Log.i(TAG, "Setting explicit component: ${matched.activityInfo.packageName}/${matched.activityInfo.name}")
                                intent.component = ComponentName(matched.activityInfo.packageName, matched.activityInfo.name)
                            } else {
                                Log.w(TAG, "No specific activity matched for $targetPackage, using package target")
                            }
                        }

                        if (targetPackage == null) {
                            val chooser = Intent.createChooser(intent, title).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(chooser)
                        } else {
                            startActivity(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error during share: ${e.message}", e)
                        result.error("SHARE_ERROR", e.message, null)
                    }
                }
                "checkInstalled" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    val isInstalled = packages.any { pkg ->
                        try {
                            packageManager.getPackageInfo(pkg, 0)
                            true
                        } catch (e: Exception) {
                            false
                        }
                    }
                    result.success(isInstalled)
                }
                "setSecureScreen" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    runOnUiThread {
                        if (enabled) {
                            window.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                            Log.i(TAG, "FLAG_SECURE enabled (anti-screenshot & anti-spy screen active)")
                        } else {
                            window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
                            Log.i(TAG, "FLAG_SECURE disabled")
                        }
                        result.success(true)
                    }
                }
                "isSecureScreen" -> {
                    val isSecure = (window.attributes.flags and android.view.WindowManager.LayoutParams.FLAG_SECURE) != 0
                    result.success(isSecure)
                }
                else -> result.notImplemented()
            }
        }
    }
}
