//
//  NSObject+String.swift
//  TSWeChat
//
//  Created by Hilen on 11/3/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy:".").last! as String
    }
    
    //用于获取 cell 的 reuse identifier
    class var cellIdentifier: String {
        return String(format: "%@_identifier", self.nameOfClass)
    }
}

extension NSObject {
    
    func perform(selector:Selector,objects:[Any]?){
//        let methonIpm = self.classForCoder.instanceMethod(for: selector)
        
    }
    
//    @implementation NSObject (PerformSelector)
//    
//    - (id)performSelector:(SEL)aSelector
//    withObjects:(NSArray  *)objects {
//    
//    //创建签名对象
//    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:aSelector];
//    
//    //判断传入的方法是否存在
//    if (!signature) { //不存在
//    //抛出异常
//    NSString *info = [NSString stringWithFormat:@"-[%@ %@]:unrecognized selector sent to instance",[self class],NSStringFromSelector(aSelector)];
//    @throw [[NSException alloc] initWithName:@"ifelseboyxx remind:" reason:info userInfo:nil];
//    return nil;
//    }
//    
//    //创建 NSInvocation 对象
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//    
//    //保存方法所属的对象
//    invocation.target = self;
//    invocation.selector = aSelector;
//    
//    
//    //设置参数
//    //存在默认的 _cmd、target 两个参数，需剔除
//    NSInteger arguments = signature.numberOfArguments - 2;
//    
//    //谁少就遍历谁,防止数组越界
//    NSUInteger objectsCount = objects.count;
//    NSInteger count = MIN(arguments, objectsCount);
//    for (int i = 0; i < count; i++) {
//    id obj = objects[i];
//    //处理参数是 NULL 类型的情况
//    if ([obj isKindOfClass:[NSNull class]]) {obj = nil;}
//    [invocation setArgument:&obj atIndex:i+2];
//    }
//    
//    //调用
//    [invocation invoke];
//    
//    //获取返回值
//    id res = nil;
//    //判断当前方法是否有返回值
//    if (signature.methodReturnLength != 0) {
//    [invocation getReturnValue:&res];
//    }
//    return res;
//    }
//    
//    @end
    

}
