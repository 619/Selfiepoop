//
//  GZStickerPackagePanel.m
//  MobileFramework
//
//  Created by zhaoy on 14/10/15.
//  Copyright © 2015 com.gz. All rights reserved.
//

#import "GZStickerPackagePanel.h"
#import "GZEmojiKeyboardControl.h"
#import "GZStickerPackage.h"
#import "GZStickerContentScrollView.h"

@interface GZStickerPackagePanel()<GZStickerContentScrollViewControl>

@property(strong, nonatomic)NSArray* stickerList;
@property(strong, nonatomic)UIView* currentHighlightView;

@end

@implementation GZStickerPackagePanel

- (instancetype)init
{
    self = [super init];
    
    self.alwaysBounceHorizontal = NO;
    self.bounces = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.tag = -1;

    return self;
}

- (void)updateStickerList:(NSArray*)stickerList
{
    if (!stickerList.count) {
        return;
    }
    
    self.stickerList = stickerList;
    [self refreshContent];
}

- (void)refreshContent
{
    if (!self.stickerList.count) {
        return;
    }
    
    float offsetX = 0;
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (GZStickerPackage* stickerPackage in self.stickerList) {
        UILabel* stickerTab = [UILabel new];
        [self addSubview:stickerTab];
        
        UIImageView* tabImageIcon = [UIImageView new];
        [stickerTab addSubview:tabImageIcon];
        
        tabImageIcon.tag = 1000;
        tabImageIcon.image = stickerPackage.icon;
        tabImageIcon.contentMode = UIViewContentModeCenter;
        
       [self updateIconViewInTab:stickerTab];

        stickerTab.textAlignment = NSTextAlignmentCenter;
        stickerTab.userInteractionEnabled = YES;
        stickerTab.tag = [self.stickerList indexOfObject:stickerPackage];
        [stickerTab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(onStickerTabTapped:)]];
        [stickerTab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo([NSNumber numberWithInteger:GZ_EMO_PACK_ITEM_WIDTH]);
            make.height.equalTo([NSNumber numberWithInteger:GZ_EMO_PACK_BAR_HEIGHT]);
            make.leading.equalTo([NSNumber numberWithInteger:offsetX]);
            make.top.equalTo(self.mas_top);
        }];
        
        offsetX += GZ_EMO_PACK_ITEM_WIDTH;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.stickerList firstObject] == stickerPackage) {
                [self selectTag:stickerTab fireDelegate:YES];
            }
        });
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentSize = CGSizeMake(self.stickerList.count *  GZ_EMO_PACK_ITEM_WIDTH, GZ_EMO_PACK_BAR_HEIGHT);
}

#pragma mark - Panel Click

- (void)selectTag:(UIView*)stickerTab fireDelegate:(BOOL)needFire
{
    if (stickerTab.tag >= self.stickerList.count ||
        stickerTab == self.currentHighlightView) {
        return;
    }
    
    [self scrollRectToVisible:stickerTab.frame animated:YES];
    
    if (needFire) {
        [self.controlDelegate tapPackagePaneAtIndex:(int)stickerTab.tag];
    }
    
    [self.currentHighlightView setBackgroundColor:[UIColor clearColor]];
    self.currentHighlightView = stickerTab;
    [stickerTab setBackgroundColor:[UIColor colorWithRGB:0xBBBBBB]];
    [self updateIconViewInTab:stickerTab];
}

- (void)onStickerTabTapped:(UIGestureRecognizer*)recognizer
{
    [self selectTag:recognizer.view fireDelegate:YES];
}


- (void)updateIconViewInTab:(UIView*)stickerTab
{
    UIImageView* iconView = [stickerTab viewWithTag:1000];
    [iconView removeFromSuperview];
    [stickerTab addSubview:iconView];
    [iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(stickerTab.mas_width);
        make.leading.equalTo(stickerTab.mas_leading);
        make.top.equalTo(stickerTab.mas_top).offset(-4);
        make.bottom.equalTo(stickerTab.mas_bottom).offset(-4);
    }];
}

#pragma mark Scroll Content Delegate

- (void)onScrolledToNewPackage:(int)index
{
    UIView* tab = [self viewWithTag:index];
    [self selectTag:tab fireDelegate:NO];
}

- (void)adjustPanelPositionAtIndex:(int)index
{
    UIView* tab = [self viewWithTag:index];
    [self scrollRectToVisible:tab.frame animated:YES];
}

@end
