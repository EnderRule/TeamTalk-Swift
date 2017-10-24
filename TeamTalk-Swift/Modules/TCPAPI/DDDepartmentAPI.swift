//
//  DDDepartmentAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class DDDepartmentAPI: DDSuperAPI,DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int32 {
        return TimeOutTimeInterval
    }
    
    func requestServiceID() -> Int32 {
        return 2
    }
    
    func responseServiceID() -> Int32 {
        return 2
    }
    
    func requestCommendID() -> Int32 {
        return 18
    }
    
    func responseCommendID() -> Int32 {
        return 19
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            
            if let bodyData = DDDataInputStream.init(data: data ?? Data()){
                var array:[[String:Any]] = []
                let departcount = bodyData.readInt()
                
                
                
                //Fixme: should fix departcount or not?
                for _ in 0..<departcount {
                    let departID = bodyData.readUTF() ?? ""       // [bodyData readUTF];
                    let title = bodyData.readUTF() ?? ""          // [bodyData readUTF];
                    let description = bodyData.readUTF() ?? ""    // [bodyData readUTF];
                    let parentID = bodyData.readUTF() ?? ""       // [bodyData readUTF];
                    let leader = bodyData.readUTF() ?? ""         // [bodyData readUTF];
                    let isDelete = bodyData.readInt()               // [bodyData readInt];
                    
                    let departDic:[String:Any] = ["departCount":departcount,
                                                  "departID":departID,
                                                  "title":title,
                                                  "description":description,
                                                  "parentID":parentID,
                                                  "leader":leader,
                                                  "isDelete":isDelete ]
                    array.append(departDic)
                }
                return array
            }else{
                return []
            }
            
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let IM_PDU_HEADER_LEN:Int32 = 16
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(IM_PDU_HEADER_LEN)
            dataOut.writeTcpProtocolHeader(2, cId: 18,  seqNo: seqno)
            return dataOut.toByteArray()
        }
        return package
    }
}
