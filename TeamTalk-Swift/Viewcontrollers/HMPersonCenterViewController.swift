//
//  HMPersonCenterViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/25.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import LCActionSheet
import SVProgressHUD

class HMPersonCenterViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var tableView:UITableView = UITableView.init(frame: .zero, style: .grouped)
    var headerView:UIView = UIView.init()
    
    var avatarImgv:UIImageView = UIImageView.init()
    var nameLabel:UILabel = UILabel.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我"
        
        self.setupTableview()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshUI()
    }
    
    func setupTableview(){
        
        headerView.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH(), height: 150)
        
        avatarImgv.contentMode = .scaleAspectFit
        avatarImgv.width = 80
        avatarImgv.height = 80
        avatarImgv.centerX = headerView.centerX
        avatarImgv.top = 15
        avatarImgv.addCommonTap(target: self , sel: #selector(self.changeAvatarAction))
        
        nameLabel.font = UIFont.systemFont(ofSize: 16)
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
        
        tableView.mj_addHeader {
            self.refreshUI()
            self.tableView.mj_headerEndRefreshing()
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
    
    func refreshUI(){
        let user:MTTUserEntity = HMLoginManager.shared.currentUser
        HMPrint("curentuser : \(user.objID) \(user.name) \(user.avatarUrl) \(user)")
        
        self.avatarImgv.setImage(str: user.avatar,placeHolder:#imageLiteral(resourceName: "defaultAvatar"))
        self.nameLabel.text = user.nickName
    }
    
    func changeAvatarAction(){
        
        ZQMediaFetch.shared.fetchPhoto(maxCount: 1, configPicker: { (imagePickvc ) in
            imagePickvc.allowPreview = true
            imagePickvc.allowTakePicture = true
            imagePickvc.allowPickingVideo = false
            imagePickvc.allowPickingGif = false
            imagePickvc.allowCrop = true
        }, finish: { (photos , assets, isoriginal, infos) in
            guard  photos.count >  0 else { return }
            let image = photos.first!
            
            let imagePath = ZQFileManager.shared.tempPathFor(image: image)
            guard imagePath.length > 0 else {
                return
            }
            HMPrint("ready to upload avatar Image:\(imagePath)")
            
            let progressView:UIProgressView = UIProgressView.init()
            progressView.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH()/2, height: 30)
            progressView.setProgress(0, animated: true )
            
            SendPhotoMessageAPI.shared.uploadAvatar(imagePath: imagePath, progress: { (progress ) in
                dispatch(after: 0, task: {
                    let floatPro = Float(progress.completedUnitCount)/Float(progress.totalUnitCount)
                    SVProgressHUD.showProgress(floatPro, status: "上传中...")
                })
            }, success: { (imageurl ) in
                dispatch(after: 0, task: {
                    progressView.removeFromSuperview()
                    self.avatarImgv.setImage(str: imageurl)
                    HMLoginManager.shared.currentUser.avatar = imageurl
                    HMLoginManager.shared.currentUser.dbSave(completion: nil )
                })
            }) { (error ) in
                dispatch(after: 0, task: {
                    progressView.removeFromSuperview()
                    SVProgressHUD.showError(withStatus: error)
                })
            }
        }) {
            //cancel
        }
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
        }else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 2 {
            cell.textLabel?.text = "文件浏览"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let sheet = LCActionSheet.init(title: "確認退出嗎？", cancelButtonTitle: "再看看", clicked: { (sheet , index ) in
                if index == 1 {
                    HMLoginManager.shared.logout()
                    
                    let loginvc = HMLoginViewController.init()
                    loginvc.hidesBottomBarWhenPushed = true
                                        
                    self.navigationController?.tabBarController?.navigationController?.pushViewController(loginvc, animated: true )

                    self.navigationController?.tabBarController?.removeFromParentViewController()
                }
            }, otherButtonTitleArray: ["退出"])

            sheet.show()
        }else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 2 {
            let browser = ZQFileBrowserVC.init()
            browser.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(browser, animated: true )
        }else  {
//            LCActionSheet .show(withTitle: "个人中心", buttonTitles: ["1","2","3","4"], redButtonIndex: 6, clickHandler: { (index) in
//            })
        }
    }
    
}
