//
//  ZQFileManager.swift
//  heyfriendS
//
//  Created by HZQ on 2016/12/21.
//  Copyright © 2016年 online. All rights reserved.
//

import UIKit

class ZQFileManager: NSObject {

    static let shared = ZQFileManager()
    
    public func deleteTempImages(){
       
        let enumrator:FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: NSTemporaryDirectory())!
        for path in enumrator.allObjects {
            if path as? String != nil && ((path as! String).contains("new_")){
                let completePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(path as! String)
                let _ = self.delete(filePath: completePath)
            }
        }
    }
    
    func delete(filePath:String)->Bool{
        if  FileManager.default.fileExists(atPath: filePath){
            do{
                try FileManager.default.removeItem(atPath: filePath)
                return true
            }catch{
                debugPrint("1 try delete file:",filePath,"\n delete Error:",error.localizedDescription)
                return false
            }
        }else{
            let range:NSRange = (filePath as NSString).range(of: "/var/mobile/Containers/Data/Application/")
            if range.length > 0{
                let newPart:String  = (filePath as NSString).substring(from: range.location + range.length + 36)
                let newfilePath = NSHomeDirectory().appending(newPart)
                
                if FileManager.default.fileExists(atPath: newfilePath){
                    do{
                        try FileManager.default.removeItem(atPath: newfilePath)
                        return true
                    }catch{
                        debugPrint("2 try delete file:",filePath,"\n delete Error:",error.localizedDescription)
                        return false
                    }
                }else{
                    return true
                }
            }else{
                return true
            }
        }
    }
    
    ////没有指定文件名时返回 文件夹path,默認userID=0
    func userDocPath(fileName:String,userID:Int?)->String{
        let uID :Int = userID ?? 0
        
        let folder = DocPath(name: "User_\(uID)")
        
        let fullPath = (folder as NSString).appendingPathComponent(fileName)
        //文件不存在、创建时先检查目录是否存在
        if !FileManager.default.fileExists(atPath: fullPath){
            
            if !FileManager.default.fileExists(atPath: folder){
                do {
                    try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: false , attributes: nil)
                }catch{
                    debugPrint("fail to create dir :\(folder)  error:\(error.localizedDescription)")
                }
            }
            
            if fileName.length <= 0{
                return folder
            }
            
            if !FileManager.default.fileExists(atPath: fullPath){
                FileManager.default.createFile(atPath: fullPath, contents: nil, attributes: nil)
            }
        }
        
        return fullPath
    }
    
    func userTempPath(fileName:String,userID:Int?)->String{
        let uID :Int = userID ?? 0
        
        return (NSTemporaryDirectory() as NSString).appendingPathComponent("\(uID)").appending(fileName)
    }

    
    func tempPathFor(image:UIImage)->String{
        let fileId:String = "new_".appending(TIMESTAMP())
        let filePath:String = TempPath(name: fileId.appending(".jpg"))
        
        if write(data: UIImageJPEGRepresentation(image, 1)!, toPath: filePath){
            return filePath
        }else{
            return ""
        }
    }
    
    func tempPathFor(images:[UIImage])->[String]{
        
        var paths:[String] = []
        for index  in 0..<images.count{
            let image = images[index]
            let fileId:String = "new_".appending(TIMESTAMP()).appending("_\(index)")
            let filePath:String = TempPath(name: fileId.appending(".jpg"))
            if write(data: UIImageJPEGRepresentation(image, 1)!, toPath: filePath){
                paths.append(filePath)
            }else{
                if write(data: UIImageJPEGRepresentation(image, 1)!, toPath: filePath){
                    paths.append(filePath)
                }
            }
        }
        return paths
    }
    
}

// 发布动态的图片管理
extension ZQFileManager{
    
    func inPostingImageFolderWith(uID:Int)->String {
        let userFolder = userDocPath(fileName: "", userID: uID)  // 已确保此文件夹一定存在
        let imagesFolder = (userFolder as NSString).appendingPathComponent("InPostingImages")
        
        if !FileManager.default.fileExists(atPath: imagesFolder){
            do{
                try FileManager.default.createDirectory(atPath: imagesFolder, withIntermediateDirectories: false, attributes: nil)
            }catch{
                debugPrint("fail to create dir :\(imagesFolder)  error:\(error.localizedDescription)")
            }
        }
        return imagesFolder
    }
    
    func deleteAllInPostingImages(uID:Int){
        let imagesFolder = self.inPostingImageFolderWith(uID: uID)
        
        let enumrator = FileManager.default.enumerator(atPath: imagesFolder)
        for path in enumrator?.allObjects ?? [] {
            let completePath = (imagesFolder as NSString).appendingPathComponent(path as! String)
            let _ = self.delete(filePath: completePath)
        }
    }
    
    func feedEventInPostingImagePath(images:[UIImage],uID:Int)->[String]{
        let imagesFolder = self.inPostingImageFolderWith(uID: uID)

        var paths:[String] = []
        for index  in 0..<images.count{
            let image = images[index]
            
            let data = UIImageJPEGRepresentation(image, 1.0)
            
            
            if data != nil {
//                debugPrint("image data length \(data!.endIndex) \((data! as NSData).length)")

                var fileName:String = "new_\(TIMESTAMP())_\(index)"
                let isGifImage:Bool = image.images != nil // image.images 不为nil 就属于gif
                if isGifImage {
                    fileName.append(".gif")
                }else{
                    fileName.append(".jpg")
                }
                
                let filePath:String = (imagesFolder as NSString).appendingPathComponent(fileName)
                
//                debugPrint("filePath:\(filePath)")
                if write(data: data!, toPath: filePath){
                    paths.append(filePath)
                }else{
//                    debugPrint("write image fail")
                    if write(data: data!, toPath: filePath){
                        paths.append(filePath)
                    }else{
//                        debugPrint("write image fail 2")
                    }
                }
            }
        
//            NSString *imageContentType = [NSData sd_contentTypeForImageData:data];
//            if ([imageContentType isEqualToString:@"image/gif"]) {
//                image = [UIImage sd_animatedGIFWithData:data];
//            }
        }
        return paths
    }
    
    func feedEventInPostingGIFImagePath(gifData:Data,uID:Int)->String?{
        let imagesFolder = self.inPostingImageFolderWith(uID: uID)
        
        let fileName:String = "new_\(TIMESTAMP()).gif"
        let filePath:String = (imagesFolder as NSString).appendingPathComponent(fileName)
        
        debugPrint("filePath:\(filePath)")
        if write(data: gifData, toPath: filePath){
            return filePath
        }else{
             if write(data: gifData, toPath: filePath){
                return filePath
             }else{
                debugPrint("write gif image fail 2")
            }
        }
        
        return nil
    }
    
}

extension FileManager {
    
    
    
}


//1、Documents 目录：您应该将所有de应用程序数据文件写入到这个目录下。这个目录用于存储用户数据或其它应该定期备份的信息。
//2、AppName.app 目录：这是应用程序的程序包目录，包含应用程序的本身。由于应用程序必须经过签名，所以您在运行时不能对这个目录中的内容进行修改，否则可能会使应用程序无法启动。
//3、Library 目录：这个目录下有两个子目录：Caches 和 Preferences
//Preferences 目录：包含应用程序的偏好设置文件。您不应该直接创建偏好设置文件，而是应该使用NSUserDefaults类来取得和设置应用程序的偏好.
//Caches 目录：用于存放应用程序专用的支持文件，保存应用程序再次启动过程中需要的信息。
//4、tmp 目录：这个目录用于存放临时文件，保存应用程序再次启动过程中不需要的信息。
//
//获取这些目录路径的方法：
//1，获取家目录路径的函数：
//NSString *homeDir = NSHomeDirectory();
//2，获取Documents目录路径的方法：
//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//NSString *docDir = [paths objectAtIndex:0];
//3，获取Caches目录路径的方法：
//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//NSString *cachesDir = [paths objectAtIndex:0];
//4，获取tmp目录路径的方法：
//NSString *tmpDir = NSTemporaryDirectory();

//代码中的mainBundle类方法用于返回一个代表应用程序包的对象。

let PATH_DOCUMENT       = NSSearchPathForDirectoriesInDomains( .documentDirectory,  .userDomainMask, true)
let PATH_Caches         = NSSearchPathForDirectoriesInDomains( .cachesDirectory,  .userDomainMask, true)

func  DocPath(name:String)->String{
    return (PATH_DOCUMENT[0] as NSString).appendingPathComponent(name)
}
func TempPath(name:String)->String{
    return (NSTemporaryDirectory() as NSString).appendingPathComponent(name)
}
func CachesPath(name:String)->String{
    return (PATH_Caches[0] as NSString).appendingPathComponent(name)
}


func write(data:Data,toPath:String)->Bool{
    if  FileManager.default.fileExists(atPath: toPath){
        do{
            try FileManager.default.removeItem(atPath: toPath)
        }catch{
            debugPrint("path:",toPath,"\ndeleteFileError:",error.localizedDescription)
        }
    }
    return FileManager.default.createFile(atPath: toPath, contents: data, attributes: nil)
}
func read(filePath:String)->Data{
    if  !FileManager.default.fileExists(atPath: filePath){
        return Data()
    }else{
        do{
            let data = try Data.init(contentsOf: URL.init(string: filePath)!)
            return data
        }catch{
            debugPrint("path:",filePath,"read data error:",error.localizedDescription)
            return Data()
        }
    }
}







