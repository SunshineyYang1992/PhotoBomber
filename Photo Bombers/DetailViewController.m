//
//  DetailViewController.m
//  Photo Bombers
//
//  Created by Sunshine Yang on 17/9/15.
//  Copyright (c) 2015 SunshineYang. All rights reserved.
//

#import "DetailViewController.h"
#import "PhotoController.h"

const CGFloat kRetinaToEyeScaleFactor = 0.5f;
const CGFloat kFaceBoundsToEyeScaleFactor = 4.0f;

@interface DetailViewController () <UIScrollViewDelegate>

//@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *shareImageView;
@property (nonatomic, strong) UIImageView *closeImageView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor whiteColor];
	
	// setup imageview
	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -320.0f, 320.0f, 320.0f)];
	self.shareImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width /2 - 40 , 40, 80, 80)];
	self.closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height - 120, 80, 80)];
	[self.view addSubview:self.scrollView];
	[self.scrollView addSubview:self.imageView];
	[self.view addSubview:self.shareImageView];
	[self.view addSubview:self.closeImageView];
	self.shareImageView.image = [UIImage imageNamed:@"share"];
	self.closeImageView.image = [UIImage imageNamed:@"close"];
	self.closeImageView.userInteractionEnabled = YES;
	self.shareImageView.userInteractionEnabled = YES;
	
	[PhotoController imageForPhoto:self.photo size:@"standard_resolution" completion:^(UIImage *image) {
		self.image = image;
		self.imageView.image = self.image;

	}];

	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
	[self.closeImageView addGestureRecognizer:tap];
	self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
	
	//Zooming
	self.scrollView.minimumZoomScale = 0.5;
	self.scrollView.maximumZoomScale = 3.0;
	self.scrollView.contentSize = CGSizeMake(self.imageView.bounds.size.width, self.imageView.bounds.size.height);
	self.scrollView.delegate = self;
	

	
	
}
- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.imageView snapToPoint:self.view.center];
	[self.animator addBehavior:snap];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		UIImage *overlayImage = [self faceOverlayImageFromImage:self.image];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self fadeInNewImage:overlayImage];
		});
	});
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

- (void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	CGSize size = self.view.bounds.size;
	CGSize imageSize = CGSizeMake(size.width, size.width);
	self.imageView.frame = CGRectMake(0.0, (size.height-imageSize.height)/2.0, imageSize.width,
									   imageSize.height);
}
- (void) close {
	[self.animator removeAllBehaviors];
	UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.imageView snapToPoint:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(self.view.bounds)+ 180.0f)];
	[self.animator addBehavior:snap];
	[self dismissViewControllerAnimated:YES completion:nil];
}
-(void) setPhoto:(NSDictionary *)photo {
	_photo = photo;
	
	[PhotoController imageForPhoto:_photo size:@"standard_resolution" completion:^(UIImage *image) {
		self.imageView.image = image;
	}];
	
}



#pragma mark --Face detection

- (UIImage *)faceOverlayImageFromImage:(UIImage *)image
{
	CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
											  context:nil
											  options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
	// Get features from the image
	CIImage* newImage = [CIImage imageWithCGImage:image.CGImage];
	
	NSArray *features = [detector featuresInImage:newImage];
	
	UIGraphicsBeginImageContext(image.size);
	CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
	
	//Draws this in the upper left coordinate system
	[image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0f];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	for (CIFaceFeature *faceFeature in features) {
		CGRect faceRect = [faceFeature bounds];
		CGContextSaveGState(context);
		
		// CI and CG work in different coordinate systems, we should translate to
		// the correct one so we don't get mixed up when calculating the face position.
		CGContextTranslateCTM(context, 0.0, imageRect.size.height);
		CGContextScaleCTM(context, 1.0f, -1.0f);
		
		if ([faceFeature hasLeftEyePosition]) {
			CGPoint leftEyePosition = [faceFeature leftEyePosition];
			CGFloat eyeWidth = faceRect.size.width / kFaceBoundsToEyeScaleFactor;
			CGFloat eyeHeight = faceRect.size.height / kFaceBoundsToEyeScaleFactor;
			CGRect eyeRect = CGRectMake(leftEyePosition.x - eyeWidth/2.0f,
										leftEyePosition.y - eyeHeight/2.0f,
										eyeWidth,
										eyeHeight);
			[self drawEyeBallForFrame:eyeRect];
		}
		
		if ([faceFeature hasRightEyePosition]) {
			CGPoint leftEyePosition = [faceFeature rightEyePosition];
			CGFloat eyeWidth = faceRect.size.width / kFaceBoundsToEyeScaleFactor;
			CGFloat eyeHeight = faceRect.size.height / kFaceBoundsToEyeScaleFactor;
			CGRect eyeRect = CGRectMake(leftEyePosition.x - eyeWidth / 2.0f,
										leftEyePosition.y - eyeHeight / 2.0f,
										eyeWidth,
										eyeHeight);
			[self drawEyeBallForFrame:eyeRect];
		}
		
		CGContextRestoreGState(context);
	}
	
	UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return overlayImage;
}

- (CGFloat)faceRotationInRadiansWithLeftEyePoint:(CGPoint)startPoint rightEyePoint:(CGPoint)endPoint;
{
	CGFloat deltaX = endPoint.x - startPoint.x;
	CGFloat deltaY = endPoint.y - startPoint.y;
	CGFloat angleInRadians = atan2f(deltaY, deltaX);
	
	return angleInRadians;
}

- (void)drawEyeBallForFrame:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextAddEllipseInRect(context, rect);
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillPath(context);
	
	CGFloat x, y, eyeSizeWidth, eyeSizeHeight;
	eyeSizeWidth = rect.size.width * kRetinaToEyeScaleFactor;
	eyeSizeHeight = rect.size.height * kRetinaToEyeScaleFactor;
	
	x = arc4random_uniform((rect.size.width - eyeSizeWidth));
	y = arc4random_uniform((rect.size.height - eyeSizeHeight));
	x += rect.origin.x;
	y += rect.origin.y;
	
	CGFloat eyeSize = MIN(eyeSizeWidth, eyeSizeHeight);
	CGRect eyeBallRect = CGRectMake(x, y, eyeSize, eyeSize);
	CGContextAddEllipseInRect(context, eyeBallRect);
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextFillPath(context);
}

- (void)fadeInNewImage:(UIImage *)newImage
{
	UIImageView *tmpImageView = [[UIImageView alloc] initWithImage:newImage];
	tmpImageView.contentMode = self.imageView.contentMode;
	tmpImageView.frame = self.imageView.bounds;
	tmpImageView.alpha = 0.0f;
	[self.imageView addSubview:tmpImageView];
	
	[UIView animateWithDuration:0.75f animations:^{
		tmpImageView.alpha = 1.0f;
	} completion:^(BOOL finished) {
		self.imageView.image = newImage;
		[tmpImageView removeFromSuperview];
	}];
}
#pragma mark - Zooming
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return  self.imageView;
}
@end

