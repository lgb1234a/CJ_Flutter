package com.youxi.chat.util.crash

import android.content.Context
import android.text.TextUtils
import com.netease.nim.uikit.common.util.storage.StorageType
import com.netease.nim.uikit.common.util.storage.StorageUtil
import com.netease.nim.uikit.common.util.string.MD5
import java.io.*
import java.text.SimpleDateFormat
import java.util.*

internal object CrashSaver {
    fun save(context: Context, ex: Throwable,
             uncaught: Boolean) {
        if (!StorageUtil.isExternalStorageExist()) { // 如果没有sdcard，则不存储
            return
        }
        var writer: Writer? = null
        var printWriter: PrintWriter? = null
        var stackTrace = ""
        try {
            writer = StringWriter()
            printWriter = PrintWriter(writer)
            ex.printStackTrace(printWriter)
            var cause = ex.cause
            while (cause != null) {
                cause.printStackTrace(printWriter)
                cause = cause.cause
            }
            stackTrace = writer.toString()
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            if (writer != null) {
                try {
                    writer.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
            printWriter?.close()
        }
        val signature = stackTrace.replace("\\([^\\(]*\\)".toRegex(), "")
        val filename = MD5.getStringMD5(signature)
        if (TextUtils.isEmpty(filename)) {
            return
        }
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        val date = Date()
        val timestamp = sdf.format(date)
        var mBufferedWriter: BufferedWriter? = null
        try {
            val mFile = File(StorageUtil.getWritePath(
                    "$filename.crashlog", StorageType.TYPE_LOG))
            val pFile = mFile.parentFile
            if (!pFile.exists()) { // 如果文件夹不存在，则先创建文件夹
                pFile.mkdirs()
            }
            var count = 1
            if (mFile.exists()) {
                var reader: LineNumberReader? = null
                try {
                    reader = LineNumberReader(FileReader(mFile))
                    val line = reader.readLine()
                    if (line.startsWith("count")) {
                        var index = line.indexOf(":")
                        if (index != -1) {
                            var count_str = line.substring(++index)
                            if (count_str != null) {
                                count_str = count_str.trim { it <= ' ' }
                                count = count_str.toInt()
                                count++
                            }
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                } finally {
                    if (reader != null) {
                        try {
                            reader.close()
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                }
                mFile.delete()
            }
            mFile.createNewFile()
            mBufferedWriter = BufferedWriter(FileWriter(mFile, true)) // 追加模式写文件
            mBufferedWriter.append(CrashSnapshot.snapshot(context, uncaught, timestamp, stackTrace, count))
            mBufferedWriter.flush()
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            if (mBufferedWriter != null) {
                try {
                    mBufferedWriter.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
        }
    }
}