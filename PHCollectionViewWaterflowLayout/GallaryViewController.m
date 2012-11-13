//
//  GallaryViewController.m
//  PHCollectionViewWaterflowLayout
//
//  Created by Appublisher  on 12-11-12.
//  Copyright (c) 2012年 Appublisher . All rights reserved.
//

#import "GallaryViewController.h"

#import "PHCollectionViewWaterFlowLayout.h"
#import <PXAPI/PXAPI.h>
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>

#define CONSUMER_KEY @"b9tR1kc2KgFDqHYxRysdELK6qbE02ymTz4wZ3nn2"
#define CONSUMER_SECRET @"6yLTkJA2bBrRmVQCBe7KxXam27q5RMZ17qhx1bqb"

static NSString* GallaryCellIdentifier = @"GallaryCell";

@interface GallaryViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray* photoArray;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) PHCollectionViewWaterFlowLayout* waterflowLayout;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL isLoading;
@end

@implementation GallaryViewController

-(id)init{
    self = [super init];
    if (self) {
        self.photoArray = [NSMutableArray array];
        self.currentPage = 1;
        [PXRequest setConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.waterflowLayout = [[PHCollectionViewWaterFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) collectionViewLayout:self.waterflowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[GallaryCollectionViewCell class] forCellWithReuseIdentifier:GallaryCellIdentifier];
    
    [self.view addSubview:self.collectionView];
    
    [self fetchImageAtPage:self.currentPage andCount:20];
    
    //
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.collectionView.backgroundColor = [UIColor clearColor];
}

-(void)fetchImageAtPage:(NSInteger)page andCount:(NSInteger)count{
    self.isLoading = YES;
    [PXRequest requestForPhotoFeature:PXAPIHelperPhotoFeaturePopular resultsPerPage:count page:page photoSizes:PXPhotoModelSizeLarge completion:^(NSDictionary *results, NSError *error) {
        //get photo
        [self.photoArray addObjectsFromArray:results[@"photos"]];
        
        //calculate size
        NSMutableArray* sizeArray = [NSMutableArray array];
        for (NSDictionary* photo in self.photoArray){
            [sizeArray addObject:[NSValue valueWithCGSize:[GallaryCollectionViewCell sizeForPhoto:photo]]];
        }
        
        //set layout
        self.waterflowLayout.cellSizeArray = sizeArray;
        
        //reload and relayout
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.waterflowLayout invalidateLayout];
            [self.collectionView reloadData];
        });
        
        [self.collectionView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.5];
        
        self.currentPage++;
        self.isLoading = NO;
    }];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GallaryCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:GallaryCellIdentifier forIndexPath:indexPath];
    
//    [cell loadImage:((NSString*)self.photoArray[indexPath.row][@"image_url"][0])];
    
    [cell loadPhoto:self.photoArray[indexPath.row]];
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) && !self.isLoading) {
        [self fetchImageAtPage:self.currentPage andCount:20];
        NSLog(@"fectch page %d", self.currentPage);
    }
}

@end

#define TITLE_FONT_SIZE 12.

@interface GallaryCollectionViewCell()
@property (nonatomic, strong) AsyncImageView* imageView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* timestamp;
@end

@implementation GallaryCollectionViewCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        //add imageView
        self.imageView = [[AsyncImageView alloc] initWithFrame:CGRectZero];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
        
        //add title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        [self addSubview:self.titleLabel];
        
        //add timestamp
        self.timestamp = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timestamp.font = [UIFont systemFontOfSize:10.];
        self.timestamp.backgroundColor = [UIColor clearColor];
        self.timestamp.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timestamp];
    }
    
    return self;
}

-(void)loadPhoto:(NSDictionary *)photo{    
    //set all subviews' frame as well as content
    CGFloat cellHeight = 0.;
    self.imageView.frame = self.titleLabel.frame = self.timestamp.frame = CGRectZero;
    
    //imageView
    CGSize imageViewSize = CGSizeMake(90, 90 * [photo[@"height"] floatValue] / [photo[@"width"] floatValue]);
    self.imageView.frame = CGRectMake(5, 5, imageViewSize.width, imageViewSize.height);
    [self.imageView loadImage:photo[@"image_url"][0]];
    cellHeight = CGRectGetMaxY(self.imageView.frame);

    //titleLabel
    if (photo[@"name"]!=[NSNull null] && ![photo[@"name"] isEqualToString:@""]) {
        CGSize titleSize = [photo[@"name"] sizeWithFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE] constrainedToSize:CGSizeMake(90, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        self.titleLabel.frame = CGRectMake(5, cellHeight+5, 90, titleSize.height);
        self.titleLabel.text = photo[@"name"];
        cellHeight = CGRectGetMaxY(self.titleLabel.frame);
    }
    
    //timestamp
    self.timestamp.frame = CGRectMake(5, cellHeight+5, 90, 15);
    self.timestamp.text = [photo[@"created_at"] substringToIndex:9];
}

+(CGSize)sizeForPhoto:(NSDictionary*)photo{
    CGFloat cellHeight;
    CGSize imageViewSize = CGSizeMake(90, 90 * [photo[@"height"] floatValue] / [photo[@"width"] floatValue]);
    cellHeight = 5 + imageViewSize.height;
    
    if (photo[@"name"]!=[NSNull null] && ![photo[@"name"] isEqualToString:@""]) {
        CGSize titleSize = [photo[@"name"] sizeWithFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE] constrainedToSize:CGSizeMake(90, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        cellHeight += 5 + titleSize.height;
    }
    
    cellHeight += 5 + 15;//timestamp
    cellHeight += 5;//bottom spacing
    
    return CGSizeMake(100, cellHeight);
}

@end
