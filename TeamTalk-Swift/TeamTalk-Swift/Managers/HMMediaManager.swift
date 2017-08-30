//
//  HMMediaManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/30.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import AudioToolbox

typealias HMAudioPlayFinish = ((String?)->Void)

class HMMediaManager: NSObject,AVAudioPlayerDelegate {
    static let shared:HMMediaManager = HMMediaManager()
    
    private var audioPlayer:AVAudioPlayer?
    private var audioPlayedFinish:HMAudioPlayFinish?

    private var audioRecorder:AVAudioRecorder?
    private var recordVoicePath:String = ""
    private var recordTimeInterval:TimeInterval = 0

    func durationFor(filePath:String )->TimeInterval{
        guard let url = URL.init(string: filePath) else {
            return 0
        }
        let asset = AVURLAsset.init(url:url)
        let duration = asset.duration
        return  CMTimeGetSeconds(duration)
    }
    
    //MARK: 錄音播放
    public func audioPlay(filePath:String,completion:@escaping HMAudioPlayFinish){
        
        guard let url = URL.init(string: filePath) else {
            completion("錄音文件不存在")
            return
        }
        
        do {
            let data:Data = try Data.init(contentsOf: url)
            
//            debugPrint(data)
            
            do {
                self.audioPlayedFinish = completion
                
                let player:AVAudioPlayer = try  AVAudioPlayer.init(data: data )
                player.delegate = self
                player.prepareToPlay()
                
                self.audioPlayer = player
                player.play()
            }catch{
                completion(error.localizedDescription)
                return
            }
        }catch{
            completion("無法讀取錄音文件")
        }
//        guard let data = NSData.init(contentsOfFile: filePath) else {
//            completion("無法讀取錄音文件")
//            return
//        }
        
    }
    public func audioPlayPause(){
        self.audioPlayer?.pause()
    }
    public func audioPlayStop(){
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        
    }
    //MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer = nil
        self.audioPlayedFinish?(nil)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.audioPlayer = nil
        self.audioPlayedFinish?(error?.localizedDescription ?? "音頻解碼失敗")
    }
    
}
