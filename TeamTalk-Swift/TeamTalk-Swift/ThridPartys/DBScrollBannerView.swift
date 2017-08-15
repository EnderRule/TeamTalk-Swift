//
//  DHScrollView.swift
//  demo6-TabbarVcÁöÑ‰ΩøÁî®
//
//  Created by zero on 16/12/26.
//  Copyright ¬© 2016Âπ¥ yunhaitechnology. All rights reserved.
//

import UIKit
//ÂõæÁâáËΩÆÊí≠ÁªÑ‰ª∂‰ª£ÁêÜÂçèËÆÆ
protocol DBScrollBannerViewDelegate{
    //Ëé∑ÂèñÊï∞ÊçÆÊ∫ê
    func handleTapAction(index:Int)->Void
}

//ÂõæÁâáËΩÆÊí≠ÁªÑ‰ª∂ÊéßÂà∂Âô®
class DBScrollBannerView: UIView,UIScrollViewDelegate{
    //‰ª£ÁêÜÂØπË±°
    var delegate : DBScrollBannerViewDelegate?
    var handleTapActionBlock:((_ index:Int )->Void)?
    var pageChangeBlock:((Int) -> Void)?

    
    //Â±èÂπïÂÆΩÂ∫¶
    let kScreenWidth = UIScreen.main.bounds.size.width
    
    //ÂΩìÂâçÂ±ïÁ§∫ÁöÑÂõæÁâáÁ¥¢Âºï
    var currentIndex : Int = 0
    
    //Êï∞ÊçÆÊ∫ê
    var dataSource : [String]?
    
    //Áî®‰∫éËΩÆÊí≠ÁöÑÂ∑¶‰∏≠Âè≥‰∏â‰∏™imageÔºà‰∏çÁÆ°Âá†Âº†ÂõæÁâáÈÉΩÊòØËøô‰∏â‰∏™imageView‰∫§Êõø‰ΩøÁî®Ôºâ
    var leftImageView , middleImageView , rightImageView : UIImageView?
    
    //ÊîæÁΩÆimageViewÁöÑÊªöÂä®ËßÜÂõæ
    var scrollerView : UIScrollView?
    
    //scrollViewÁöÑÂÆΩÂíåÈ´ò
    var scrollerViewWidth : CGFloat?
    var scrollerViewHeight : CGFloat?
    
    //È°µÊéßÂà∂Âô®ÔºàÂ∞èÂúÜÁÇπÔºâ
    var pageControl : UIPageControl?
    
    //Ëá™Âä®ÊªöÂä®ËÆ°Êó∂Âô®
    var autoScrollTimer:Timer?
    //Ëá™ÂãïÊªæÂãïÈñìÈöîÊôÇÈñì
    var autoScrollTimeInterval:TimeInterval = 3.0
    
    func relodataData(ImagesArr:[String]){
        //Ëé∑ÂèñÊï∞ÊçÆ
        self.dataSource =  ImagesArr
        //ËÆæÁΩÆimageView
        self.configureImageView()
        //ËÆæÁΩÆÈ°µÊéßÂà∂Âô®
        self.configurePageController()
        if ImagesArr.count > 1 {
            //ËÆæÁΩÆËá™Âä®ÊªöÂä®ËÆ°Êó∂Âô®
            self.configureAutoScrollTimer()
        }else{
            self.scrollerView?.isScrollEnabled = false
        }
        
    }
    
    init(frame: CGRect, ImagesArr:[String]) {
        super.init(frame: frame)
        
        //Ëé∑ÂèñÂπ∂ËÆæÁΩÆscrollerViewÂ∞∫ÂØ∏
        self.scrollerViewWidth = frame.width
        self.scrollerViewHeight = frame.height
        
        //Ëé∑ÂèñÊï∞ÊçÆ
        self.dataSource =  ImagesArr
        //ËÆæÁΩÆscrollerView
        self.configureScrollerView()
        //ËÆæÁΩÆimageView
        self.configureImageView()
        //ËÆæÁΩÆÈ°µÊéßÂà∂Âô®
        self.configurePageController()
        if ImagesArr.count > 1 {
            //ËÆæÁΩÆËá™Âä®ÊªöÂä®ËÆ°Êó∂Âô®
            self.configureAutoScrollTimer()
        }else{
            self.scrollerView?.isScrollEnabled = false
        }
        self.backgroundColor = UIColor.gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //ËÆæÁΩÆscrollerView
    func configureScrollerView(){
        self.scrollerView = UIScrollView(frame: CGRect(x: 0,y: 0,
                                                       width: self.scrollerViewWidth!, height: self.scrollerViewHeight!))
        if self.scrollerView != nil{
            self.scrollerView?.delegate = self
            self.scrollerView?.contentSize = CGSize(width: self.scrollerViewWidth! * 3,
                                                    height: self.scrollerViewHeight!)
            //ÊªöÂä®ËßÜÂõæÂÜÖÂÆπÂå∫ÂüüÂêëÂ∑¶ÂÅèÁßª‰∏Ä‰∏™viewÁöÑÂÆΩÂ∫¶
            self.scrollerView?.contentOffset = CGPoint(x: self.scrollerViewWidth!, y: 0)
            self.scrollerView?.isPagingEnabled = true
            self.scrollerView?.bounces = false
            self.addSubview(self.scrollerView!)
        }
    }
    //ËÆæÁΩÆimageView
    func configureImageView(){
        self.leftImageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                       width: self.scrollerViewWidth!, height: self.scrollerViewHeight!))
        self.middleImageView = UIImageView(frame: CGRect(x: self.scrollerViewWidth!, y: 0,
                                                         width: self.scrollerViewWidth!, height: self.scrollerViewHeight! ));
        self.rightImageView = UIImageView(frame: CGRect(x: 2*self.scrollerViewWidth!, y: 0,
                                                        width: self.scrollerViewWidth!, height: self.scrollerViewHeight!));
        self.scrollerView?.showsHorizontalScrollIndicator = false
        
        //ËÆæÁΩÆÂàùÂßãÊó∂Â∑¶‰∏≠Âè≥‰∏â‰∏™imageViewÁöÑÂõæÁâáÔºàÂàÜÂà´Êó∂Êï∞ÊçÆÊ∫ê‰∏≠ÊúÄÂêé‰∏ÄÂº†ÔºåÁ¨¨‰∏ÄÂº†ÔºåÁ¨¨‰∫åÂº†ÂõæÁâáÔºâ
        if(self.dataSource?.count != 0){
            self.touchViewAction()
            resetImageViewSource()
        }else{
            // Â¶ÇÊûúÊ≤°ÊúâÂõæÁâáÔºåÁ´ô‰ΩçÂõæ
            self.middleImageView?.image = UIImage(named: "img_05")
        }
        
        self.scrollerView?.addSubview(self.leftImageView!)
        self.scrollerView?.addSubview(self.middleImageView!)
        self.scrollerView?.addSubview(self.rightImageView!)
    }
    
    //ËÆæÁΩÆÈ°µÊéßÂà∂Âô®
    func configurePageController() {
        self.pageControl = UIPageControl(frame: CGRect(x: kScreenWidth/2-60,
                                                       y: self.scrollerViewHeight! - 20, width: 120, height: 20))
        self.pageControl?.numberOfPages = (self.dataSource?.count)!
        self.pageControl?.isUserInteractionEnabled = true
        self.addSubview(self.pageControl!)

        if (self.dataSource?.count)! > 1{
            self.pageControl?.alpha = 1.0
        }else{
            self.pageControl?.alpha = 0.01
        }
    }
    
    //ËÆæÁΩÆËá™Âä®ÊªöÂä®ËÆ°Êó∂Âô®
    func configureAutoScrollTimer() {
        autoScrollTimer?.invalidate()
        //ËÆæÁΩÆ‰∏Ä‰∏™ÂÆöÊó∂Âô®ÔºåÊØè X ÁßíÈíüÊªöÂä®‰∏ÄÊ¨°
        if self.autoScrollTimeInterval > 0 && (self.dataSource?.count)! > 1{
            autoScrollTimer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval,
                                                   target: self,
                                                   selector: #selector(letItScroll),
                                                   userInfo: nil,
                                                   repeats: true)
        }
    }
    
    //ËÆ°Êó∂Âô®Êó∂Èó¥‰∏ÄÂà∞ÔºåÊªöÂä®‰∏ÄÂº†ÂõæÁâá
    @objc func letItScroll(){
        let offset = CGPoint(x: 2*scrollerViewWidth!, y: 0)
        self.scrollerView?.setContentOffset(offset, animated: true)
    }
    
    //ÊØèÂΩìÊªöÂä®ÂêéÈáçÊñ∞ËÆæÁΩÆÂêÑ‰∏™imageViewÁöÑÂõæÁâá
    func resetImageViewSource() {
        //ÂΩìÂâçÊòæÁ§∫ÁöÑÊòØÁ¨¨‰∏ÄÂº†ÂõæÁâá
        if self.currentIndex == 0 {
            self.leftImageView?.image = UIImage(named: self.dataSource!.last!)
            self.middleImageView?.image = UIImage(named: self.dataSource!.first!)
            let rightImageIndex = (self.dataSource?.count)!>1 ? 1 : 0 //‰øùÊä§
            self.rightImageView?.image = UIImage(named: self.dataSource![rightImageIndex])
        }
            //ÂΩìÂâçÊòæÁ§∫ÁöÑÊòØÊúÄÂ•Ω‰∏ÄÂº†ÂõæÁâá
        else if self.currentIndex == (self.dataSource?.count)! - 1 {
            self.leftImageView?.image = UIImage(named: self.dataSource![self.currentIndex-1])
            self.middleImageView?.image = UIImage(named: self.dataSource!.last!)
            self.rightImageView?.image = UIImage(named: self.dataSource!.first!)
        }
            //ÂÖ∂‰ªñÊÉÖÂÜµ
        else{
            self.leftImageView?.image = UIImage(named: self.dataSource![self.currentIndex-1])
            self.middleImageView?.image = UIImage(named: self.dataSource![self.currentIndex])
            self.rightImageView?.image = UIImage(named: self.dataSource![self.currentIndex+1])
        }
    }
    
    func touchViewAction(){
        //Ê∑ªÂä†ÁªÑ‰ª∂ÁöÑÁÇπÂáª‰∫ã‰ª∂
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleTapAction(_:)))
        self.addGestureRecognizer(tap)
    }
    //ÁÇπÂáª‰∫ã‰ª∂ÂìçÂ @objc∫î
    @objc func handleTapAction(_ tap:UITapGestureRecognizer)->Void{
        self.delegate?.handleTapAction(index: self.currentIndex)
        self.handleTapActionBlock?(self.currentIndex)
    }
    
    //scrollViewÊªöÂä®ÂÆåÊØïÂêéËß¶Âèë
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollerView{
            //Ëé∑ÂèñÂΩìÂâçÂÅèÁßªÈáè
            let offset = scrollView.contentOffset.x
            
            if(self.dataSource?.count != 0){
                
                //Â¶ÇÊûúÂêëÂ∑¶ÊªëÂä®ÔºàÊòæÁ§∫‰∏ã‰∏ÄÂº†Ôºâ
                if(offset >= self.scrollerViewWidth!*2){
                    //ËøòÂéüÂÅèÁßªÈáè
                    scrollView.contentOffset = CGPoint(x: self.scrollerViewWidth!, y: 0)
                    //ËßÜÂõæÁ¥¢Âºï+1
                    self.currentIndex = self.currentIndex + 1
                    
                    if self.currentIndex == self.dataSource?.count {
                        self.currentIndex = 0
                    }
                }
                
                //Â¶ÇÊûúÂêëÂè≥ÊªëÂä®ÔºàÊòæÁ§∫‰∏ä‰∏ÄÂº†Ôºâ
                if(offset <= 0){
                    //ËøòÂéüÂÅèÁßªÈáè
                    scrollView.contentOffset = CGPoint(x: self.scrollerViewWidth!, y: 0)
                    //ËßÜÂõæÁ¥¢Âºï-1
                    self.currentIndex = self.currentIndex - 1
                    
                    if self.currentIndex == -1 {
                        self.currentIndex = (self.dataSource?.count)! - 1
                    }
                }
                
                //ÈáçÊñ∞ËÆæÁΩÆÂêÑ‰∏™imageViewÁöÑÂõæÁâá
                resetImageViewSource()
                //ËÆæÁΩÆÈ°µÊéßÂà∂Âô®ÂΩìÂâçÈ°µÁ†Å
                self.pageControl?.currentPage = self.currentIndex
                
                if self.pageChangeBlock != nil{
                    self.pageChangeBlock!(self.currentIndex)
                }
            }
        }
    }
    
    //ÊâãÂä®ÊãñÊãΩÊªöÂä®ÂºÄÂßã
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //‰ΩøËá™Âä®ÊªöÂä®ËÆ°Êó∂Âô®Â§±ÊïàÔºàÈò≤Ê≠¢Áî®Êà∑ÊâãÂä®ÁßªÂä®ÂõæÁâáÁöÑÊó∂ÂÄôËøôËæπ‰πüÂú®Ëá™Âä®ÊªöÂä®Ôºâ
        autoScrollTimer?.invalidate()
    }
    
    //ÊâãÂä®ÊãñÊãΩÊªöÂä®ÁªìÊùü
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        //ÈáçÊñ∞ÂêØÂä®Ëá™Âä®ÊªöÂä®ËÆ°Êó∂Âô®
        configureAutoScrollTimer()
        
    }
    
}
