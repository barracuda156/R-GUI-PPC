/*
 *  R.app : a Cocoa front end to: "R A Computer Language for Statistical Data Analysis"
 *  
 *  R.app Copyright notes:
 *                     Copyright (C) 2004  The R Foundation
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
 */


#import "EditorPrefPane.h"
#import "RController.h"

@interface EditorPrefPane (Private)
- (void)setIdentifier:(NSString *)newIdentifier;
- (void)setLabel:(NSString *)newLabel;
- (void)setCategory:(NSString *)newCategory;
- (void)setIcon:(NSImage *)newIcon;
@end

@implementation EditorPrefPane

- (id)initWithIdentifier:(NSString *)theIdentifier label:(NSString *)theLabel category:(NSString *)theCategory
{
	if (self = [super init]) {
		[self setIdentifier:theIdentifier];
		[self setLabel:theLabel];
		[self setCategory:theCategory];
		NSImage *theImage = [[NSImage imageNamed:@"RDoc"] copy];
		[theImage setFlipped:NO];
		[theImage lockFocus];
		[[NSColor blackColor] set];
		//		[theIdentifier drawAtPoint:NSZeroPoint withAttributes:nil];
		[theImage unlockFocus];
		[theImage recache];
		[self setIcon:theImage];
	}
	return self;
}


- (NSString *)identifier
{
    return identifier;
}

- (void)setIdentifier:(NSString *)newIdentifier
{
    id old = nil;
	
    if (newIdentifier != identifier) {
        old = identifier;
        identifier = [newIdentifier copy];
        [old release];
    }
}

- (NSString *)label
{
    return label;
}

- (void)setLabel:(NSString *)newLabel
{
    id old = nil;
	
    if (newLabel != label) {
        old = label;
        label = [newLabel copy];
        [old release];
    }
}

- (NSString *)category
{
    return category;
}

- (void)setCategory:(NSString *)newCategory
{
    id old = nil;
	
    if (newCategory != category) {
        old = category;
        category = [newCategory copy];
        [old release];
    }
}

- (NSImage *)icon
{
    return icon;
}

- (void)setIcon:(NSImage *)newIcon
{
    id old = nil;
	
    if (newIcon != icon) {
        old = icon;
        icon = [newIcon retain];
        [old release];
    }
}


// AMPrefPaneProtocol
- (NSView *)mainView
{
	if (!mainView) {
		[NSBundle loadNibNamed:@"EditorPrefPane" owner:self];
	}
	return mainView;
}

// AMPrefPaneInformalProtocol

- (void)willSelect
{}

- (void)didSelect
{
}

- (int)shouldUnselect
{
	// should be NSPreferencePaneUnselectReply
	return AMUnselectNow;
}

- (void)willUnselect
{}

- (void)didUnselect
{}

	/* end of std methods implementation */

- (IBAction) changeInternalOrExternal:(id)sender {
    [[RController getRController] changeInternalOrExternal:sender];
}

- (NSMatrix *) internalOrExternal {
	return internalOrExternal;
}

- (id) builtInPrefs {
	return builtInPrefs;
}

- (id) externalSettings {
	return externalSettings;
}

- (IBAction) changeShowSyntaxColoring:(id)sender {
    [[RController getRController] changeShowSyntaxColoring:sender];
}

- (id) showSyntaxColoring {
	return showSyntaxColoring;
}

- (IBAction) changeShowBraceHighlighting:(id)sender {
    [[RController getRController] changeShowBraceHighlighting:sender];
}

- (id) showBraceHighlighting {
	return showBraceHighlighting;
}

- (IBAction) changeHighlightInterval:(id)sender {
    [[RController getRController] changeHighlightInterval:sender];
}

- (id) highlightInterval {
	return highlightInterval;
}

- (IBAction) changeShowLineNumbers:(id)sender {
    [[RController getRController] changeShowLineNumbers:sender];
}

- (id) showLineNumbers {
	return showLineNumbers;
}

- (IBAction)changeExternalEditorName:(id)sender {
    [[RController getRController] changeExternalEditorName:sender];
}

- (id) externalEditorName {
	return externalEditorName;
}

- (IBAction) changeAppOrCommand:(id)sender {
    [[RController getRController] changeAppOrCommand:sender];
}

- (NSMatrix *) appOrCommand {
	return appOrCommand;
}

@end