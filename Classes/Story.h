//
//  Story.h
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

#import <Foundation/Foundation.h>


@interface Story : NSObject <NSCoding> {
	NSString *title;
	NSString *summary;
	NSDate *date;
	NSString *author;
	NSString *link;
	NSString *thumbnailLink;
}
@property (readwrite, copy) NSString *title;
@property (readwrite, copy) NSString *summary;
@property (readwrite, copy) NSDate *date;
@property (readwrite, copy) NSString *author;
@property (readwrite, copy) NSString *link;
@property (readwrite, copy) NSString *thumbnailLink;

@end