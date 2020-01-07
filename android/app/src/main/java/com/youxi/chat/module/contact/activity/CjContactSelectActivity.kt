package com.youxi.chat.module.contact.activity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.util.TypedValue
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.*
import androidx.appcompat.widget.SearchView
import androidx.core.view.MenuItemCompat
import com.netease.nim.uikit.R
import com.netease.nim.uikit.api.wrapper.NimToolBarOptions
import com.netease.nim.uikit.business.contact.core.item.AbsContactItem
import com.netease.nim.uikit.business.contact.core.item.ContactItem
import com.netease.nim.uikit.business.contact.core.item.ItemTypes
import com.netease.nim.uikit.business.contact.core.model.ContactGroupStrategy
import com.netease.nim.uikit.business.contact.core.model.IContact
import com.netease.nim.uikit.business.contact.core.provider.ContactDataProvider
import com.netease.nim.uikit.business.contact.core.provider.TeamMemberDataProvider
import com.netease.nim.uikit.business.contact.core.query.IContactDataProvider
import com.netease.nim.uikit.business.contact.core.query.TextQuery
import com.netease.nim.uikit.business.contact.core.viewholder.LabelHolder
import com.netease.nim.uikit.business.contact.selector.activity.ContactSelectActivity
import com.netease.nim.uikit.business.contact.selector.adapter.ContactSelectAdapter
import com.netease.nim.uikit.business.contact.selector.adapter.ContactSelectAvatarAdapter
import com.netease.nim.uikit.business.contact.selector.viewholder.ContactsMultiSelectHolder
import com.netease.nim.uikit.business.contact.selector.viewholder.ContactsSelectHolder
import com.netease.nim.uikit.business.session.constant.Extras
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.activity.ToolBarOptions
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.ui.liv.LetterIndexView
import com.netease.nim.uikit.common.ui.liv.LivIndex
import java.util.*

/**
 * 联系人选择器
 *
 *
 * Created by huangjun on 2015/3/3.
 */
class CjContactSelectActivity : UI(), View.OnClickListener, SearchView.OnQueryTextListener {
    // adapter
    private var contactAdapter: ContactSelectAdapter? = null
    private var contactSelectedAdapter: ContactSelectAvatarAdapter? = null
    // view
    private var listView: ListView? = null
    private var livIndex: LivIndex? = null
    private var bottomPanel: RelativeLayout? = null
    private var scrollViewSelected: HorizontalScrollView? = null
    private var imageSelectedGridView: GridView? = null
    private var btnSelect: Button? = null
    private var searchView: SearchView? = null
    // other
    private var queryText: String? = null
    private var option: ContactSelectActivity.Option? = null

    // class
    private class ContactsSelectGroupStrategy : ContactGroupStrategy() {
        init {
            add(GROUP_NULL, -1, "")
            addABC(0)
        }
    }

    /**
     * 联系人选择器配置可选项
     */
    enum class ContactSelectType {
        BUDDY, TEAM_MEMBER, TEAM
    }

    interface Callback {
        /**
         * 选择器结果
         */
        fun onSelect(data: Intent)
    }

    class Option : ContactSelectActivity.Option() {}
//    class Option : Serializable {
//        /**
//         * 联系人选择器中数据源类型：好友（默认）、群、群成员（需要设置teamId）
//         */
//        var type = ContactSelectType.BUDDY
//        /**
//         * 联系人选择器数据源类型为群成员时，需要设置群号
//         */
//        var teamId: String? = null
//        /**
//         * 联系人选择器标题
//         */
//        var title = "联系人选择器"
//        /**
//         * 联系人单选/多选（默认）
//         */
//        var multi = true
//        /**
//         * 至少选择人数
//         */
//        var minSelectNum = 1
//        /**
//         * 低于最少选择人数的提示
//         */
//        var minSelectedTip: String? = null
//        /**
//         * 最大可选人数
//         */
//        var maxSelectNum = 2000
//        /**
//         * 超过最大可选人数的提示
//         */
//        var maxSelectedTip: String? = null
//        /**
//         * 是否显示已选头像区域
//         */
//        var showContactSelectArea = true
//        /**
//         * 默认勾选（且可操作）的联系人项
//         */
//        var alreadySelectedAccounts: ArrayList<String>? = null
//        /**
//         * 需要过滤（不显示）的联系人项
//         */
//        var itemFilter: ContactItemFilter? = null
//        /**
//         * 需要disable(可见但不可操作）的联系人项
//         */
//        var itemDisableFilter: ContactItemFilter? = null
//        /**
//         * 是否支持搜索
//         */
//        var searchVisible = true
//        /**
//         * 允许不选任何人点击确定
//         */
//        var allowSelectEmpty = false
//        /**
//         * 是否显示最大数目，结合maxSelectNum,与搜索位置相同
//         */
//        var maxSelectNumVisible = false
//    }

    override fun onBackPressed() {
        if (searchView != null) {
            searchView!!.setQuery("", true)
            searchView!!.isIconified = true
        }
        showKeyboard(false)
        finish()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean { // search view
        menuInflater.inflate(R.menu.nim_contacts_search_menu, menu)
        val item = menu.findItem(R.id.action_search)
        if (!option!!.searchVisible) {
            item.isVisible = false
            return true
        }
        MenuItemCompat.setOnActionExpandListener(item, object : MenuItemCompat.OnActionExpandListener {
            override fun onMenuItemActionExpand(menuItem: MenuItem): Boolean {
                return true
            }

            override fun onMenuItemActionCollapse(menuItem: MenuItem): Boolean {
                finish()
                return false
            }
        })
        val searchView = MenuItemCompat.getActionView(item) as SearchView
        this.searchView = searchView
        this.searchView!!.visibility = if (option!!.searchVisible) View.VISIBLE else View.GONE
        searchView.setOnQueryTextListener(this)
        return true
    }

    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.nim_contacts_select)
        val options: ToolBarOptions = NimToolBarOptions()
        setToolBar(R.id.toolbar, options)
        parseIntentData()
        initAdapter()
        initListView()
        initContactSelectArea()
        loadData()
    }

    private fun parseIntentData() {
        option = intent.getSerializableExtra(EXTRA_DATA) as ContactSelectActivity.Option
        if (TextUtils.isEmpty(option!!.maxSelectedTip)) {
            option!!.maxSelectedTip = "最多选择" + option!!.maxSelectNum + "人"
        }
        if (TextUtils.isEmpty(option!!.minSelectedTip)) {
            option!!.minSelectedTip = "至少选择" + option!!.minSelectNum + "人"
        }
        title = option!!.title
    }

    private inner class ContactDataProviderEx(private val teamId: String?, vararg itemTypes: Int) : ContactDataProvider(*itemTypes) {
        private var loadedTeamMember = false
        override fun provide(query: TextQuery): List<AbsContactItem> {
            var data: List<AbsContactItem> = ArrayList()
            // 异步加载
            if (!loadedTeamMember) {
                TeamMemberDataProvider.loadTeamMemberDataAsync(teamId) { success ->
                    if (success) {
                        loadedTeamMember = true
                        // 列表重新加载数据
                        loadData()
                    }
                }
            } else {
                data = TeamMemberDataProvider.provide(query, teamId)
            }
            return data
        }

    }

    private fun initAdapter() {
        val dataProvider: IContactDataProvider
        if (option!!.type == ContactSelectType.TEAM_MEMBER && !TextUtils.isEmpty(option!!.teamId)) {
            dataProvider = ContactDataProviderEx(option!!.teamId, ItemTypes.TEAM_MEMBER)
        } else if (option!!.type == ContactSelectType.TEAM) {
            option!!.showContactSelectArea = false
            dataProvider = ContactDataProvider(ItemTypes.TEAM)
        } else {
            dataProvider = ContactDataProvider(ItemTypes.FRIEND)
        }
        // contact adapter
        contactAdapter = object : ContactSelectAdapter(this@CjContactSelectActivity, ContactsSelectGroupStrategy(),
                dataProvider) {
            var isEmptyContacts = false
            override fun onNonDataItems(): List<AbsContactItem>? {
                return null
            }

            override fun onPostLoad(empty: Boolean, queryText: String?, all: Boolean) {
                if (empty) {
                    if (TextUtils.isEmpty(queryText)) {
                        isEmptyContacts = true
                    }
                    updateEmptyView(queryText)
                } else {
                    setSearchViewVisible(true)
                }
            }

            private fun updateEmptyView(queryText: String?) {
                if (!isEmptyContacts && !TextUtils.isEmpty(queryText)) {
                    setSearchViewVisible(true)
                } else {
                    setSearchViewVisible(false)
                }
            }

            private fun setSearchViewVisible(visible: Boolean) {
                option!!.searchVisible = visible
                if (searchView != null) {
                    searchView!!.visibility = if (option!!.searchVisible) View.VISIBLE else View.GONE
                }
            }
        }
        val c = if (option!!.multi) ContactsMultiSelectHolder::class.java else ContactsSelectHolder::class.java
        contactAdapter!!.addViewHolder(ItemTypes.LABEL, LabelHolder::class.java)
        contactAdapter!!.addViewHolder(ItemTypes.FRIEND, c)
        contactAdapter!!.addViewHolder(ItemTypes.TEAM_MEMBER, c)
        contactAdapter!!.addViewHolder(ItemTypes.TEAM, c)
        contactAdapter!!.setFilter(option!!.itemFilter)
        contactAdapter!!.setDisableFilter(option!!.itemDisableFilter)
        // contact select adapter
        contactSelectedAdapter = ContactSelectAvatarAdapter(this)
    }

    private fun initListView() {
        listView = findView(R.id.contact_list_view)
        listView!!.setAdapter(contactAdapter)
        listView!!.setOnScrollListener(object : AbsListView.OnScrollListener {
            override fun onScrollStateChanged(view: AbsListView, scrollState: Int) {
                showKeyboard(false)
            }

            override fun onScroll(view: AbsListView, firstVisibleItem: Int, visibleItemCount: Int, totalItemCount: Int) {}
        })
        listView!!.setOnItemClickListener(AdapterView.OnItemClickListener { parent, view,
                                                                            position, id ->
            var position = position
            position = position - listView!!.getHeaderViewsCount()
            val item = contactAdapter!!.getItem(position) as AbsContactItem
                    ?: return@OnItemClickListener
            if (option!!.multi) {
                if (!contactAdapter!!.isEnabled(position)) {
                    return@OnItemClickListener
                }
                var contact: IContact? = null
                if (item is ContactItem) {
                    contact = item.contact
                }
                if (contactAdapter!!.isSelected(position)) {
                    contactAdapter!!.cancelItem(position)
                    if (contact != null) {
                        contactSelectedAdapter!!.removeContact(contact)
                    }
                } else {
                    if (contactSelectedAdapter!!.count <= option!!.maxSelectNum) {
                        contactAdapter!!.selectItem(position)
                        if (contact != null) {
                            contactSelectedAdapter!!.addContact(contact)
                        }
                    } else {
                        ToastHelper.showToast(this@CjContactSelectActivity, option!!.maxSelectedTip)
                    }
                    if (!TextUtils.isEmpty(queryText) && searchView != null) {
                        searchView!!.setQuery("", true)
                        searchView!!.isIconified = true
                        showKeyboard(false)
                    }
                }
                arrangeSelected()
            } else {
                if (item is ContactItem) {
                    val contact = item.contact
                    val selectedIds = ArrayList<String>()
                    val selectedNames = ArrayList<String>()
                    selectedIds.add(contact.contactId)
                    selectedNames.add(contact.displayName)
                    onSelected(selectedIds, selectedNames)
                }
                arrangeSelected()
            }
        })
        // 字母导航
        val letterHit = findViewById<View>(R.id.tv_hit_letter) as TextView
        val idxView = findViewById<View>(R.id.liv_index) as LetterIndexView
        idxView.setLetters(resources.getStringArray(R.array.letter_list2))
        val imgBackLetter = findViewById<View>(R.id.img_hit_letter) as ImageView
        if (option!!.type != ContactSelectType.TEAM) {
            livIndex = contactAdapter!!.createLivIndex(listView, idxView, letterHit, imgBackLetter)
            livIndex!!.show()
        } else {
            idxView.visibility = View.GONE
        }
    }

    private fun initContactSelectArea() {
        btnSelect = findViewById<View>(R.id.btnSelect) as Button
        if (!option!!.allowSelectEmpty) {
            btnSelect!!.isEnabled = false
        } else {
            btnSelect!!.isEnabled = true
        }
        btnSelect!!.setOnClickListener(this)
        bottomPanel = findViewById<View>(R.id.rlCtrl) as RelativeLayout
        scrollViewSelected = findViewById<View>(R.id.contact_select_area) as HorizontalScrollView
        if (option!!.multi) {
            bottomPanel!!.visibility = View.VISIBLE
            if (option!!.showContactSelectArea) {
                scrollViewSelected!!.visibility = View.VISIBLE
                btnSelect!!.visibility = View.VISIBLE
            } else {
                scrollViewSelected!!.visibility = View.GONE
                btnSelect!!.visibility = View.GONE
            }
            btnSelect!!.text = getOKBtnText(0)
        } else {
            bottomPanel!!.visibility = View.GONE
        }
        // selected contact image banner
        imageSelectedGridView = findViewById<View>(R.id.contact_select_area_grid) as GridView
        imageSelectedGridView!!.adapter = contactSelectedAdapter
        notifySelectAreaDataSetChanged()
        imageSelectedGridView!!.onItemClickListener = AdapterView.OnItemClickListener { parent, view, position, id ->
            try {
                if (contactSelectedAdapter!!.getItem(position) == null) {
                    return@OnItemClickListener
                }
                val iContact = contactSelectedAdapter!!.remove(position)
                if (iContact != null) {
                    contactAdapter!!.cancelItem(iContact)
                }
                arrangeSelected()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        // init already selected items
        val selectedUids: List<String>? = option!!.alreadySelectedAccounts
        if (selectedUids != null && !selectedUids.isEmpty()) {
            contactAdapter!!.setAlreadySelectedAccounts(selectedUids)
            val selectedItems = contactAdapter!!.selectedItem
            for (item in selectedItems) {
                contactSelectedAdapter!!.addContact(item.contact)
            }
            arrangeSelected()
        }
    }

    private fun loadData() {
        contactAdapter!!.load(true)
    }

    private fun arrangeSelected() {
        contactAdapter!!.notifyDataSetChanged()
        if (option!!.multi) {
            val count = contactSelectedAdapter!!.count
            if (!option!!.allowSelectEmpty) {
                btnSelect!!.isEnabled = count > 1
            } else {
                btnSelect!!.isEnabled = true
            }
            btnSelect!!.text = getOKBtnText(count)
            notifySelectAreaDataSetChanged()
        }
    }

    private fun notifySelectAreaDataSetChanged() {
        val converViewWidth = Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 46f, this.resources
                .displayMetrics))
        val layoutParams = imageSelectedGridView!!.layoutParams
        layoutParams.width = converViewWidth * contactSelectedAdapter!!.count
        layoutParams.height = converViewWidth
        imageSelectedGridView!!.layoutParams = layoutParams
        imageSelectedGridView!!.numColumns = contactSelectedAdapter!!.count
        try {
            val x = layoutParams.width
            val y = layoutParams.height
            Handler().post { scrollViewSelected!!.scrollTo(x, y) }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        contactSelectedAdapter!!.notifyDataSetChanged()
    }

    private fun getOKBtnText(count: Int): String {
        val caption = getString(R.string.ok)
        val showCount = if (count < 1) 0 else count - 1
        val sb = StringBuilder(caption)
        sb.append(" (")
        sb.append(showCount)
        if (option!!.maxSelectNumVisible) {
            sb.append("/")
            sb.append(option!!.maxSelectNum)
        }
        sb.append(")")
        return sb.toString()
    }

    /**
     * ************************** select ************************
     */
    override fun onClick(v: View) {
        if (v.id == R.id.btnSelect) {
            val contacts = contactSelectedAdapter!!.getSelectedContacts()
            if (option!!.allowSelectEmpty || checkMinMaxSelection(contacts.size)) {
                val selectedNames = ArrayList<String>()
                val selectedAccounts = ArrayList<String>()
                for (c in contacts) {
                    selectedAccounts.add(c.contactId)
                    selectedNames.add(c.displayName)
                }
                onSelected(selectedAccounts, selectedNames)
            }
        }
    }

    private fun checkMinMaxSelection(selected: Int): Boolean {
        if (option!!.minSelectNum > selected) {
            return showMaxMinSelectTip(true)
        } else if (option!!.maxSelectNum < selected) {
            return showMaxMinSelectTip(false)
        }
        return true
    }

    private fun showMaxMinSelectTip(min: Boolean): Boolean {
        if (min) {
            ToastHelper.showToast(this, option!!.minSelectedTip)
        } else {
            ToastHelper.showToast(this, option!!.maxSelectedTip)
        }
        return false
    }

    fun onSelected(selects: ArrayList<String>?, selectedNames: ArrayList<String>?) {
        val intent = Intent()
        intent.putStringArrayListExtra(RESULT_DATA, selects)
        intent.putStringArrayListExtra(Extras.RESULT_NAME, selectedNames)
        setResult(Activity.RESULT_OK, intent)
        callback?.onSelect(intent)
        finish()
    }

    /**
     * ************************* search ******************************
     */
    override fun onQueryTextChange(query: String): Boolean {
        queryText = query
        if (TextUtils.isEmpty(query)) {
            contactAdapter!!.load(true)
        } else {
            contactAdapter!!.query(query)
        }
        return true
    }

    override fun onQueryTextSubmit(arg0: String): Boolean {
        return false
    }

    override fun finish() {
        showKeyboard(false)
        super.finish()
    }

    companion object {
        const val EXTRA_DATA = "EXTRA_DATA" // 请求数据：Option
        const val RESULT_DATA = "RESULT_DATA" // 返回结果
        const val RESULT_NAME = "RESULT_NAME" //返回结果对应的的昵称或群名称
        var callback : Callback? = null // 选择器回调
        fun startActivityForResult(context: Context, option: Option, requestCode: Int) {
            val intent = Intent()
            intent.putExtra(EXTRA_DATA, option)
            intent.setClass(context, CjContactSelectActivity::class.java)
            (context as Activity).startActivityForResult(intent, requestCode)
        }
        fun startActivityForResult(context: Context, option: ContactSelectActivity.Option,
                                   callback: Callback) {
            val intent = Intent()
            intent.putExtra(EXTRA_DATA, option)
            intent.setClass(context, CjContactSelectActivity::class.java)
            this.callback = callback
            (context as Activity).startActivity(intent)
        }
    }
}