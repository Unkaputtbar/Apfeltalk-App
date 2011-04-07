//
//  DetailLiveticker.m
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

#import "DetailLiveticker.h"
#import "LivetickerController.h"
#import "UIScrollViewPrivate.h"


@implementation DetailLiveticker

- (void)viewDidLoad
{
    NSArray            *imgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Up.png"], [UIImage imageNamed:@"Down.png"], nil];
	UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:imgArray];

	[segControl addTarget:[[[self navigationController] viewControllers] objectAtIndex:0] action:@selector(changeStory:)
         forControlEvents:UIControlEventValueChanged];
	[segControl setFrame:CGRectMake(0, 0, 90, 30)];
	[segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segControl setMomentary:YES];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:segControl];

    [[self navigationItem] setRightBarButtonItem:rightItem];
    [[[[self navigationController] viewControllers] objectAtIndex:0] changeStory:segControl];

    [segControl release];
    [rightItem release];

    [webview setDelegate:self];
    [webview setBackgroundColor:[UIColor clearColor]];
    [self updateInterface];
// :below:20091111 Apple wants this removed
//	[(UIScrollView *)[webview.subviews objectAtIndex:0] setAllowsRubberBanding:NO];
}



- (UIImage *) thumbimage
{
	return [UIImage imageNamed:@"TickerThumbnail.png"];
}



- (NSString *)htmlString
{
    NSRange          aRange;
    NSMutableString *contentString = [NSMutableString stringWithString:[self scaledHtmlStringFromHtmlString:[[self story] summary]]];

    // Remove the last paragraph tags
    aRange = [contentString rangeOfString:@"</p>" options:NSBackwardsSearch];
    if (([contentString length] - NSMaxRange(aRange)) <= 1)
    {
        [contentString deleteCharactersInRange:aRange];
        aRange = [contentString rangeOfString:@"<p>" options:NSBackwardsSearch];
        if (aRange.location != NSNotFound)
            [contentString deleteCharactersInRange:aRange];
    }

    [thumbnailButton setBackgroundImage:[self thumbimage] forState:UIControlStateNormal];

    return [[self baseHtmlString] stringByReplacingOccurrencesOfString:@"%@" withString:contentString];
}



- (UISegmentedControl *)storyControl
{
    return (UISegmentedControl *)[[[self navigationItem] rightBarButtonItem] customView];
}



- (void)updateInterface
{
    [titleLabel setText:[[self story] title]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
	datum.text = [NSString stringWithFormat:@"von %@ - %@", [[self story] author], [dateFormatter stringFromDate:[[self story] date]]];
    [dateFormatter release];

    [webview loadHTMLString:[self htmlString] baseURL:nil];
}

@end
