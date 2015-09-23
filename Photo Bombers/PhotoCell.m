//
//  PhotoCell.m
//  Photo Bombers
//
//  Created by Sunshine Yang on 17/9/15.
//  Copyright (c) 2015 SunshineYang. All rights reserved.
//

#import "PhotoCell.h"
#import "PhotoController.h"

@implementation PhotoCell

-(void) setPhoto:(NSDictionary *)photo {
	_photo = photo;
	
	[PhotoController imageForPhoto:_photo size:@"thumbnail" completion:^(UIImage *image) {
		self.imageView.image = image;
	}];
	
}


- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.imageView = [[UIImageView alloc]init];
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(like)];
		tap.numberOfTapsRequired = 2;
		[self addGestureRecognizer:tap];
		[self.contentView addSubview:self.imageView];
	}
	return self;
}

- (void) like {
	NSLog(@"Link: %@",self.photo[@"link"]);
	NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@",self.photo[@"id"],accessToken];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	request.HTTPMethod = @"POST";
	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self showLikeCompletion];
		});
	}];
	[task resume];
	
	
}
- (void) showLikeCompletion {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"liked" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
	[alertView show];
	double delayInSeconds = 1.0;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	});
}
- (void) layoutSubviews {
	[super layoutSubviews];
	self.imageView.frame = self.contentView.bounds;
}
@end
