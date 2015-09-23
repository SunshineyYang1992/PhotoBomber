//
//  PhotosCollectionViewController.m
//  Photo Bombers
//
//  Created by Sunshine Yang on 9/17/15.
//  Copyright (c) 2015 SunshineYang. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "PhotoCell.h"
#import "DetailViewController.h"
#import <SimpleAuth/SimpleAuth.h>
#import "PhotoController.h"

@interface PhotosCollectionViewController () <UISearchControllerDelegate, UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *searchBarContainer;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSArray *photos;
@property (nonatomic,strong) UISearchController *searchController;
@property BOOL shouldShowSearchResults;
@property NSString *searchText;;


@end

@implementation PhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
	{
		[self setNeedsStatusBarAppearanceUpdate];
	}
	self.title = @"Photo Bombers";
	self.shouldShowSearchResults = NO;
	self.searchText = @"celebrity";
	// Register cell classes
	[self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"Cell"];
	self.collectionView.backgroundColor = [UIColor whiteColor];
	
	//
	[self configureSearchController];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	self.accessToken = [userDefaults objectForKey:@"accessToken"];
	if (self.accessToken == nil) {
		[SimpleAuth authorize:@"instagram" options:@{@"scope":@[@"likes"]} completion:^(NSDictionary  *responseObject, NSError *error) {
			self.accessToken = responseObject[@"credentials"][@"token"];
			[userDefaults setObject:self.accessToken forKey:@"accessToken"];
			[userDefaults synchronize];
			[self refresh];
			
		}];
		
	}else {
		[self refresh];
	}
}
- (void) configureSearchController {
	self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	self.searchController.searchResultsUpdater = self;
	self.searchController.dimsBackgroundDuringPresentation = NO;
	self.searchController.searchBar.placeholder = @"Search here....";
	self.searchController.searchBar.delegate = self;
	[self.searchBarContainer addSubview:self.searchController.searchBar];
	[self.searchController.searchBar sizeToFit];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.definesPresentationContext = YES;
}

- (void) refresh {
	NSURLSession *session = [NSURLSession sharedSession];
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@",self.searchText,self.accessToken];
	NSURL *url = [[NSURL alloc]initWithString:urlString];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
		NSData *data = [[NSData alloc] initWithContentsOfURL:location];
		NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
		self.photos = [responseDictionary valueForKeyPath:@"data"];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.collectionView reloadData];
		});
	}];
	[task resume];
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	self.shouldShowSearchResults = YES;
//	[self.collectionView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	self.shouldShowSearchResults = NO;
//	[self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	if (!self.shouldShowSearchResults) {
		self.shouldShowSearchResults = YES;
		[self refresh];
	}
	[self.searchController.searchBar resignFirstResponder];
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	self.searchText = searchController.searchBar.text;
	[self refresh];
}

- (instancetype) init {
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
	layout.itemSize = CGSizeMake(106.0, 106.0);
	layout.minimumInteritemSpacing = 0.0;
	layout.minimumLineSpacing = 0.0;
	//self = [super initWithCollectionViewLayout:layout];
	return self;
}
#pragma mark - Present camera 

- (IBAction)cameraDidTapped:(UIBarButtonItem *)sender {
	UIAlertController * view= [UIAlertController
								 alertControllerWithTitle:nil
								 message:nil
								 preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction* takePhoto = [UIAlertAction
						 actionWithTitle:@"Take Photo"
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
								 UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
								 UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
								 [alertView addAction:cancle];
							 }else {
								 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
								 picker.delegate = self;
								 picker.allowsEditing = YES;
								 picker.sourceType = UIImagePickerControllerSourceTypeCamera;
								 [self presentViewController:picker animated:YES completion:nil];
								 
							 }
						 }];
	UIAlertAction* choosePhoto = [UIAlertAction
								actionWithTitle:@"Choose from Photos"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction * action)
								{
									UIImagePickerController *picker = [[UIImagePickerController alloc]init];
									picker.delegate = self;
									picker.allowsEditing = YES;
									picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
									[self presentViewController:picker animated:YES completion:nil];
								}];

	UIAlertAction* cancel = [UIAlertAction
							 actionWithTitle:@"Cancel"
							 style:UIAlertActionStyleDefault
							 handler:^(UIAlertAction * action)
							 {
								 [view dismissViewControllerAnimated:YES completion:nil];
								 
							 }];
	
	
	[view addAction:takePhoto];
	[view addAction:choosePhoto];
	[view addAction:cancel];
	[self presentViewController:view animated:YES completion:nil];}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
	
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
	
	cell.backgroundColor = [UIColor lightGrayColor];
	cell.photo = self.photos[indexPath.row];
	
	return cell;
}



#pragma mark <UICollectionViewDelegate>

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *photo = self.photos[indexPath.row];
	DetailViewController *viewController = [[DetailViewController alloc] init];
	viewController.photo = photo;
//	
//	[PhotoController imageForPhoto:photo size:@"standard_resolution" completion:^(UIImage *image) {
//		viewController.image = image;
//	}];
	[self presentViewController:viewController animated:YES completion:nil];
	
}
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat width = CGRectGetWidth(self.collectionView.frame) / 3;
	return CGSizeMake(width, width);
}

@end

