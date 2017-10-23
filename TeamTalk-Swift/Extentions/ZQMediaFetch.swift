//
//  ZQMediaFetch.swift
//  LKMall
//
//  Created by HuangZhongQing on 2017/9/26.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import TZImagePickerController

typealias fetchVideoFinishBlock = ((UIImage,Any)->Void)
typealias fetchPhotoFinishBlock = (([UIImage],[Any],Bool?,[[AnyHashable:Any]]?)->Void)
typealias fetchCancelBlock = (()->Void)

class ZQMediaFetch: NSObject,TZImagePickerControllerDelegate {
    static let shared = ZQMediaFetch()
    
    private var videoFinishBlock:fetchVideoFinishBlock?
    private var photoFinishBlock:fetchPhotoFinishBlock?
    private var cancelBlock:fetchCancelBlock?
    
    func fetchPhoto(maxCount:Int,configPicker:((TZImagePickerController) ->Void)?,finish:@escaping fetchPhotoFinishBlock,cancel cancelBlock: fetchCancelBlock?){
        
        let picker:TZImagePickerController = TZImagePickerController.init(maxImagesCount: maxCount, delegate: self)
        configPicker?(picker)
        
        picker.maxImagesCount = maxCount
        picker.allowPickingImage = true
        picker.allowTakePicture = true
        picker.allowPickingGif = true
        picker.allowPickingVideo = false

        self.photoFinishBlock = finish
        self.cancelBlock = cancelBlock
        
        UIApplication.shared.keyWindow?.rootViewController!.present(picker, animated: true , completion: nil )
    }
    
    func fetchGif(configPicker:((TZImagePickerController) ->Void)?,finish:@escaping fetchPhotoFinishBlock,cancel cancelBlock: fetchCancelBlock?){
        let picker:TZImagePickerController = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
        configPicker?(picker)
        
        picker.maxImagesCount = 1
        picker.allowPickingGif = true
        picker.allowPickingVideo = false
        picker.allowPickingImage = false
        picker.allowTakePicture = false
        
        self.photoFinishBlock = finish
        self.cancelBlock = cancelBlock

        UIApplication.shared.keyWindow?.rootViewController!.present(picker, animated: true , completion: nil )
    }
    func fetchVideo(configPicker:((TZImagePickerController) ->Void)?,finish:@escaping fetchVideoFinishBlock,cancel cancelBlock: fetchCancelBlock?){
        let picker:TZImagePickerController = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
        configPicker?(picker)
        
        picker.allowPickingVideo = true
        picker.allowPickingGif = false
        picker.allowPickingImage = false
        picker.maxImagesCount = 1
        
        self.videoFinishBlock = finish
        self.cancelBlock = cancelBlock

        UIApplication.shared.keyWindow?.rootViewController!.present(picker, animated: true , completion: nil )
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: Any!) {
        self.videoFinishBlock?(coverImage,asset)
        self.videoFinishBlock = nil
        self.photoFinishBlock = nil
        self.cancelBlock = nil
    }
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.photoFinishBlock?(photos,assets,isSelectOriginalPhoto,nil )
        
        self.videoFinishBlock = nil
        self.photoFinishBlock = nil
        self.cancelBlock = nil
    }
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!)
    {
        self.photoFinishBlock?(photos,assets,isSelectOriginalPhoto,infos )

        self.videoFinishBlock = nil
        self.photoFinishBlock = nil
        self.cancelBlock = nil
    }
    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {
        self.cancelBlock?()
        
        self.videoFinishBlock = nil
        self.photoFinishBlock = nil
        self.cancelBlock = nil
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingGifImage animatedImage: UIImage!, sourceAssets asset: Any!) {
        self.photoFinishBlock?([animatedImage],[asset],nil,nil )

        self.videoFinishBlock = nil
        self.photoFinishBlock = nil
        self.cancelBlock = nil
    }
}
