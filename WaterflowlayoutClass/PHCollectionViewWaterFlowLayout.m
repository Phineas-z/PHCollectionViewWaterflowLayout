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
    
    //when there is no cellSizeArray, nothing to prepare
    if (!self.cellSizeArray || self.cellSizeArray.count==0) {
        return;
    }
    
    NSMutableArray* tempArray = [NSMutableArray array];
    float columnHeight[self.numberOfColumn];
    
    //init to 0 height
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
        
        //find the shortest column to add imageview
        int currentShortestColumn = [self indexOfMinValueOfArray:columnHeight withArrayLength:self.numberOfColumn];

        //add image to this column
        UICollectionViewLayoutAttributes* attributesForCell = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        CGRect frame = CGRectMake(horizontal_spacing+(self.columnWidth+horizontal_spacing)*currentShortestColumn, columnHeight[currentShortestColumn]+self.verticalSpacing, size.width, size.height);
        attributesForCell.frame = frame;
        [tempArray addObject:attributesForCell];
        //update shortest column height
        columnHeight[currentShortestColumn] += size.height+self.verticalSpacing;
    }
    
    //end up with calculating the max column height
    CGFloat maxColumnHeight = [self maxValueOfArray:columnHeight withArrayLength:self.numberOfColumn];
    
    self.contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), maxColumnHeight+self.verticalSpacing);
    
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

#pragma mark - Private Methods
-(int)indexOfMinValueOfArray:(float*)array withArrayLength:(int)length{
    int indexOfMin;
    for (int i=0; i<=length-1; i++) {
        if (i==0) {
            indexOfMin = 0;
        }else{
            if (array[i]<array[indexOfMin]) {
                indexOfMin = i;
            }
        }
    }
    
    return indexOfMin;
}

-(float)maxValueOfArray:(float*)array withArrayLength:(int)length{
    float max;
    for (int i=0; i<=length-1; i++) {
        if (i==0) {
            max = array[0];
        }else{
            if (array[i]>max) {
                max = array[i];
            }
        }
    }
    
    return max;
}

@end
