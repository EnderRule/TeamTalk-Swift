//
//  ZQFileBrowserVC.swift
//  CornerRadius
//
//  Created by HZQ on 2017/3/19.
//  Copyright © 2017年 zxy. All rights reserved.
//

import UIKit

let FileBrowserBackID:String = "<< 返回上一級"

class ZQFileBrowserVC: UIViewController,UITableViewDataSource,UITableViewDelegate {

    public var browserPath:String = NSHomeDirectory()
    
    private var files:[String] = []
    
    private var tableview:UITableView = UITableView.init()
    
    private var simpleTextView:UITextView = UITextView.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if browserPath == NSHomeDirectory(){
            self.title = "Home"
        }else{
            self.title = (browserPath as NSString).lastPathComponent
        }
        
        tableview.frame = .init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        tableview.dataSource = self
        tableview.delegate  = self
        tableview.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cellForBrowerFile")
        tableview.backgroundColor = UIColor.darkGray
        tableview.tableFooterView = UIView.init()
        self.view.addSubview(tableview)
        
        simpleTextView.frame = tableview.frame
        simpleTextView.isEditable = false
        simpleTextView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        simpleTextView.textColor = UIColor.white
        simpleTextView.isHidden = true
        self.view.addSubview(simpleTextView)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true )
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        self.reloadFiles()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchBackButton() {
        if simpleTextView.isHidden{
            super.touchBackButton()
        }else{
            simpleTextView.text = ""
            simpleTextView.isHidden = true
        }
    }
    
    
    func reloadFiles(){
        if self.browserPath == NSHomeDirectory(){
            self.title = "Home"
        }else{
            self.title = (self.browserPath as NSString).lastPathComponent
        }
        
        self.files = FileManager.default.getFilesAt(path: self.browserPath)
        self.tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellForBrowerFile", for: indexPath)
        
        cell.selectionStyle = .none
        if indexPath.row < self.files.count{
            
            let subPath = files[indexPath.row]
            cell.textLabel?.text = subPath

            if subPath != FileBrowserBackID{
                let fullPath = (self.browserPath as NSString).appendingPathComponent(subPath)
                
                let folderSize:UInt64 = FileManager.default.folderSizeAt(path: fullPath)
                
                var sizeStr:String = "0 B"
                if folderSize > 1024*1024*1024 {
                    sizeStr = "\(folderSize/1024/1024/1024) GB"
                }else if folderSize > 1024 * 1024{
                    sizeStr = "\(folderSize/1024/1024) MB"
                }else if folderSize > 1024 {
                    sizeStr = "\(folderSize/1024) KB"
                }else {
                    sizeStr = "\(folderSize) B"
                }
                cell.textLabel?.text = subPath.appending("   size:\(sizeStr)")
            }
            cell.textLabel?.lineBreakMode = .byTruncatingMiddle
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.files.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < files.count{
            let subPath = files[indexPath.row]
            let fullPath = (browserPath as NSString).appendingPathComponent(subPath)

            let fileExtention = (subPath as NSString ).pathExtension
            
            if subPath == FileBrowserBackID{
                
                if browserPath == NSHomeDirectory(){
                    let _ = self.navigationController?.popViewController(animated: true)
                }else{                
                    self.browserPath = (self.browserPath as NSString).deletingLastPathComponent
                    self.reloadFiles()
                }
                
            }else if subPath.hasImageExtention() {
                var imageFullPaths:[String] = []
                var currentIndex:Int = 0
                for index in 0..<files.count
                {
                    let tempSubpath = files[index]
                    if tempSubpath.hasImageExtention(){
                        let tempFullPath = (self.browserPath as NSString).appendingPathComponent(tempSubpath)
                        imageFullPaths.append(tempFullPath)
                        
                        if tempSubpath == subPath{
                            currentIndex = imageFullPaths.count - 1
                        }
                    }
                } 
//                let imageBrowser:LKACImageBrowser = LKACImageBrowser.init(imagesPaths: imageFullPaths)
//                imageBrowser.setPageIndex(UInt(currentIndex))
//                imageBrowser.show()
                
            }else if fileExtention == "plist"{
                    do{
                        let data:NSData = try NSData.init(contentsOfFile: fullPath)
                        let string = data.base64EncodedString(options: .endLineWithLineFeed)

                        
                        if string.length > 0 {
                            let tempData = string.data(using: .utf8)
                            if tempData != nil{
                                let string = String.init(data: tempData! , encoding: .utf8)
                                
                                self.simpleTextView.text = string
                                self.simpleTextView.isHidden = false ;
                            }
                        }
                    }catch{
                    
                    }
                
            } else if fileExtention == "log"
                || fileExtention == "txt"
                || fileExtention == "html"
                || fileExtention == "json"
            {
                do {
                    let data:NSData = try NSData.init(contentsOfFile: fullPath)
                    let string = String.init(data: data as Data , encoding: .utf8)
                    if string != nil  && string!.length > 0{
                        self.simpleTextView.text = string
                        self.simpleTextView.isHidden = false ;
                    }
                }catch{
                
                }
            }else {
                self.browserPath = fullPath
                self.reloadFiles()
            }
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.row < self.files.count{
            let subPath = files[indexPath.row]
            let fullPath = (self.browserPath as NSString).appendingPathComponent(subPath)
           
            let errorString = FileManager.default.deleteFilesAt(path: fullPath)
            if errorString.length > 0{
                debugPrint("delete \(fullPath) error:\(errorString)")
            }else {
                files = FileManager.default.getFilesAt(path: self.browserPath)
                self.tableview.reloadData()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



extension FileManager{
    
    func getFilesAt(path:String)->[String]{
        
        var isDir:ObjCBool = false
        let exist:Bool = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        
        if exist{
            if isDir.boolValue {
                do{
                    var fileArr:[String] = try FileManager.default.contentsOfDirectory(atPath: path)
                    fileArr.insert(FileBrowserBackID, at: 0)
                    
                    return fileArr
                }catch{
                    print(error.localizedDescription)
                    return [FileBrowserBackID]
                }
            }else{
                return [FileBrowserBackID,(path as NSString).lastPathComponent]
            }
        }else{
            return [FileBrowserBackID]
        }
    }
    
    func deleteFilesAt(path:String)->String{
        
        var isDir:ObjCBool = false
        let exist:Bool = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        
        var errorStr = ""
        if exist{
            if FileManager.default.isDeletableFile(atPath: path){
                do{
                    try removeItem(atPath: path)
                }catch {
                    errorStr = "file delete fail"
                }
            }else{
                errorStr = "file can't delete"
            }
//            if isDir.boolValue {
//                do{
//                    let fileArr:[String] = try FileManager.default.contentsOfDirectory(atPath: path)
//                    for subpath in fileArr{
//                        let _ = deleteFilesAt(path: (path as NSString).appendingPathComponent(subpath))
//                    }
//                }catch{
//                    return error.localizedDescription
//                }
//                
//                
//                
//            }else{
//                if  FileManager.default.isDeletableFile(atPath: path){
//                    do{
//                        try removeItem(atPath: path)
//                    }catch {
//                        errorStr = "file delete fail"
//                    }
//                }else{
//                    errorStr = "file can't delete"
//                }
//            }
        }else{
            errorStr = "file not exist"
        }
        
        return errorStr
    }
    
    
    func folderSizeAt(path:String)->UInt64{
        var isDir:ObjCBool = false
        let exist:Bool = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        var folderSize:UInt64 = 0
        if exist{
            if isDir.boolValue {
                do{
                    let fileArr:[String] = try FileManager.default.contentsOfDirectory(atPath: path)
                    for subpath in fileArr{
                        folderSize = folderSize + self.folderSizeAt(path: (path as NSString).appendingPathComponent(subpath))
                    }
                }catch{
                    folderSize = 0
                }
            }else{
                do{
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
                    folderSize = fileAttributes[FileAttributeKey.size] as! UInt64
                }catch {
                    folderSize = 0
                }
            }
        }else{
            folderSize = 0
        }
        return folderSize
    }
}

extension String{
    
    func hasImageExtention()->Bool{
        let fileExtention = (self as NSString ).pathExtension
        if fileExtention == "jpg"
            || fileExtention == "png"
            || fileExtention == "bmp"
            || fileExtention == "gif"
        {
            return true
        }
        return false
        
    }
    
}

