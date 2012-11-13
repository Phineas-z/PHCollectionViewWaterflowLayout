//
//  APWaterFlowLayout.m
//  TryCollectionView
//
//  Created by Phinea-z  on 12-11-9.
//  Copyright (c) 2012年 Phineas-z . All rights reserved.
//

#import "PHCollectionViewWaterFlowLayout.h"

#define DEFAULT_COLUMN_NUMBER 3
#define DEFAULT_COLUMN_WIDTH 100
#define DEFAULT_VERTICAL_SPACING 10

@interface PHCollectionViewWaterFlowLayout()
@property (nonatomic, strong) NSArray* layoutAttributesArray;
@property (nonatomic) CGSize contentSize;

@end

@implementation PHCollectionViewWaterFlowLayout

-(id)init{
    self = [super init];
    if (self) {
        self.numberOfColumn = DEFAULT_COLUMN_NUMBER;
        self.columnWidth = DEFAULT_COLUMN_WIDTH;
        self.verticalSpacing = DEFAULT_VERTICAL_SPACING;
    }
    
    return self;
}

-(void)prepareLayout{
    [super prepareLayout];
    
    //
    if (!self.cellSizeArray || self.cellSizeArray.count==0) {
        return;
    }
    
    NSMutableArray* tempArray = [NSMutableArray array];
    float columnHeight[self.numberOfColumn];//这种方法必须要初始化，要不然数值很诡异
    
    for (int i=0; i<=self.numberOfColumn-1; i++) {
        columnHeight[i] = 0.;
    }
    
    CGFloat horizontal_spacing = (CGRectGetWidth(self.collectionView.bounds) - self.columnWidth*self.numberOfColumn) / (self.numberOfColumn + 1);
        
    //build the image map
    for (int i=0; i<=self.cellSizeArray.count-1; i++){
        CGSize size = [(NSValue*)self.cellSizeArray[i] CGSizeValue];
        //calculate the scaled size
        size.height = self.columnWidth * size.height / size.width;
        size.width = self.columnWidth;
        
        //which column to add
        int currentShortestColumn = 0;
        for (int columnToCompare=1; columnToCompare<=self.numberOfColumn-1; columnToCompare++) {
            if (columnHeight[columnToCompare] < columnHeight[currentShortestColumn]) {
                currentShortestColumn = columnToCompare;
            }
        }

        //add image to this column
        UICollectionViewLayoutAttributes* attributesForImage = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        CGRect frame = CGRectMake(horizontal_spacing+(self.columnWidth+horizontal_spacing)*currentShortestColumn, columnHeight[currentShortestColumn]+self.verticalSpacing, size.width, size.height);
        attributesForImage.frame = frame;
        [tempArray addObject:attributesForImage];
        //update shortest column height
        columnHeight[currentShortestColumn] += size.height+self.verticalSpacing;
    }
    
    //end up with calculating the max column height
    //Problem 1:给定一个数组，告诉我哪一个index值最小
    int currentlongestColumn = 0;
    for (int columnToCompare=1; columnToCompare<=self.numberOfColumn-1; columnToCompare++) {
        if (columnHeight[columnToCompare] > columnHeight[currentlongestColumn]) {
            currentlongestColumn = columnToCompare;
        }
    }
        
    self.contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), columnHeight[currentlongestColumn]+self.verticalSpacing);
    
    self.layoutAttributesArray = [NSArray arrayWithArray:tempArray];
}

-(CGSize)collectionViewContentSize{
    if (!self.cellSizeArray || self.cellSizeArray.count==0) {
        return CGSizeZero;
    }else{
        return self.contentSize;
    }
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    if (!self.cellSizeArray || self.cellSizeArray.count==0) {
        return nil;
    }
    
    NSMutableArray* intersectViewAtrributesArray = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes* attributesForView in self.layoutAttributesArray){
        if (CGRectIntersectsRect(attributesForView.frame, rect)) {
            [intersectViewAtrributesArray addObject:attributesForView];
        }
    }
    
    return [NSArray arrayWithArray:intersectViewAtrributesArray];
}

@end
