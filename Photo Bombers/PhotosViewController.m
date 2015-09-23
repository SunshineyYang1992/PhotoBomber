//
//  PhotosViewController.m
//  Photo Bombers
//
//  Created by Sunshine Yang on 6/5/15.
//  Copyright (c) 2015 SunshineYang. All rights reserved.
//

//#import "PhotosViewController.h"
//#import "PhotoCell.h"
//#import <SimpleAuth/SimpleAuth.h>
//#import "DetailViewController.h"
//
//@interface PhotosViewController () <UICollectionViewDelegateFlowLayout, UISearchResultsUpdating>
//
//@property (nonatomic) NSString *accessToken;
//@property (nonatomic) NSArray *photos;
//@property (nonatomic,strong) UISearchController *searchController;
//
//
//@end
//
//@implementation PhotosViewController
//
//static NSString * const reuseIdentifier = @"Cell";
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.title = @"Photo Bombers";
//	
//    // Register cell classes
//    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:reuseIdentifier];
//	self.collectionView.backgroundColor = [UIColor whiteColor];
//	
//	//
//	[self configureSearchController];
//	self.navigationItem.titleView = self.searchController.searchBar;
//	self.searchController.hidesNavigationBarDuringPresentation = NO;
//
//	
//	
//}
//- (void) viewDidAppear:(BOOL)animated {
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//	self.accessToken = [userDefaults objectForKey:@"accessToken"];
//	if (self.accessToken == nil) {
//		[SimpleAuth authorize:@"instagram" options:@{@"scope":@[@"likes"]} completion:^(NSDictionary  *responseObject, NSError *error) {
//			self.accessToken = responseObject[@"credentials"][@"token"];
//			[userDefaults setObject:self.accessToken forKey:@"accessToken"];
//			[userDefaults synchronize];
//			[self refresh];
//			
//		}];
//		
//	}else {
//		[self refresh];
//	}
//}
//- (void) configureSearchController {
//	self.searchController = [[UISearchController alloc]init];
//	self.searchController.searchResultsUpdater = self;
//	self.searchController.dimsBackgroundDuringPresentation = YES;
//	self.searchController.searchBar.placeholder = @"Search here....";
//	self.searchController.searchBar.delegate = self;
//	[self.searchController.searchBar sizeToFit];
//	}
//- (void) refresh {
//	NSURLSession *session = [NSURLSession sharedSession];
//	NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/tags/britneyspears/media/recent?access_token=%@",self.accessToken];
//	NSURL *url = [[NSURL alloc]initWithString:urlString];
//	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//	NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//		NSData *data = [[NSData alloc] initWithContentsOfURL:location];
//		NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//		self.photos = [responseDictionary valueForKeyPath:@"data"];
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[self.collectionView reloadData];
//		});
//	}];
//	[task resume];
//}
//
//
//- (instancetype) init {
//	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//	layout.itemSize = CGSizeMake(106.0, 106.0);
//	layout.minimumInteritemSpacing = 1.0;
//	layout.minimumLineSpacing = 1.0;
//	self = [super initWithCollectionViewLayout:layout];
//	return self;
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//#pragma mark <UICollectionViewDataSource>
//
//
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.photos.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//	
//	cell.backgroundColor = [UIColor lightGrayColor];
//	cell.photo = self.photos[indexPath.row];
//	
//    return cell;
//}
//
//
//#pragma mark <UICollectionViewDelegate>
//
//- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//	NSDictionary *photo = self.photos[indexPath.row];
//	DetailViewController *viewController = [[DetailViewController alloc] init];
//	viewController.photo = photo;
//	[self presentViewController:viewController animated:YES completion:nil];
//	
//}
//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//	CGFloat width = CGRectGetWidth(self.collectionView.frame) / 3;
//	return CGSizeMake(width, width);
//}
//
//
//@end
