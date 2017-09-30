//
//  UIImage+Extention.swift
//  heyfriendS
//
//  Created by HZQ on 2016/11/9.
//  Copyright © 2016年 online. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

extension UIImage {
    
    class func imageWith(color:UIColor,size:CGSize)->UIImage{
        let rect:CGRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(size)
        let ctx:CGContext = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        let theImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return theImage
    }
    
    open  func imageWith(color:UIColor, size:CGSize) -> UIImage {
        let rect:CGRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(size)
        let ctx:CGContext = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        
        let theImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return theImage
    }
    
    open func circleImage()->UIImage{
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        ctx?.addEllipse(in: rect)
        ctx?.clip()
        self .draw(in: rect)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    open func imageToFit(size:CGSize)->UIImage{
        if size.width <= 0 || size.height <= 0{
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        self .draw(in: rect)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    open func blurryImage(blurLevel:CGFloat)->UIImage?{
        let inputImage = CIImage.init(cgImage: self.cgImage!)
        let filter = CIFilter.init(name: "CIGaussianBlur", withInputParameters: [kCIInputImageKey:inputImage,kCIInputRadiusKey:blurLevel]) //CIFilter.init(name: "CIGaussianBlur")
        return UIImage.init(ciImage: (filter?.outputImage)!)
    }
    
    func cornerImage(radius: CGFloat,sizetoFit:CGSize) -> UIImage? {
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        UIGraphicsBeginImageContextWithOptions(sizetoFit, false, 0.0)
//        UIGraphicsBeginImageContext(sizetoFit)
        UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        UIGraphicsGetCurrentContext()?.clip()
        
        self.draw(in: rect)
        UIGraphicsGetCurrentContext()?.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return output
    }
    
    //mode:default is .topLeft
    func addRedDot(mode:UIViewContentMode)->UIImage{
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self .draw(in: rect)

        let padding:CGFloat = 1.0
        let redDotSize:CGFloat = self.size.width * 0.25
        var originPoint:CGPoint = CGPoint.init(x: padding, y: padding)
        if mode == .center{
            originPoint.x = self.size.width/2 - redDotSize
            originPoint.y = self.size.height/2 - redDotSize
        }else if mode == .topRight{
            originPoint.x = self.size.width - padding - redDotSize
            originPoint.y = padding
        }else if mode == .bottomLeft{
            originPoint.x =  padding
            originPoint.y = self.size.height - padding - redDotSize
        }else if mode == .bottomRight{
            originPoint.x = self.size.width - padding - redDotSize
            originPoint.y = self.size.height - padding - redDotSize
        }
        
        let reddotPath = CGPath.init(roundedRect: .init(x: originPoint.x, y: originPoint.y, width: redDotSize, height: redDotSize), cornerWidth: redDotSize * 0.5, cornerHeight: redDotSize*0.5, transform: nil)
        ctx?.addPath(reddotPath)
        ctx?.setFillColor(UIColor.red.cgColor)
        ctx?.setStrokeColor(UIColor.red.cgColor)
        ctx?.drawPath(using: .fillStroke)
        ctx?.strokePath()
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}


//- (UIImage *)imageAsCircle:(BOOL)clipToCircle
//withDiamter:(CGFloat)diameter
//borderColor:(UIColor *)borderColor
//borderWidth:(CGFloat)borderWidth
//shadowOffSet:(CGSize)shadowOffset
//{
//    // increase given size for border and shadow
//    CGFloat increase = diameter * 0.15f;
//    CGFloat newSize = diameter + increase;
//    
//    CGRect newRect = CGRectMake(0.0f,
//                                0.0f,
//        newSize,
//        newSize);
//    
//    // fit image inside border and shadow
//    CGRect imgRect = CGRectMake(increase,
//                                increase,
//                                newRect.size.width - (increase * 2.0f),
//                                newRect.size.height - (increase * 2.0f));
//    
//    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, [UIScreen mainScreen].scale);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    
//    // draw shadow
//    if(!CGSizeEqualToSize(shadowOffset, CGSizeZero))
//    CGContextSetShadowWithColor(context,
//    CGSizeMake(shadowOffset.width, shadowOffset.height),
//    3.0f,
//    [UIColor colorWithWhite:0.0f alpha:0.45f].CGColor);
//    
//    // draw border
//    // as circle or square
//    CGPathRef borderPath = (clipToCircle) ? CGPathCreateWithEllipseInRect(imgRect, NULL) : CGPathCreateWithRect(imgRect, NULL);
//    
//    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
//    CGContextSetLineWidth(context, borderWidth);
//    CGContextAddPath(context, borderPath);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGPathRelease(borderPath);
//    CGContextRestoreGState(context);
//    
//    // clip to circle
//    if(clipToCircle) {
//        UIBezierPath *imgPath = [UIBezierPath bezierPathWithOvalInRect:imgRect];
//        [imgPath addClip];
//    }
//    
//    [self drawInRect:imgRect];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}


