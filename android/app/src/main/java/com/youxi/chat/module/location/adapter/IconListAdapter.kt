package com.youxi.chat.module.location.adapter

import android.content.Context
import android.graphics.drawable.Drawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ImageView
import android.widget.TextView
import com.youxi.chat.R
import com.youxi.chat.module.location.adapter.IconListAdapter.IconListItem

/**
 * An adapter to store icons.
 */
class IconListAdapter(context: Context,
                      items: List<IconListItem>?) : ArrayAdapter<IconListItem?>(context, mResource, items) {
    protected var mInflater: LayoutInflater
    override fun getView(position: Int, convertView: View, parent: ViewGroup): View {
        val text: TextView
        val image: ImageView
        val view: View
        view = convertView ?: mInflater.inflate(mResource, parent, false)
        // Set text field
        text = view.findViewById<View>(R.id.text1) as TextView
        text.text = getItem(position)!!.title
        // Set resource icon
        image = view.findViewById<View>(R.id.icon) as ImageView
        image.setBackgroundDrawable(getItem(position)!!.resource)
        return view
    }

    class IconListItem(val title: String, val resource: Drawable?, val attach: Any?)

    companion object {
        private val mResource: Int = R.layout.icon_list_item
    }

    init {
        mInflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
    }
}