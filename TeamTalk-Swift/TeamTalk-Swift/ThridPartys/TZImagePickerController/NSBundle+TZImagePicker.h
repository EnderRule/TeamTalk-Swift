//
//  NSBundle+TZImagePicker.h
//  TZImagePickerController
//
//  Created by 譚真 on 16/08/18.
//  Copyright c 2016年 譚真. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (TZImagePicker)

+ (NSString *)tz_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)tz_localizedStringForKey:(NSString *)key;

@end

