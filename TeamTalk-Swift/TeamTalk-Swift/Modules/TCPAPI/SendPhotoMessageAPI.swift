//
//  SendPhotoMessageAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/9/6.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class SendPhotoMessageAPI: NSObject {
    static let shared:SendPhotoMessageAPI =  SendPhotoMessageAPI()
    
    private var manager: AFHTTPSessionManager = AFHTTPSessionManager.init()
    private var queue: OperationQueue = OperationQueue.init()
    
    private var max_try_upload_times:Int = 5
    
    override init() {
        super.init()
        
        self.manager.responseSerializer.accessibilityElements = ["text/html"]
        self.queue.maxConcurrentOperationCount = 1
    }
    
    public func uploadPhoto(imagePath:String ,
                            to session:MTTSessionEntity,
                            progress:@escaping ((Progress)->Void),
                            success:@escaping ((String)->Void),
                            failure:@escaping ((String)->Void))
    {
        let operation:BlockOperation =  BlockOperation.init {
            do {
                let imageData:NSData = try NSData.init(contentsOfFile: imagePath)
                guard imageData.length > 128 else {
                    self.max_try_upload_times = 5
                    failure("invalid image data")
                    return
                }
                let msgType:Int = session.isGroupSession ? 17 : 1
                let fromUserID:Int = HMLoginManager.shared.currentUser.intUserID
                let toSessionID:UInt32 = MTTBaseEntity.pbIDFrom(localID: session.sessionID)
                let time:TimeInterval = HMLoginManager.shared.serverTime
                
                let authDic:[String : Any] = ["msg_type":msgType,"from_user_id":fromUserID,"to_session_id":toSessionID,"time":time]
                let authString:String  = (authDic as NSDictionary).jsonString()
                let auth:String = authString.encrypt()
                
                let urlString:String = HMLoginManager.shared.msfsUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.init())!
                let paras:[AnyHashable:Any] = ["type":"im_image","auth":auth]
                let image:UIImage = UIImage.init(data: imageData as Data) ?? UIImage()
                let imageName:String = "image_\(image.size.width)x\(image.size.height).png"

                debugPrint(HMLoginManager.shared.msfsUrl)
                debugPrint("upload image to url:\(urlString)")
                
                self.manager.post(urlString, parameters: paras, constructingBodyWith: { (formData) in
                    formData.appendPart(withFileData: imageData as Data, name: "image", fileName: imageName, mimeType: "image/jpeg")
                }, progress: { (pro ) in
                    progress(pro)
                }, success: { (task , responseObject ) in
                    
                    var imageURL:String = ""
                    
                    let resultJson:JSON = JSON.init(responseObject as? [AnyHashable:Any] ?? [:])
                    
                    if resultJson["error_code"].intValue == 0{
                        imageURL = resultJson["url"].stringValue
                    }else{
                        failure(resultJson["error_msg"].stringValue)
                        return
                    }
                    
                    if imageURL.length > 0 {
                        self.max_try_upload_times = 5
                        success(imageURL)
                    }else{
                        self.max_try_upload_times -= 1
                        if self.max_try_upload_times > 0{
                            self.uploadPhoto(imagePath: imagePath, to: session, progress: { (pro ) in
                                progress(pro)
                            }, success: { (url ) in
                                success(url)
                            }, failure: { (error ) in
                                failure(error)
                            })
                        }else{
                            self.max_try_upload_times = 5

                            failure("上傳失敗：重試超限")
                        }
                    }
                }, failure: { (task , error ) in
                    self.max_try_upload_times = 5
                    failure (error.localizedDescription)
                    
//                    let nserror:NSError = (error as NSError)
//                    let response:URLResponse = task?.response //nserror.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] as! HTTPURLResponse
//                    let stateCode:Int = response.statusCode
//                    
//                    self.max_try_upload_times = 5
//
//                    if !(stateCode >= 300 && stateCode <= 307){
//                        failure("上傳失敗：网络连接已断开。code=\(stateCode)")
//                    }else{
//                        failure("上傳失敗：code=\(stateCode)")
//                    }
                })
            }catch{
                self.max_try_upload_times = 5

                failure("上傳失敗：image read data error")
                return
            }
        }
        
        self.queue.addOperation(operation)
    }
}
