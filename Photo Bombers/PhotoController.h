//
//  PhotoController.h
//  Photo Bombers
//
//  Created by Sunshine Yang on 17/9/15.
//  Copyright (c) 2015 SunshineYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PhotoController : NSObject

+(void) imageForPhoto:(NSDictionary *)photo size:(NSString *)size completion:(void(^)(UIImage *image))completion;

@end
