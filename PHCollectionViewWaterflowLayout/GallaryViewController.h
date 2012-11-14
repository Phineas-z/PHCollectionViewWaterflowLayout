//
//  GallaryViewController.h
//  PHCollectionViewWaterflowLayout
//
//  Created by Appublisher  on 12-11-12.
//  Copyright (c) 2012年 Appublisher . All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GallaryViewController : UIViewController

@end

@interface GallaryCollectionViewCell : UICollectionViewCell

+(CGSize)sizeForPhoto:(NSDictionary*)photo;

-(void)loadPhoto:(NSDictionary*)photo;

@end