//
//  PhotoController.m
//  Photo Bombers
//
//  Created by Sunshine Yang on 17/9/15.
//  Copyright (c) 2015 SunshineYang. All rights reserved.
//

#import "PhotoController.h"

@implementation PhotoController

+(void) imageForPhoto:(NSDictionary *)photo size:(NSString *)size completion:(void(^)(UIImage *image))completion {
	
	if (photo == nil || size == nil || completion == nil) {
		return;
	}
	NSURL *url = [[NSURL alloc] initWithString:photo[@"images"][size][@"url"]];

	NSURLSession *session = [NSURLSession sharedSession];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
		NSData *data = [[NSData alloc] initWithContentsOfURL:location];
		UIImage *image = [[UIImage alloc] initWithData:data];
		dispatch_async(dispatch_get_main_queue(), ^{
			completion(image);
		});
	}];
	[task resume];
}
@end
