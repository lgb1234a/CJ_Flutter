//
//  CJSearchTableHeaderView.m
//  Runner
//
//  Created by chenyn on 2019/9/30.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJSearchTableHeaderView.h"
#import "NIMContactDefines.h"

CGFloat CJ_SearchViewMinWidth = 80;

@interface CJSearchCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *avatarImgView;

@end

@implementation CJSearchCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        _avatarImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _avatarImgView.backgroundColor = [UIColor yy_colorWithHexString:@"#8F8F8F33"];
        [self addSubview:_avatarImgView];
    }
    return self;
}

- (void)configData:(id<NIMGroupMemberProtocol>)item
{
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:item.memberId option:nil];
    _avatarImgView.image = info.avatarImage;
    co_launch(^{
        NSURL *url = [NSURL URLWithString:info.avatarUrlString];
        NSData *data = await([NSData async_dataWithContentsOfURL:url]);
        UIImage *image = await([UIImage async_imageWithData:data]);
        self.avatarImgView.image = image;
    });
}

@end

@interface CJSearchTableHeaderView ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UITextFieldDelegate,
CJTextFieldInput>

@property (nonatomic, strong) UICollectionView *mCollectionView;
@property (nonatomic, copy) NSArray <id<NIMGroupMemberProtocol>>*dataSource;
@property (nonatomic, strong) CJTextField *searchInput;

@end

@implementation CJSearchTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.mCollectionView];
        [self addSubview:self.searchInput];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat itemWidth = self.frame.size.height - 10;
    CGFloat sectionInsetHorizontal = 10.f;
    CGFloat itemMargin = 10;
    
    CGFloat contentWidth = self.dataSource.count == 0? 0:(sectionInsetHorizontal + itemWidth * self.dataSource.count + itemMargin * (self.dataSource.count - 1));
    CGFloat collectionViewWidth = MIN(contentWidth, self.frame.size.width - CJ_SearchViewMinWidth);
    self.mCollectionView.frame = CGRectMake(0, 0, collectionViewWidth, self.frame.size.height);
    
    self.searchInput.frame = CGRectMake(collectionViewWidth, 0, self.frame.size.width - collectionViewWidth, self.frame.size.height);
}

- (UICollectionView *)mCollectionView
{
    if(!_mCollectionView) {
        UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
        fl.itemSize = CGSizeMake(self.frame.size.height - 10, self.frame.size.height - 10);
        fl.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        fl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        fl.minimumInteritemSpacing = 5.f;
        
        _mCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:fl];
        _mCollectionView.delegate = self;
        _mCollectionView.dataSource = self;
        _mCollectionView.backgroundColor = [UIColor whiteColor];
        [_mCollectionView registerClass:CJSearchCollectionViewCell.class
             forCellWithReuseIdentifier:@"CJSearchCollectionViewCell"];
    }
    return _mCollectionView;
}

// 搜索输入框
- (CJTextField *)searchInput
{
    if(!_searchInput) {
        _searchInput = [[CJTextField alloc] initWithFrame:CGRectZero];
        _searchInput.leftViewMode = UITextFieldViewModeAlways;
        UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
        searchIcon.frame = CGRectMake(10, 6, 19, 19);
        _searchInput.leftView = searchIcon;
        _searchInput.delegate = self;
        _searchInput.cjInputDelegate = self;
        _searchInput.returnKeyType = UIReturnKeySearch;
        [_searchInput addTarget:self action:@selector(searchValueChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _searchInput;
}

// 刷新选中列表
- (void)refresh:(NSArray <id<NIMGroupMemberProtocol>>*)dataSource
{
    self.dataSource = dataSource;
    self.searchInput.text = @"";
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self.mCollectionView reloadData];
    
    if(self.dataSource.count > 0) {
        NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
        [self.mCollectionView scrollToItemAtIndexPath:endIndexPath
                                     atScrollPosition:UICollectionViewScrollPositionRight
                                             animated:NO];
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CJSearchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CJSearchCollectionViewCell" forIndexPath:indexPath];
    
    id<NIMGroupMemberProtocol> item = [self.dataSource tn_objectAtIndex:indexPath.row];
    [cell configData:item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<NIMGroupMemberProtocol> item = [self.dataSource tn_objectAtIndex:indexPath.row];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchHeaderDeselect:)])
    {
        [self.delegate searchHeaderDeselect:item];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchStatusChanged:)])
    {
        [self.delegate searchStatusChanged:YES];
    }
}

- (void)searchValueChanged
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchValueChanged:)])
    {
        [self.delegate searchValueChanged:self.searchInput.text];
    }
}

// 删除
- (void)deleteBackward
{
    if(self.searchInput.text.length == 0 && self.dataSource.count > 0)
    {
        id<NIMGroupMemberProtocol> item = self.dataSource.lastObject;
        if(self.delegate && [self.delegate respondsToSelector:@selector(searchHeaderDeselect:)])
        {
            [self.delegate searchHeaderDeselect:item];
            
            // 点击删除清空选中，需要取消搜索
            if(self.dataSource.count == 0) {
                [self.delegate searchStatusChanged:NO];
            }
        }
    }
}

// 点击搜索按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchInput resignFirstResponder];
    
    return YES;
}

@end
