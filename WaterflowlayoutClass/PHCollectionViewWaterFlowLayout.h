//
//  APWaterFlowLayout.h
//  TryCollectionView
//
//  Created by Phineas-z  on 12-11-9.
//  Copyright (c) 2012年 Phineas-z . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface  PHCollectionViewWaterFlowLayout: UICollectionViewFlowLayout

@property (nonatomic) NSInteger numberOfColumn;

@property (nonatomic, strong) NSArray* cellSizeArray;

@property (nonatomic) CGFloat columnWidth;

@property (nonatomic) CGFloat verticalSpacing;

@end

@protocol PHCollectionViewWaterFlowLayoutDelegate <NSObject>
@optional
-(CGRect)waterflowLayoutFrameForLoadingMoreFooter:(PHCollectionViewWaterFlowLayout*)waterflowLayout;

@end
