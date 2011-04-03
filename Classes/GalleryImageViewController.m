//
//  GalleryImageViewController.m
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Laurids Düllmann, Jesper Frommherz (Graphics),
//						Patrick Rollbis (Graphics),
//						
//	This program is free software; you can redistribute it and/or
//	modify it under the terms of the GNU General Public License
//	as published by the Free Software Foundation; either version 2
//	of the License, or (at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software
//	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.//
//

#import "GalleryImageViewController.h"
#import "Image.h"
#import "ImageView.h"


#define reflectionFraction 0.35
#define reflectionOpacity 0.5


@implementation GalleryImageViewController

@synthesize element;
@synthesize imageView;
@synthesize containerView;
@synthesize reflectionView;
@synthesize flipIndicatorButton;
@synthesize frontViewIsVisible;
@synthesize timer;
@synthesize imageURL;


- (void)setTimer:(NSTimer *)newTimer {
    if (timer != newTimer) {
        [timer invalidate];
        [timer release];
        timer = [newTimer retain];
    }
}


- (id)init {
	if (self = [super init]) {
		element = nil;
		imageView = nil;
		self.frontViewIsVisible=YES;
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	[self init];
	
	imageURL = [url retain];
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[[self navigationController] setNavigationBarHidden:YES animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self setTimer:nil];

	[[self navigationController] setNavigationBarHidden:NO animated:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// show navigation bar
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	[[self navigationController] setNavigationBarHidden:NO animated:YES];

	// create timer to remove navigation bar
	self.timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                  target:self
                                                selector:@selector(hideNavigationBar:)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)hideNavigationBar:(NSTimer *)theTimer {
	[self setTimer:nil];

	[[self navigationController] setNavigationBarHidden:YES animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
}

- (void)loadView {	
	// create and store a container view

	UIView *localContainerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.containerView = localContainerView;
	[localContainerView release];
	
	containerView.backgroundColor = [UIColor blackColor];
	
	CGSize preferredImageViewSize = [ImageView preferredViewSize];
	
	// do we really need this?
	CGRect viewRect = CGRectMake((containerView.bounds.size.width-preferredImageViewSize.width)/2,
								 (containerView.bounds.size.height-preferredImageViewSize.height)/2-40,
								 preferredImageViewSize.width,preferredImageViewSize.height);
	
	// create the image element view
	ImageView *localImageElementView = [[ImageView alloc] initWithFrame:viewRect];
	self.imageView = localImageElementView;
	[localImageElementView release];
	
	// add the image element view to the containerView
	imageView.element =	[[Image alloc] initWithURL:imageURL];
	[containerView addSubview:imageView];
	
	imageView.viewController = self;
	self.view = containerView;

	// create the reflection view
	CGRect reflectionRect=viewRect;

	// the reflection is a fraction of the size of the view being reflected
	reflectionRect.size.height=reflectionRect.size.height*reflectionFraction;
	
	// and is offset to be at the bottom of the view being reflected
	reflectionRect=CGRectOffset(reflectionRect,0,viewRect.size.height);
	
	UIImageView *localReflectionImageView = [[UIImageView alloc] initWithFrame:reflectionRect];
	self.reflectionView = localReflectionImageView;
	[localReflectionImageView release];
	
	// determine the size of the reflection to create
	NSUInteger reflectionHeight=imageView.bounds.size.height*reflectionFraction;
	
	// create the reflection image, assign it to the UIImageView and add the image view to the containerView
	reflectionView.image=[self.imageView reflectedImageRepresentationWithHeight:reflectionHeight];
	reflectionView.alpha=reflectionOpacity;
	
	[containerView addSubview:reflectionView];
}

- (void)dealloc {
	[imageView release];
	[reflectionView release];
	[element release];
	[self setTimer:nil];
    [imageURL release];
	[super dealloc];
}

@end
