//
//  OpenCVWrapper.m
//  Dictionary
//
//  Created by Mani Batra on 26/3/17.
//  Copyright © 2017 Mani Batra. All rights reserved.
//

#import "opencv2/core.hpp"
#import "opencv2/highgui/highgui.hpp"
#import "opencv2/imgproc/imgproc.hpp"
#import "UIImage+OpenCV.h"

#include <iostream>

#import "OpenCVWrapper.h"


using namespace cv;
using namespace std;


@implementation OpenCVWrapper

/**
 * Method name: processImageWithOpenCV
 * Description: pre processes the image with opencv and prepares it for OCR
 * Parameters: (UIImage*) inputImage -> UIImage
 */

+ (UIImage*) processImageWithOpenCV: (UIImage*) inputImage {
    
    
    //converting to mat for preprocessing by opencv
    Mat initial = [inputImage CVMat];
    
    Mat grey, blur_grey, edges;
    
    //converting to greyscale
    cvtColor(initial, grey, CV_BGR2GRAY);
    //applying gaussian blur to remove noise
    GaussianBlur(grey, blur_grey,   cv::Size(5, 5), 0);
    
    
    
    
    //applying a bitwise not to invert the colors
    cv::bitwise_not(blur_grey, blur_grey);
    
    vector<Vec4i> lines;
    
    //applying canny transform to ignore edges
    Canny(blur_grey, edges, 50, 150, 3);
    
    //applying hough transoform to draw lines on the text
    HoughLinesP(edges, lines, 1,  CV_PI/180,  50,  100, 20);
    
    
    //creating an image to draw lines on to calculate angles
    cv::Size size = blur_grey.size();
    Mat disp_lines(size,CV_8UC1, cv::Scalar(0,0,0));
    
    
    //calculating the angles between the lines
    double angle = 0.;
    unsigned nb_lines = lines.size();
    for (unsigned i = 0; i < nb_lines; ++i) {
        cv::line(disp_lines, cv::Point(lines[i][0], lines[i][1]),
                 cv::Point(lines[i][2], lines[i][3]), cv::Scalar(255, 0 ,0));
        angle += atan2((double)lines[i][3] - lines[i][1],
                       (double)lines[i][2] - lines[i][0]);
    }
    
    angle /= nb_lines; // mean angle, in radians.
    //printf("Angle : %2f", angle * 180/CV_PI);
    
    
    //drawing a box around the image to rotate it
    std::vector<cv::Point> points;
    cv::Mat_<uchar>::iterator it = blur_grey.begin<uchar>();
    cv::Mat_<uchar>::iterator end = blur_grey.end<uchar>();
    for (; it != end; ++it)
        if (*it)
            points.push_back(it.pos());
    
    cv::RotatedRect box = cv::minAreaRect(cv::Mat(points));
    
    cv::Mat rot_mat = cv::getRotationMatrix2D(box.center, angle*180 / CV_PI, 1);
    
    //rotating the image
    cv::Mat rotated;
    cv::warpAffine(grey, rotated, rot_mat, grey.size(), cv::INTER_CUBIC);
    
    cv::Size box_size = box.size;
    if (box.angle < -45.)
        std::swap(box_size.width, box_size.height);
    cv::Mat cropped;
    cv::getRectSubPix(rotated, box_size, box.center, cropped);
    
    
    
    return [UIImage UIImageFromCVMat:cropped];
    
}



@end

