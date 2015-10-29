//
//  TGPhotoViewController.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 15/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

@import AssetsLibrary;
#import "TGPhotoViewController.h"
#import "TGAssetsLibrary.h"
#import "TGCameraColor.h"
#import "TGCameraFilterView.h"
#import "UIImage+CameraFilters.h"
#import "TGTintedButton.h"
#import "UIImage+TRPhotoTaker.h"

static NSString* const kTGCacheSatureKey = @"TGCacheSatureKey";
static NSString* const kTGCacheCurveKey = @"TGCacheCurveKey";
static NSString* const kTGCacheVignetteKey = @"TGCacheVignetteKey";

@interface TGPhotoViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

@property (weak) id<TGCameraDelegate> delegate;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSCache *cachePhoto;
@property (nonatomic) BOOL albumPhoto;

+ (instancetype)newController;

@end



@implementation TGPhotoViewController

+ (instancetype)newWithDelegate:(id<TGCameraDelegate>)delegate photo:(UIImage *)photo
{
    TGPhotoViewController *viewController = [TGPhotoViewController newController];
    
    if (viewController) {
        viewController.delegate = delegate;
        viewController.photo = photo;
        viewController.cachePhoto = [[NSCache alloc] init];
    }
    
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _photoView.clipsToBounds = YES;
    _photoView.image = _photo;
    [self setupNavigationBar];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = NO;
    
    //    UIColor *c = [UIColor colorWithRed:0xf8/255.0 green:0xf8/255.0 blue:0xf8/255.0 alpha:1.0];
    //    [self.navigationController.navigationBar lt_setBackgroundColor:c];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    //
    UIFont *font = [UIFont boldSystemFontOfSize:19.f];
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : [UIColor blackColor]
                                     };
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
}

-(void)setupNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title = @"确定？";
    
//    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:(@selector(onBack:))];
//    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"继续" style:UIBarButtonItemStyleDone target:self action:@selector(onSure:)];
//    self.navigationItem.leftBarButtonItem = left;
//    self.navigationItem.rightBarButtonItem = right;

    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage TRPhotoTaker_imageNamed:@"uzysAP_navi_icon_close"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"继续" style:UIBarButtonItemStyleDone target:self action:@selector(onSure:)];
    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.rightBarButtonItem = right;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSure:(id)sender {
    // 就用这张
    if ( [_delegate respondsToSelector:@selector(cameraWillTakePhoto)]) {
        [_delegate cameraWillTakePhoto];
    }
    
    if ([_delegate respondsToSelector:@selector(cameraDidTakePhoto:)]) {
        _photo = _photoView.image;
        
        if (_albumPhoto) {
            [_delegate cameraDidSelectAlbumPhoto:_photo];
        } else {
            [_delegate cameraDidTakePhoto:_photo];
        }
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        TGAssetsLibrary *library = [TGAssetsLibrary defaultAssetsLibrary];
        
        void (^saveJPGImageAtDocumentDirectory)(UIImage *) = ^(UIImage *photo) {
            [library saveJPGImageAtDocumentDirectory:_photo resultBlock:^(NSURL *assetURL) {
                [_delegate cameraDidSavePhotoAtPath:assetURL];
            } failureBlock:^(NSError *error) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoWithError:)]) {
                    [_delegate cameraDidSavePhotoWithError:error];
                }
            }];
        };
        
        if ([[TGCamera getOption:kTGCameraOptionSaveImageToAlbum] boolValue] && status != ALAuthorizationStatusDenied) {
            [library saveImage:_photo resultBlock:^(NSURL *assetURL) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                    [_delegate cameraDidSavePhotoAtPath:assetURL];
                }
            } failureBlock:^(NSError *error) {
                saveJPGImageAtDocumentDirectory(_photo);
            }];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                saveJPGImageAtDocumentDirectory(_photo);
            }
        }
    }

}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)dealloc
{
    _photoView = nil;
    _photo = nil;
    _cachePhoto = nil;
}

+ (instancetype)newController
{
    return [super new];
}

@end
