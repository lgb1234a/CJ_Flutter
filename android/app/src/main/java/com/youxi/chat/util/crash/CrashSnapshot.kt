package com.youxi.chat.util.crash

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import android.text.TextUtils
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.common.util.sys.NetworkUtil
import com.youxi.chat.util.InstallUtil
import com.youxi.chat.util.SysInfoUtil
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.IOException
import java.util.*
import java.util.regex.Pattern

object CrashSnapshot {
    private var mTotalMemory: Long = -1
    /**
     * 检测手机是否Rooted
     *
     * @return
     */
    private val isRooted: Boolean
        private get() {
            val isSdk = isGoogleSdk
            val tags: Any? = Build.TAGS
            if (!isSdk && tags != null
                    && (tags as String).contains("test-keys")) {
                return true
            }
            if (File("/system/app/Superuser.apk").exists()) {
                return true
            }
            return if (!isSdk && File("/system/xbin/su").exists()) {
                true
            } else false
        }

    private val isGoogleSdk: Boolean
        private get() {
            val str = Settings.Secure.getString(NimUIKit.getContext().contentResolver, Settings.Secure.ANDROID_ID)
            return ("sdk" == Build.PRODUCT
                    || "google_sdk" == Build.PRODUCT || str == null)
        }

    /**
     * 获取手机剩余电量
     *
     * @return
     */
    private fun battery(): String {
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val intent = NimUIKit.getContext().registerReceiver(null, filter)
        val level = intent.getIntExtra("level", -1)
        val scale = intent.getIntExtra("scale", -1)
        return if (scale == -1) {
            "--"
        } else {
            String.format(Locale.US, "%d %%", level * 100 / scale)
        }
    }

    private val availMemory: Long
        private get() {
            val am = NimUIKit.getContext()
                    .getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val mi = ActivityManager.MemoryInfo()
            am.getMemoryInfo(mi)
            return mi.availMem
        }

    private fun parseFile(file: File, filter: String): String? {
        var str: String? = null
        if (file.exists()) {
            var br: BufferedReader? = null
            try {
                br = BufferedReader(FileReader(file), 1024)
                var line: String?
                while (br.readLine().also { line = it } != null) {
                    val pattern = Pattern.compile("\\s*:\\s*")
                    val ret = pattern.split(line, 2)
                    if (ret != null && ret.size > 1 && ret[0] == filter) {
                        str = ret[1]
                        break
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                try {
                    br!!.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
        }
        return str
    }

    private fun getSize(size: String, uint: String, factor: Int): Long {
        return size.split(uint).toTypedArray()[0].trim { it <= ' ' }.toLong() * factor
    }

    @get:Synchronized
    private val totalMemory: Long
        private get() {
            if (mTotalMemory == -1L) {
                var total = 0L
                var str: String
                try {
                    if (!TextUtils.isEmpty(parseFile(
                                    File("/proc/meminfo"), "MemTotal").also { str = it!! })) {
                        str = str.toUpperCase(Locale.US)
                        total = if (str.endsWith("KB")) {
                            getSize(str, "KB", 1024)
                        } else if (str.endsWith("MB")) {
                            getSize(str, "MB", 1048576)
                        } else if (str.endsWith("GB")) {
                            getSize(str, "GB", 1073741824)
                        } else {
                            -1
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                mTotalMemory = total
            }
            return mTotalMemory
        }

    @get:SuppressLint("NewApi")
    private val sdCardMemory: LongArray
        private get() {
            val sdCardInfo = LongArray(2)
            val state = Environment.getExternalStorageState()
            if (Environment.MEDIA_MOUNTED == state) {
                val sdcardDir = Environment.getExternalStorageDirectory()
                val sf = StatFs(sdcardDir.path)
                if (Build.VERSION.SDK_INT >= 18) {
                    val bSize = sf.blockSizeLong
                    val bCount = sf.blockCountLong
                    val availBlocks = sf.availableBlocksLong
                    sdCardInfo[0] = bSize * bCount
                    sdCardInfo[1] = bSize * availBlocks
                } else {
                    val bSize = sf.blockSize.toLong()
                    val bCount = sf.blockCount.toLong()
                    val availBlocks = sf.availableBlocks.toLong()
                    sdCardInfo[0] = bSize * bCount
                    sdCardInfo[1] = bSize * availBlocks
                }
            }
            return sdCardInfo
        }

    private fun disk(): String {
        val info = sdCardMemory
        val total = info[0]
        val avail = info[1]
        return if (total <= 0) {
            "--"
        } else {
            val ratio = (avail * 100 / total).toFloat()
            String.format(Locale.US, "%.01f%% [%s]", ratio, getSizeWithUnit(total))
        }
    }

    private fun ram(): String {
        val total = totalMemory
        val avail = availMemory
        return if (total <= 0) {
            "--"
        } else {
            val ratio = (avail * 100 / total).toFloat()
            String.format(Locale.US, "%.01f%% [%s]", ratio, getSizeWithUnit(total))
        }
    }

    private fun getSizeWithUnit(size: Long): String {
        return if (size >= 1073741824) {
            val i = (size / 1073741824).toFloat()
            String.format(Locale.US, "%.02f GB", i)
        } else if (size >= 1048576) {
            val i = (size / 1048576).toFloat()
            String.format(Locale.US, "%.02f MB", i)
        } else {
            val i = (size / 1024).toFloat()
            String.format(Locale.US, "%.02f KB", i)
        }
    }

    fun snapshot(context: Context, uncaught: Boolean, timestamp: String, trace: String?, count: Int): String {
        val info: MutableMap<String, String> = LinkedHashMap()
        info["count: "] = count.toString()
        info["time: "] = timestamp
        info["device: "] = SysInfoUtil.phoneModelWithManufacturer
        info["android: "] = SysInfoUtil.osInfo
        info["system: "] = Build.DISPLAY
        info["battery: "] = battery()
        info["rooted: "] = if (isRooted) "yes" else "no"
        info["ram: "] = ram()
        info["disk: "] = disk()
        info["ver: "] = String.format("%d", InstallUtil.getVersionCode(context))
        info["caught: "] = if (uncaught) "no" else "yes"
        info["network: "] = NetworkUtil.getNetworkInfo(context)
        val iterator: Iterator<Map.Entry<String, String>> = info.entries.iterator()
        val sb = StringBuilder()
        while (iterator.hasNext()) {
            val entry = iterator.next()
            if (entry != null) {
                sb.append(entry.key).append(entry.value)
                sb.append(System.getProperty("line.separator"))
            }
        }
        sb.append(System.getProperty("line.separator"))
        sb.append(trace)
        sb.append(System.getProperty("line.separator"))
        sb.append(System.getProperty("line.separator"))
        sb.append(System.getProperty("line.separator"))
        return sb.toString()
    }
}