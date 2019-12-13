package com.youxi.chat.module.file

import com.netease.nim.uikit.common.util.file.FileUtil
import com.youxi.chat.R
import java.util.*

object FileIcons {
    private val smallIconMap: MutableMap<String, Int> = HashMap()
    private val bigIconMap: MutableMap<String, Int> = HashMap()
    fun smallIcon(fileName: String?): Int {
        val ext = FileUtil.getExtensionName(fileName).toLowerCase()
        return smallIconMap[ext] ?: return R.drawable.file_ic_session_unknow
    }

    fun bigIcon(fileName: String?): Int {
        val ext = FileUtil.getExtensionName(fileName).toLowerCase()
        return bigIconMap[ext] ?: return R.drawable.file_ic_detail_unknow
    }

    init {
        smallIconMap["xls"] = R.drawable.file_ic_session_excel
        smallIconMap["ppt"] = R.drawable.file_ic_session_ppt
        smallIconMap["doc"] = R.drawable.file_ic_session_word
        smallIconMap["xlsx"] = R.drawable.file_ic_session_excel
        smallIconMap["pptx"] = R.drawable.file_ic_session_ppt
        smallIconMap["docx"] = R.drawable.file_ic_session_word
        smallIconMap["pdf"] = R.drawable.file_ic_session_pdf
        smallIconMap["html"] = R.drawable.file_ic_session_html
        smallIconMap["htm"] = R.drawable.file_ic_session_html
        smallIconMap["txt"] = R.drawable.file_ic_session_txt
        smallIconMap["rar"] = R.drawable.file_ic_session_rar
        smallIconMap["zip"] = R.drawable.file_ic_session_zip
        smallIconMap["7z"] = R.drawable.file_ic_session_zip
        smallIconMap["mp4"] = R.drawable.file_ic_session_mp4
        smallIconMap["mp3"] = R.drawable.file_ic_session_mp3
        smallIconMap["png"] = R.drawable.file_ic_session_png
        smallIconMap["gif"] = R.drawable.file_ic_session_gif
        smallIconMap["jpg"] = R.drawable.file_ic_session_jpg
        smallIconMap["jpeg"] = R.drawable.file_ic_session_jpg
    }

    init {
        bigIconMap["xls"] = R.drawable.file_ic_detail_excel
        bigIconMap["ppt"] = R.drawable.file_ic_detail_ppt
        bigIconMap["doc"] = R.drawable.file_ic_detail_word
        bigIconMap["xlsx"] = R.drawable.file_ic_detail_excel
        bigIconMap["pptx"] = R.drawable.file_ic_detail_ppt
        bigIconMap["docx"] = R.drawable.file_ic_detail_word
        bigIconMap["pdf"] = R.drawable.file_ic_detail_pdf
        bigIconMap["html"] = R.drawable.file_ic_detail_html
        bigIconMap["htm"] = R.drawable.file_ic_detail_html
        bigIconMap["txt"] = R.drawable.file_ic_detail_txt
        bigIconMap["rar"] = R.drawable.file_ic_detail_rar
        bigIconMap["zip"] = R.drawable.file_ic_detail_zip
        bigIconMap["7z"] = R.drawable.file_ic_detail_zip
        bigIconMap["mp4"] = R.drawable.file_ic_detail_mp4
        bigIconMap["mp3"] = R.drawable.file_ic_detail_mp3
        bigIconMap["png"] = R.drawable.file_ic_detail_png
        bigIconMap["gif"] = R.drawable.file_ic_detail_gif
        bigIconMap["jpg"] = R.drawable.file_ic_detail_jpg
        bigIconMap["jpeg"] = R.drawable.file_ic_detail_jpg
    }
}