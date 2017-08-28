//
//  HMPersonCenterViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/25.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMPersonCenterViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,TZImagePickerControllerDelegate {

    var tableView:UITableView = UITableView.init(frame: .zero, style: .grouped)
    var headerView:UIView = UIView.init()
    
    var avatarImgv:UIImageView = UIImageView.init()
    var nameLabel:UILabel = UILabel.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我"
        
        self.setupTableview()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.headerBeginRefreshing()
    }
    
    
    func setupTableview(){
        
        headerView.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH(), height: 150)
        
        avatarImgv.contentMode = .scaleAspectFit
        avatarImgv.width = 80
        avatarImgv.height = 80
        avatarImgv.centerX = headerView.centerX
        avatarImgv.top = 15
        avatarImgv.addCommonTap(target: self , sel: #selector(self.changeAvatarAction))
        
        nameLabel.font = fontTitle
        nameLabel.backgroundColor = UIColor.clear
        nameLabel.width = headerView.width
        nameLabel.height = 50
        nameLabel.top = avatarImgv.bottom + 15
        nameLabel.left = 0
        nameLabel.textAlignment = .center
        
        headerView.addSubview(avatarImgv)
        headerView.addSubview(nameLabel)
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.cellIdentifier)
        self.view.addSubview(tableView)
        
        tableView.addHeader {
            
            DDUserModule.shareInstance().getUserForUserID(RuntimeStatus.instance().user.userId, block: { (user ) in
                
                self.tableView.headerEndRefreshing()
                
                if user != nil {
                    self.avatarImgv.setImage(str: user!.avatar)
                    self.nameLabel.text = user!.name
                }
            })
        }
        
        self.view.addSubview(tableView)
        
        tableView.mas_makeConstraints { (maker ) in
            maker?.top.equalTo()(self.view.mas_top)
            maker?.left.mas_equalTo()(self.view.mas_left)
            maker?.right.mas_equalTo()(self.view.mas_right)
            maker?.bottom.mas_equalTo()(self.view.mas_bottom)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func changeAvatarAction(){
        let imagePickvc:TZImagePickerController = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
        
        imagePickvc.allowPreview = true
        imagePickvc.allowTakePicture = true
        imagePickvc.allowPickingVideo = false
        imagePickvc.allowPickingGif = false
        imagePickvc.allowCrop = true
        
        self.present(imagePickvc, animated: true , completion: nil )
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerView
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.section)-\(indexPath.row)"
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.textLabel?.text = "退出登入"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            RuntimeStatus.instance().user = nil
            
            UserDefaults.standard.setValue("", forKey: "password")
            UserDefaults.standard.setValue("", forKey: "username")
            UserDefaults.standard.setValue(false, forKey: "autologin")
 
            
            let loginvc = MTTLoginViewController.init()
            loginvc.hidesBottomBarWhenPushed = true
            
            (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.pushViewController(loginvc, animated: true )
            
            if let tabbarcontroller = self.navigationController?.tabBarController {
                tabbarcontroller.removeFromParentViewController()
            }
        }
    }
    
    
    //MARK: pick image delegate 
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
        guard  photos.count >  0 else { return }
        let image = photos.first!
        
        let imagePath = ZQFileManager.shared.tempPathFor(image: image)
        guard imagePath.length > 0 else {
            return
        }
        print("ready to upload avatar Image:\(imagePath)")
        
        //先上传图片、再发送含有图片URL 的消息。
        DDSendPhotoMessageAPI.sharedPhotoCache().uploadImage(imagePath, success: {[weak self ] (imageURL ) in
            
            debugPrint("  upload avatar image success :\(imageURL) ")
            
            if imageURL != nil {
                
            }
        }) {[weak self ] (error ) in
            debugPrint("chatting pick && upload image error :\(error.debugDescription) ")
            
            self?.view.makeToast(error.debugDescription, duration: 3.0, position: .center, title: "上传失败", image: nil , style:ToastStyle.init(), completion: nil )
            
        }
        
    }
}