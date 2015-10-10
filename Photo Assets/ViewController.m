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
@property (nonatomic, strong) NSMutableArray *resources;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSLog(@"Frigging Degraded key is %@", (NSString *)PHImageResultIsDegradedKey);
    
    [self readAssets];
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

- (NSMutableArray *)assets {
    
    if (!_resources) {
        _resources = [[NSMutableArray alloc]init];
    }
    return _resources;
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
                NSLog(@"Image added: %@", [result description]);
                
                // and also add the PHAssetResource for "full picture"
                NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
                
                for (PHAssetResource *resource in resources) {
                    if (resource.type == PHAssetResourceTypeFullSizePhoto) {
                        [self.resources addObject:asset];
                        NSLog(@"Asset added: %@", [asset description]);
                    }
                }
            }
        }];
    }
}

- (IBAction)displayAssets:(id)sender {
    
    // show a random image
    int i = arc4random() % self.images.count;
    self.imageView.image = [self.images objectAtIndex:(NSInteger)i];
}

- (IBAction)saveImageData:(id)sender {
    
    // save the first asset as data
    PHAssetResource *resource = self.resources.firstObject;
    PHAssetResourceManager *manager = [PHAssetResourceManager defaultManager];
    
    [manager requestDataForAssetResource:resource options:nil dataReceivedHandler:^(NSData * _Nonnull data) {
        // receive data here
        NSURL *dataURL = [[self applicationDocumentsDirectory]URLByAppendingPathComponent:@"AssetData"];
        
        if (![data writeToURL:dataURL atomically:YES]) {
            NSLog(@"Data File has been saved successfully");
        } else {
            NSLog(@"There was a problem saving the data file.");
        }
        
        // or
        
        [manager writeDataForAssetResource:resource toFile:dataURL options:nil completionHandler:^(NSError * _Nullable error) {
            NSLog(@"Data written - result was %@", error.localizedDescription);
        }];
        
        
    } completionHandler:^(NSError * _Nullable error) {
        // called when this thing is finished
        NSLog(@"Asset manager has finished with Error Code: %@", error.localizedDescription);
    }];
}

- (IBAction)loadImageData:(id)sender {
    
    // load data file
    NSURL *dataURL = [[self applicationDocumentsDirectory]URLByAppendingPathComponent:@"AssetData"];
    NSData *assetData = [[NSFileManager defaultManager]contentsAtPath:dataURL.path];
    PHAssetResource *resource = [[PHAssetResource alloc]init];
    
    
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
