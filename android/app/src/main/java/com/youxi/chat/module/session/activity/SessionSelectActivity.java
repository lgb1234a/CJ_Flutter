package com.youxi.chat.module.session.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.Toast;

import com.netease.nim.uikit.api.NimUIKit;
import com.netease.nim.uikit.business.contact.core.item.AbsContactItem;
import com.netease.nim.uikit.business.contact.core.item.ContactItem;
import com.netease.nim.uikit.business.contact.core.item.ItemTypes;
import com.netease.nim.uikit.business.contact.core.model.ContactDataAdapter;
import com.netease.nim.uikit.business.contact.core.model.ContactGroupStrategy;
import com.netease.nim.uikit.business.contact.core.model.IContact;
import com.netease.nim.uikit.business.contact.core.provider.ContactDataProvider;
import com.netease.nim.uikit.business.contact.core.query.IContactDataProvider;
import com.netease.nim.uikit.business.contact.core.viewholder.ContactHolder;
import com.netease.nim.uikit.business.contact.core.viewholder.LabelHolder;
import com.netease.nim.uikit.business.contact.selector.activity.ContactSelectActivity;
import com.netease.nim.uikit.business.team.helper.TeamHelper;
import com.netease.nim.uikit.common.activity.ToolBarOptions;
import com.netease.nim.uikit.common.activity.UI;
import com.netease.nim.uikit.common.util.string.StringUtil;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.msg.model.RecentContact;
import com.netease.nimlib.sdk.team.model.CreateTeamResult;
import com.netease.nimlib.sdk.team.model.Team;
import com.youxi.chat.R;
import com.youxi.chat.module.session.RecentSessionCallback;
import com.youxi.chat.module.session.fragment.RecentSessionFragment;
import com.youxi.chat.module.team.TeamCreateHelper;

import java.util.ArrayList;

import androidx.appcompat.widget.SearchView;

public class SessionSelectActivity extends UI implements AdapterView.OnItemClickListener {
    public static final String EXTRA_DATA = "EXTRA_DATA"; // 请求数据：Option
    public static final String RESULT_DATA = "RESULT_DATA"; // 返回结果
    private int REQUEST_CODE_ADVANCED = 10;
    private RecentSessionFragment shareFragment;
    SearchView searchView;
    public ContactDataAdapter contactAdapter;
    public ListView lvContacts;

    public static void start(Activity context, Bundle bundle, int requestCode) {
        Intent intent = new Intent(context, SessionSelectActivity.class);
        intent.putExtras(bundle);
        context.startActivityForResult(intent, requestCode);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_session_select);
        initToolbar();
        showShareFragment();
        initContactAdapter();
        initSearchView();
    }

	private void initToolbar() {
		ToolBarOptions options = new ToolBarOptions();
		options.titleString = "选择";
		setToolBar(R.id.toolbar, options);
	}

    private void initContactAdapter() {
        lvContacts = findViewById(R.id.share_searchResultList);
        lvContacts.setVisibility(View.GONE);
        SearchGroupStrategy searchGroupStrategy = new SearchGroupStrategy();
        IContactDataProvider dataProvider = new ContactDataProvider(ItemTypes.FRIEND, ItemTypes.TEAM);
        contactAdapter = new ContactDataAdapter(this, searchGroupStrategy, dataProvider);
        contactAdapter.addViewHolder(ItemTypes.LABEL, LabelHolder.class);
        contactAdapter.addViewHolder(ItemTypes.FRIEND, ContactHolder.class);
        contactAdapter.addViewHolder(ItemTypes.TEAM, ContactHolder.class);


        lvContacts.setAdapter(contactAdapter);
        lvContacts.setOnItemClickListener(this);

        lvContacts.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
                showKeyboard(false);
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
            }
        });
        findViewById(R.id.share_layout).setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    //finish();
                    return true;
                }
                return false;
            }
        });
    }

    private static class SearchGroupStrategy extends ContactGroupStrategy {
        public static final String GROUP_FRIEND = "FRIEND";
        public static final String GROUP_TEAM = "TEAM";
        public static final String GROUP_MSG = "MSG";

        SearchGroupStrategy() {
            add(ContactGroupStrategy.GROUP_NULL, 0, "");
            add(GROUP_FRIEND, 1, "好友");
            add(GROUP_TEAM, 2, "群组");
            add(GROUP_MSG, 3, "聊天记录");
        }

        @Override
        public String belongs(AbsContactItem item) {
            switch (item.getItemType()) {
                case ItemTypes.FRIEND:
                    return GROUP_FRIEND;
                case ItemTypes.TEAM:
                    return GROUP_TEAM;
                case ItemTypes.MSG:
                    return GROUP_MSG;
                default:
                    return null;
            }
        }
    }

    private void initSearchView() {
        searchView = findView(R.id.share_search_edit);
        searchView.setIconifiedByDefault(false);
        //搜索框文字
        SearchView.SearchAutoComplete textView = (SearchView.SearchAutoComplete) searchView.findViewById(R.id.search_src_text);
        textView.setTextColor(Color.BLACK);
        textView.setHintTextColor(Color.GRAY);
        textView.setHint("搜索");
        //搜索框删除图标
        ImageView closeIcon = searchView.findViewById(R.id.search_close_btn);
        closeIcon.setImageResource(R.drawable.nim_grey_delete_icon);
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {

            @Override
            public boolean onQueryTextSubmit(String query) {
                showKeyboard(false);
                return false;
            }

            @Override
            public boolean onQueryTextChange(String query) {

                if (StringUtil.isEmpty(query)) {
//                    contactAdapter.notifyDataSetChanged();
                    lvContacts.setVisibility(View.GONE);
                } else {
//                    contactAdapter.notifyDataSetChanged();
                    lvContacts.setVisibility(View.VISIBLE);

                }
                contactAdapter.query(query);
                return true;
            }
        });
    }


    private void showShareFragment() {
        shareFragment = new RecentSessionFragment();
        getSupportFragmentManager()    //
                .beginTransaction()
                .add(R.id.share_fragment_container, shareFragment)   // 此处的R.id.fragment_container是要盛放fragment的父容器
                .commit();
        shareFragment.setCallback(new RecentSessionCallback() {
            @Override
            public void onRecentContactsLoaded() {

            }

            @Override
            public void onUnreadCountChange(int unreadCount) {

            }

            @Override
            public void onItemClick(final RecentContact recent) {
                ArrayList<com.youxi.chat.uikit.business.contact.core.model.RecentContactData> selectedAccounts = new ArrayList<>();
                com.youxi.chat.uikit.business.contact.core.model.RecentContactData recentContactData = new com.youxi.chat.uikit.business.contact.core.model.RecentContactData(recent.getSessionType(), recent.getContactId());
                selectedAccounts.add(recentContactData);
                onSelected(selectedAccounts);
            }

            @Override
            public String getDigestOfAttachment(RecentContact recent, MsgAttachment attachment) {
                return null;
            }

            @Override
            public String getDigestOfTipMsg(RecentContact recent) {
                return null;
            }

            @Override
            public String ToActivity(int i) {
                ContactSelectActivity.Option advancedOption = TeamHelper.getCreateContactSelectOption(null, 50);
                NimUIKit.startContactSelector(SessionSelectActivity.this, advancedOption, REQUEST_CODE_ADVANCED);
                return null;
            }
        });
//        getSupportFragmentManager()    //
//                .beginTransaction()
//                .add(R.id.share_fragment_container, shareFragment)   // 此处的R.id.fragment_container是要盛放fragment的父容器
//                .commit();
    }

    public void onSelected(ArrayList<com.youxi.chat.uikit.business.contact.core.model.RecentContactData> selects) {
        Intent intent = new Intent();
        intent.putExtra(RESULT_DATA, selects);
        setResult(Activity.RESULT_OK, intent);
        this.finish();
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view, int position, long l) {
        try {
            AbsContactItem item = (AbsContactItem) contactAdapter.getItem(position);
            if (item instanceof ContactItem) {
                IContact contact = ((ContactItem) item).getContact();
                ArrayList<com.youxi.chat.uikit.business.contact.core.model.RecentContactData> selects = new ArrayList<>();
                com.youxi.chat.uikit.business.contact.core.model.RecentContactData recentContactData = new com.youxi.chat.uikit.business.contact.core.model.RecentContactData(contact.getContactType() == IContact.Type.Friend ? SessionTypeEnum.P2P : SessionTypeEnum.Team, contact.getContactId());
                selects.add(recentContactData);
                onSelected(selects);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == REQUEST_CODE_ADVANCED) {
                final ArrayList<String> selected = data.getStringArrayListExtra(ContactSelectActivity.RESULT_DATA);

                if (selected != null && !selected.isEmpty()) {
                    if (selected.size() == 1) {
                        ArrayList<com.youxi.chat.uikit.business.contact.core.model.RecentContactData> selects = new ArrayList<>();
                        com.youxi.chat.uikit.business.contact.core.model.RecentContactData recentContactData = new com.youxi.chat.uikit.business.contact.core.model.RecentContactData(SessionTypeEnum.P2P, selected.get(0));
                        selects.add(recentContactData);
                        onSelected(selects);
                    } else if (selected.size() > 1) {
                        //创建群聊
                        TeamCreateHelper.INSTANCE.createAdvancedTeam(SessionSelectActivity.this,
								selected,
								new RequestCallback<CreateTeamResult>() {
                            @Override
                            public void onSuccess(CreateTeamResult createTeamResult) {
                                if (createTeamResult != null && createTeamResult.getTeam() != null) {
                                    Team team = createTeamResult.getTeam();
                                    ArrayList<com.youxi.chat.uikit.business.contact.core.model.RecentContactData> selects = new ArrayList<>();
                                    com.youxi.chat.uikit.business.contact.core.model.RecentContactData recentContactData = new com.youxi.chat.uikit.business.contact.core.model.RecentContactData(SessionTypeEnum.Team, team.getId());
                                    selects.add(recentContactData);
                                    onSelected(selects);
                                }
                            }

                            @Override
                            public void onFailed(int i) {
                                Toast.makeText(SessionSelectActivity.this, "创建失败！", Toast.LENGTH_SHORT).show();
                            }

                            @Override
                            public void onException(Throwable throwable) {
                                Toast.makeText(SessionSelectActivity.this, "创建异常！", Toast.LENGTH_SHORT).show();

                            }
                        });
                    } else {
                        Toast.makeText(SessionSelectActivity.this, "请选择至少一个联系人！", Toast.LENGTH_SHORT).show();
                    }
                }
            }
        }
    }
}
