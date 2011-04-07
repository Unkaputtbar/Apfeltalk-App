//
//  NewsController.m
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

#import "NewsController.h"
#import "DetailNews.h"
#import "Apfeltalk_MagazinAppDelegate.h"
#import "ATMXMLUtilities.h"

@interface NewsController (private)
- (NSString *) savedStoryFilepath;
- (BOOL) saveStories;
@end

@implementation NewsController

@synthesize displayedStorySection;
@synthesize displayedStoryIndex;

const int SAVED_MESSAGES_SECTION_INDEX = 1;

- (void)viewWillAppear:(BOOL)animated {
	[savedStories release];
	savedStories = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self savedStoryFilepath]] mutableCopy];
	[super viewWillAppear:animated];
		
	UIBarButtonItem *safariButton = [[UIBarButtonItem alloc] initWithTitle:@"Optionen"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(openSafari:)];
	self.navigationItem.leftBarButtonItem = safariButton;
	[safariButton release];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

    // update the number of unread messages in Application Badge
    [self updateApplicationIconBadgeNumber];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section != SAVED_MESSAGES_SECTION_INDEX)
		return [super tableView:tableView numberOfRowsInSection:section];
	return [savedStories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section != SAVED_MESSAGES_SECTION_INDEX)
		return @"";
	
	return NSLocalizedString (@"Gespeicherte News", @"");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([indexPath section] != 1) 
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	static NSString *CellIdentifier = @"SavedStory";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
   }
    
	
	int storyIndex = [indexPath row];
	// This cries for some more refactoring
	
	cell.textLabel.text = [[savedStories objectAtIndex: storyIndex] title];
	
    return cell;
}

//set editingStyle on current row. If set do UITableViewCellEditingStyleDelete, delete button is shown at swipe gesture
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;		//default
	int section = [indexPath section];
	
	if(section == SAVED_MESSAGES_SECTION_INDEX) {
		Story *story = [savedStories objectAtIndex: indexPath.row];
		if ([self isSavedStory:story]) {						//TODO this needs refactoring. We should just check if message in correct Section, instead of checking every story.
			editingStyle = UITableViewCellEditingStyleDelete;
		}
	}
	
	return editingStyle;
}

//localize the delete button
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return NSLocalizedString(@"NewsController.TableView.DeleteButtonLabel", @"");
}

//handle tab on delete button
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	//remove element from savedStoris array
	[savedStories removeObjectAtIndex:indexPath.row];
	[self saveStories];
	
	//remove element from TableView
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	[tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setDisplayedStorySection:[indexPath section]];
    [self setDisplayedStoryIndex:[indexPath row]];

	if ([indexPath section] != SAVED_MESSAGES_SECTION_INDEX) {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
		 return;
	}
		
	// Navigation logic
	
	// Again, this really cries for some more thinking and some more refactoring
	Story *story = [savedStories objectAtIndex: indexPath.row];
	Class detailClass = [self detailControllerClass];
	
	DetailNews *detailController = [[detailClass alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]
																  story:story];
	
	[detailController setShowSave:NO];
	
	[self.navigationController pushViewController:detailController animated:YES];
	[detailController release];
}

- (Class) detailControllerClass {
	return [DetailNews self];
}

- (void) addSavedStory:(Story *)newStory {
	if (savedStories == nil)
		savedStories = [NSMutableArray new];
	[savedStories insertObject:newStory atIndex:0];
	[self saveStories];
	[newsTable reloadData];
}

- (BOOL)isSavedStory:(Story *)story {
    BOOL result = NO;
    NSString *storyLink = [story link];

    for (Story *savedStory in savedStories)
    {
        if ([storyLink isEqualToString:[savedStory link]])
            result = YES;
    }

    return result;
}

- (NSString *) savedStoryFilepath {
	return [[self supportFolderPath] stringByAppendingPathComponent:@"saved.ATStories"];
}

- (BOOL) saveStories {
	return [NSKeyedArchiver archiveRootObject:savedStories toFile:[self savedStoryFilepath]];
}

- (void)changeStory:(id)sender
{
    NSUInteger  newIndex = [self displayedStoryIndex];
    NSArray    *storiesArray;
    Story      *newStory;

    if ([self displayedStorySection] != SAVED_MESSAGES_SECTION_INDEX)
        storiesArray = [self stories];
    else
        storiesArray = savedStories;

    switch ([(UISegmentedControl *)sender selectedSegmentIndex])
    {
        case 0:     // Up
            newIndex--;
            break;

        case 1:     // Down
            newIndex++;
            break;
    }

    if ([(UISegmentedControl *)sender selectedSegmentIndex] != UISegmentedControlNoSegment)
    {
        [self setDisplayedStoryIndex:newIndex];
        newStory = [[self stories] objectAtIndex:newIndex];
        [[[[self navigationController] viewControllers] lastObject] setStory:newStory];
        [[[[self navigationController] viewControllers] lastObject] updateInterface];
    }

    [(UISegmentedControl *)sender setEnabled:([self displayedStoryIndex] > 0) forSegmentAtIndex:0];
    [(UISegmentedControl *)sender setEnabled:!([self displayedStoryIndex] == ([storiesArray count] - 1)) forSegmentAtIndex:1];
}

- (void)updateApplicationIconBadgeNumber {
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"showIconBadge"]) {
		int unreadMessages = 0;
		
		//calculate the number of unread messages
		for (Story *s in stories) {
			NSString * link = [s link];
			BOOL found = [self databaseContainsURL:link];
			if(!found){
				unreadMessages++;
			}
		}
		
		NSLog(@"%d unread Messages left", unreadMessages);
		
		//update the Badge
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadMessages];
	} else {
		NSLog(@"showIconBadges turned off");
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	}

	[super updateApplicationIconBadgeNumber];	
}

- (NSString *) extractThumbnailLink:(NSString *)htmlInput {
	return extractTextFromHTMLForQuery(htmlInput, @"//img[attribute::class=\"thumbnail\"]/attribute::src");
}

- (NSString *) extractText:(NSString *)htmlInput {
	return extractTextFromHTMLForQuery (htmlInput, @"/*[1]");
}

- (void)parseXMLFileAtURL:(NSString *)URL {
	[super parseXMLFileAtURL:URL];

	// This needs to be done in post-processing, as libxml2 interferes with NSXMLParser
	for (Story *s in stories) {
		NSString *thumbnailLink = [self extractThumbnailLink:[s summary]];
		if ([thumbnailLink length] > 0)
			[s setThumbnailLink:thumbnailLink];
//		NSString *pureText = [self extractText:[s summary]];
//		NSLog (pureText);
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];

	// This needs to be done in post-processing, as libxml2 interferes with NSXMLParser
    for (Story *s in stories) {
        NSString *thumbnailLink = [self extractThumbnailLink:[s summary]];
        if ([thumbnailLink length] > 0)
            [s setThumbnailLink:thumbnailLink];
    }
}

#pragma mark -
#pragma mark ATXMLParserDelegateProtocol

- (BOOL)parser:(ATXMLParser *)parser shouldAddParsedItem:(id)item
{
    NSScanner       *scanner = [NSScanner scannerWithString:[item summary]];
	NSMutableString *resultString = [[NSMutableString alloc] init];
    NSString        *aString;

    while (![scanner isAtEnd])
    {
        if ([scanner scanUpToString:@"<div id='mediaplayer'" intoString:&aString])
        {
            [resultString appendString:aString];
            [scanner scanUpToString:@"</div>" intoString:NULL];
            [scanner scanString:@"</div>" intoString:NULL];
        }
    }

    [item setSummary:resultString];
    [resultString release];

    return YES;
}

#pragma mark -

- (IBAction)openSafari:(id)sender {
	Apfeltalk_MagazinAppDelegate *appDelegate = (Apfeltalk_MagazinAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// :below:20090920 This is only to placate the analyzer
	myMenu = [[UIActionSheet alloc]
							 initWithTitle: nil
							 delegate:self
							 cancelButtonTitle:@"Abbrechen"
							 destructiveButtonTitle:nil
							 otherButtonTitles:@"Alle News als gel. mark.", @"Alle gesp. News löschen",nil];
	
    [myMenu showFromTabBar:[[appDelegate tabBarController] tabBar]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIdx
{	
	if (buttonIdx == 0) {
		//Alle News als gelesen markieren
		NSInteger i = 0;
		for( i = 0; i < [stories count]; i++) {
			Story *story = [stories objectAtIndex: i];
			NSString * link = [story link];
			
			if ([link length] > 0 && ![self databaseContainsURL:link]) {
				NSDate *date = [[stories objectAtIndex: i] date];
				
				const char *sql = "insert into read(url, date) values(?,?)"; 
				sqlite3_stmt *insert_statement;
				int error;
				error = sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL); 
				if (error == SQLITE_OK) {
					sqlite3_bind_text(insert_statement, 1, [link UTF8String], -1, SQLITE_TRANSIENT); 
					sqlite3_bind_double(insert_statement, 2, [date timeIntervalSinceReferenceDate]);
					error = (sqlite3_step(insert_statement) != SQLITE_DONE);
				}
				if (error == SQLITE_OK)
					error = sqlite3_finalize(insert_statement);	
				
				if (error != SQLITE_OK) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString (@"Datenbank Fehler", @"")
																	message:NSLocalizedString (@"Ein unerwarteter Fehler ist aufgetreten", @"")
																   delegate:nil
														  cancelButtonTitle:NSLocalizedString (@"OK", @"") otherButtonTitles:nil];
					[alert show];
					[alert release];
				}
				
				/*
				 *	More thinking needs to go into the deletion of reads
				 *
				 sqlite3_stmt *delete_statement;
				 NSString *deleteSql = [NSString stringWithFormat:@"delete from read where date<%f", [[[self class] oldestStoryDate] timeIntervalSinceReferenceDate]];
				 error = sqlite3_prepare_v2(database, [deleteSql UTF8String], -1, &delete_statement, NULL); 
				 if (error != SQLITE_OK)
				 NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
				 
				 error = sqlite3_step(delete_statement); 
				 error = error != SQLITE_DONE;
				 
				 error = sqlite3_finalize(delete_statement);	
				 if (error != SQLITE_OK)
				 NSLog (@"An error occurred: %s", sqlite3_errmsg(database));
				 */	
				[newsTable reloadData];
			} 
		}
	}
	if (buttonIdx == 1) {
		//Alle gespeicherten News löschen
		savedStories = [[NSMutableArray alloc] init];
		[self saveStories];
		[newsTable reloadData];
	}
	if (actionSheet == myMenu) {
		[myMenu release];
		myMenu = nil;
	}
}

- (void) dealloc {
	[savedStories release];
	[super dealloc];
}

@end
