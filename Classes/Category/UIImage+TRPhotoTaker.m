//
//  UIImage+UzysExtension.m
//  UzysAssetsPickerController
//
//  Created by jianpx on 8/26/14.
//  Copyright (c) 2014 Uzys. All rights reserved.
//

#import "TGCameraNavigationController.h"
#import "UIImage+TRPhotoTaker.h"

@implementation UIImage (VideoCapture)

+ (UIImage *)TRPhotoTaker_imageNamed:(NSString *)imageName
{
    UIImage *image = [[self class] imageNamed:imageName];
    if (image) {
        return image;
    }

    //for Swift podfile
    NSString *imagePathInFrameworkForClass = [NSString stringWithFormat:@"%@/%@", [[NSBundle bundleForClass:[TGCameraNavigationController class]] resourcePath], imageName ];
    image = [[self class] imageNamed:imagePathInFrameworkForClass];
    if (image) {
        return image;
    }
    //bundel
    NSString *bundelName = @"TGCameraViewController.bundle";
    NSString *imagePathInBundleForClass = [NSString stringWithFormat:@"%@/%@/%@", [[NSBundle bundleForClass:[TGCameraNavigationController class]] resourcePath],bundelName, imageName];
    image = [[self class] imageNamed:imagePathInBundleForClass];
    return image;
}
@end
