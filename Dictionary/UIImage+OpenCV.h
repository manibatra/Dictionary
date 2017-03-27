//
//  UIImage+OpenCV.h
//  Dictionary
//
//  Created by Mani Batra on 26/3/17.
//  Copyright © 2017 Mani Batra. All rights reserved.
//

#import <opencv2/core.hpp>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#undef check



@interface UIImage (OpenCV)

//cv::Mat to UIImage
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

//UIImage to cv::Mat
- (cv::Mat)CVMat;
@end

