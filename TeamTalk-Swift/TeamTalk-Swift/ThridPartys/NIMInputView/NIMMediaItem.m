//
//  NIMMediaItem.m
//  NIMKit
//
//  Created by amao on 8/11/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "NIMMediaItem.h"

@implementation NIMMediaItem

+ (NIMMediaItem *)item:(NSString *)selector
           normalImage:(UIImage  *)normalImage
         selectedImage:(UIImage  *)selectedImage
                 title:(NSString *)title
{
    NIMMediaItem *item  = [[NIMMediaItem alloc] init];
    item.selctor        = NSSelectorFromString(selector);
    item.normalImage    = normalImage;
    item.selectedImage  = selectedImage;
    item.title          = title;
    return item;
}

+ (NSArray <NIMMediaItem *> *)defaultItems{
    
    
    return @[[NIMMediaItem item:@"onTapMediaItemPicture:"
                    normalImage:[UIImage imageNamed:@"bk_media_picture_normal"]
                  selectedImage:[UIImage imageNamed:@"bk_media_picture_nomal_pressed"]
                          title:@"相冊"],
             
             [NIMMediaItem item:@"onTapMediaItemShoot:"
                    normalImage:[UIImage imageNamed:@"bk_media_shoot_normal"]
                  selectedImage:[UIImage imageNamed:@"bk_media_shoot_pressed"]
                          title:@"拍攝"],
             
             //             [NIMMediaItem item:@"onTapMediaItemLocation:"
             //                    normalImage:[UIImage imageNamed:@"bk_media_position_normal"]
             //                  selectedImage:[UIImage imageNamed:@"bk_media_position_pressed"]
             //                          title:@"位置"],
            
             ];
    
}

@end
