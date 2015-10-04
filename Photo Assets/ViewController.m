//
//  ViewController.m
//  Photo Assets
//
//  Created by Jay Versluis on 04/10/2015.
//  Copyright © 2015 Pinkstone Pictures LLC. All rights reserved.
//

#import "ViewController.h"
@import Photos;

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *images;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSLog(@"Frigging Degraded key is %@", (NSString *)PHImageResultIsDegradedKey);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)images {
    
    if (!_images) {
        _images = [[NSMutableArray alloc]init];
    }
    return _images;
}

# pragma mark - Photo Library Methods

- (IBAction)readAssets {
    
    // retrieve all images from the library
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    for (PHAsset *asset in result) {
        
        // display each asset as UIImage
        PHImageManager *manager = [PHImageManager defaultManager];
        CGSize imageSize = CGSizeMake(1024, 1024);
        [manager requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            // add image to our array - if it's hi-res
            if ([[info valueForKey:PHImageResultIsDegradedKey] isEqualToNumber:@0]) {
                [self.images addObject:result];
                NSLog(@"Asset added: %@", [result description]);
            }
        }];
    }
}

- (IBAction)displayAssets:(id)sender {
    
    // show a random image
    int i = arc4random() % self.images.count;
    self.imageView.image = [self.images objectAtIndex:(NSInteger)i];
}



@end
