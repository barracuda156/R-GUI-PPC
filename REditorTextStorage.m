/*
 *  R.app : a Cocoa front end to: "R A Computer Language for Statistical Data Analysis"
 *  
 *  R.app Copyright notes:
 *                     Copyright (C) 2004-5  The R Foundation
 *                     written by Stefano M. Iacus and Simon Urbanek
 *
 *                  
 *  R Copyright notes:
 *                     Copyright (C) 1995-1996   Robert Gentleman and Ross Ihaka
 *                     Copyright (C) 1998-2001   The R Development Core Team
 *                     Copyright (C) 2002-2004   The R Foundation
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  A copy of the GNU General Public License is available via WWW at
 *  http://www.gnu.org/copyleft/gpl.html.  You can also obtain it by
 *  writing to the Free Software Foundation, Inc., 59 Temple Place,
 *  Suite 330, Boston, MA  02111-1307  USA.
 *
 *  Created by Simon Urbanek on 1/11/05.
 */

#import "REditorTextStorage.h"
#import "RGUI.h"
#import "PreferenceKeys.h"

@implementation REditorTextStorage

- (id) init
{
	self = [super init];
	if (self) {
		cont = [[NSTextStorage alloc] init];
		highlightColorAttr = nil;
		currentHighlight = -1;
		pendingHilite = -1;
		insideReplaceEdited = NO;
		[self updatePreferences];
		[[Preferences sharedPreferences] addDependent:self];
	}
	return self;
}

- (void) dealloc
{
	[[Preferences sharedPreferences] removeDependent:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[cont release];
	[super dealloc];
}

// mandatory primitive methods

- (NSString*) string
{
	return [cont string];
}

- (NSDictionary *) attributesAtIndex:(unsigned)index effectiveRange:(NSRangePointer)aRange
{
	[super ensureAttributesAreFixedInRange:NSMakeRange(index,1)];
	return [cont attributesAtIndex:index effectiveRange:aRange];
}

- (void) replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString
{
	int origLen = [self length];
	if (currentHighlight>-1) [self resetHighlights];
	[cont replaceCharactersInRange:aRange withString:aString];
	insideReplaceEdited = YES;
	[super ensureAttributesAreFixedInRange:NSMakeRange(aRange.location,[aString length])];
	[self edited:NSTextStorageEditedCharacters range:aRange changeInLength:[self length] - origLen];
	insideReplaceEdited = NO;
	if (pendingHilite>-1) {
		[self highlightCharacter:pendingHilite];
		pendingHilite = -1;
	}
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange
{
	[cont setAttributes:attributes range:aRange];
	[super ensureAttributesAreFixedInRange:aRange];
	[self edited:NSTextStorageEditedAttributes range:aRange changeInLength:0];
}

- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)aRange
{
	[cont addAttribute:name value:value range:aRange];
	[self ensureAttributesAreFixedInRange:aRange];
	[self edited:NSTextStorageEditedAttributes range:aRange changeInLength:0];
}

// end of primitive methods

- (BOOL)fixesAttributesLazily
{
	return YES;
}

- (NSLayoutManager*) layoutManager
{
	NSArray *lms = [self layoutManagers];
	if (lms) {
		int lmsc = [lms count];
		if (lmsc>0) {
			if (lmsc>1) SLog(@"REditorTextStorage(%@).layoutManager: more than one LM exists, returning the first one",self);
			return [lms objectAtIndex:0];
		}
	}
	return nil;
}

-(void)resetHighlights
{
	if (currentHighlight>-1) {
		if (currentHighlight<[cont length]) {
			NSLayoutManager *lm = [self layoutManager];
			if (lm) {
				NSRange fr = NSMakeRange(currentHighlight,1);
				NSDictionary *d = [lm temporaryAttributesAtCharacterIndex:currentHighlight effectiveRange:&fr];
				if (!d || [d objectForKey:NSBackgroundColorAttributeName]==nil) {
					fr = NSMakeRange(0,[self length]);
					SLog(@"resetHighlights: attribute at %d not found, clearing all %d characters - better safe than sorry", currentHighlight, fr.length);
				}
				[lm removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:fr];
			}
		}
		currentHighlight=-1;
	}
}

-(void)highlightCharacter: (int) pos
{
	if (insideReplaceEdited) {
		pendingHilite = pos;
		return;
	}
	[self resetHighlights];
	if (pos>=0 && pos<[self length]) {
		NSLayoutManager *lm = [self layoutManager];
		if (lm) {
			currentHighlight=pos;
			[lm setTemporaryAttributes:highlightColorAttr forCharacterRange:NSMakeRange(pos, 1)];
			[self performSelector:@selector(resetBackgroundColor:) withObject:nil afterDelay:braceHighlightInterval];
		} else SLog(@"highlightCharacter: attempt to set highlight %d beyond the text range 0:%d - I refuse!", pos, [self length]-1);
	}
}

-(void)resetBackgroundColor:(id)sender
{
	[self resetHighlights];
}

- (void) updatePreferences {
	NSColor *c = [Preferences unarchivedObjectForKey: @"braceHighlightColor" withDefault: nil];
	if (!c) c=[NSColor redColor];
	if (highlightColorAttr) [highlightColorAttr release];
	highlightColorAttr = [[NSDictionary alloc] initWithObjectsAndKeys:c, NSBackgroundColorAttributeName, nil];
	showMatchingBraces = [Preferences flagForKey:showBraceHighlightingKey withDefault: YES];
	braceHighlightInterval = [[Preferences stringForKey:highlightIntervalKey withDefault: @"0.2"] doubleValue];
}

@end
