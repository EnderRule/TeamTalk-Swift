//
//  DBScrollBannerView+LKExtention.swift
//  Linking
//
//  Created by HZQ on 2017/4/13.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit

class LKDBScrollBannerView: DBScrollBannerView{
    func configData(imagesArr:[String]){
        self.dataSource = imagesArr
        
        //设置scrollerView
        self.configureScrollerView()
        //设置imageView
        self.configureImageView()
        //设置页控制器
        self.configurePageController()

        if imagesArr.count > 1 {
            //设置自动滚动计时器
            self.configureAutoScrollTimer()
        }else{
            self.scrollerView?.isScrollEnabled = false
        }
        self.backgroundColor = colorMainBg
        
        self.configureImageView()
        self.configureAutoScrollTimer()
    }
    
//    //每当滚动后重新设置各个imageView的图片
//    override func resetImageViewSource() {
//        
//        //当前显示的是第一张图片
//        if self.currentIndex == 0 {
//            self.leftImageView?.setImage(str: (self.dataSource?.last!)!)
//            self.middleImageView?.setImage(str: (self.dataSource?.first!)!)
//            let rightImageIndex = (self.dataSource?.count)!>1 ? 1 : 0 //保护
//            self.rightImageView?.setImage(str: self.dataSource![rightImageIndex])
//        }
//            //当前显示的是最好一张图片
//        else if self.currentIndex == (self.dataSource?.count)! - 1 {
//            self.leftImageView?.setImage(str: self.dataSource![self.currentIndex - 1])
//            self.middleImageView?.setImage(str: (self.dataSource?.last!)!)
//            self.rightImageView?.setImage(str: (self.dataSource?.first!)!)
//        }
//            //其他情况
//        else{
//            self.leftImageView?.setImage(str: self.dataSource![self.currentIndex - 1])
//            self.middleImageView?.setImage(str: self.dataSource![self.currentIndex ])
//            self.rightImageView?.setImage(str: self.dataSource![self.currentIndex + 1])
//        }
//    }
    
    func setPageControlHidden(hidden:Bool){
        self.pageControl?.isHidden = hidden
    }
}

