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
//    private var audioPlayerCalculate:AVAudioPlayer?

    private var audioRecorder:AVAudioRecorder?
    private var recordVoicePath:String = ""
    private var recordTimeInterval:TimeInterval = 0

    func durationFor(filePath:String,completion:@escaping ((TimeInterval)->Void) ){
        
        
        guard let url = URL.init(string: filePath) else {
            completion(0.0)
            return
        }
        let asset = AVURLAsset.init(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
        
        asset.loadValuesAsynchronously(forKeys: [AVURLAssetPreferPreciseDurationAndTimingKey]) {
            let valuestate =  asset.statusOfValue(forKey: AVURLAssetPreferPreciseDurationAndTimingKey, error: nil)
            let duration =  CMTimeGetSeconds(asset.duration)
            debugPrint("asset \(asset)  \(asset.duration)  \(valuestate)",duration)
            completion(duration)
        }
        
    }
    
    //MARK: 錄音播放
    public func audioPlay(filePath:String,completion:@escaping HMAudioPlayFinish){
        
        guard FileManager.default.fileExists(atPath: filePath) else {
            completion("錄音文件不存在")
            return
        }
    
        do {
            let data:Data = try NSData.init(contentsOfFile: filePath) as Data
            
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
            let errorstr = "無法讀取錄音文件 \(error.localizedDescription)"
            completion(errorstr)
        }
//        guard let data = NSData.init(contentsOfFile: filePath) else {
//            completion("無法讀取錄音文件")
//            return
//        }
        
    }
    
    public func audioPlayIsPlaying()->Bool{
        return self.audioPlayer?.isPlaying ?? false
    }
    public func audioPlayPause(){
        self.audioPlayer?.pause()
    }
    public func audioPlayStop(){
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.audioPlayedFinish?(nil)
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
