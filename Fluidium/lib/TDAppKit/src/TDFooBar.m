//
//  TDFooBar.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/9/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDFooBar.h>
#import <TDAppKit/TDListItem.h>
#import "TDFooBarTextField.h"
#import "TDFooBarListView.h"
#import "TDFooBarListItem.h"
#import "TDFooBarTextView.h"

#define TEXT_MARGIN_X 20.0
#define TEXT_MARGIN_Y 5.0
#define LIST_MARGIN_X 20.0
#define LIST_MARGIN_Y -5.0

@interface TDFooBar ()
- (void)resizeListView;
@end

@implementation TDFooBar

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.dataSource = nil;
    self.textField = nil;
    self.listView = nil;
    self.fieldEditor = nil;
    [super dealloc];
}


- (BOOL)isFlipped {
    return YES;
}


- (void)awakeFromNib {
    [[self window] setDelegate:self];
}


#pragma mark -
#pragma mark Bounds

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    [self resizeSubviewsWithOldSize:NSZeroSize];
}


- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    NSRect bounds = [self bounds];
    
    [self.textField setFrame:[self textFieldRectForBounds:bounds]];
    [self resizeListView];
}


- (void)resizeListView {
    BOOL hidden = ![[textField stringValue] length];
    [self.listView setHidden:hidden];
    if (!hidden) {
        NSRect bounds = [self bounds];
        NSRect r = [self listViewRectForBounds:bounds];
        [self.listView setFrame:r];
    }
}


- (NSRect)textFieldRectForBounds:(NSRect)bounds {
    return NSMakeRect(TEXT_MARGIN_X, TEXT_MARGIN_Y, bounds.size.width - (TEXT_MARGIN_X * 2), 20);
}


- (NSRect)listViewRectForBounds:(NSRect)bounds {
    CGFloat listHeight = [TDFooBarListItem defaultHeight] * [self numberOfItemsInListView:listView];
    NSLog(@"listHeight: %f", listHeight);
    return NSMakeRect(LIST_MARGIN_X, NSMaxY([self frame]) + LIST_MARGIN_Y, bounds.size.width - (LIST_MARGIN_X * 2), listHeight);
}


#pragma mark -
#pragma mark NSResponder

- (void)moveUp:(id)sender {
    NSUInteger i = listView.selectedItemIndex;
    if (i <= 0 || NSNotFound == i) {
        i = 0;
    } else {
        i--;
    }
    listView.selectedItemIndex = i;
    [listView reloadData];
}


- (void)moveDown:(id)sender {
    NSUInteger i = listView.selectedItemIndex;
    NSUInteger last = [self numberOfItemsInListView:listView] - 1;
    if (i < last) {
        i++;
    } else if (NSNotFound == i) {
        i = 0;
    }
    listView.selectedItemIndex = i;
    [listView reloadData];
}


#pragma mark -
#pragma mark NSWindowDelegate

- (id)windowWillReturnFieldEditor:(NSWindow *)win toObject:(id)obj {
    if (obj == textField) {
        if (!fieldEditor) {
            self.fieldEditor = [[[TDFooBarTextView alloc] initWithFrame:NSZeroRect] autorelease];
            fieldEditor.bar = self;
        }
        return fieldEditor; 
    } else {
        return nil;
    }
}


#pragma mark -
#pragma mark NSTextFieldNotifictions

- (void)controlTextDidBeginEditing:(NSNotification *)n {
    self.listView.selectedItemIndex = 0;
    [[[self window] contentView] addSubview:self.listView];
    [self resizeListView];
}


- (void)controlTextDidEndEditing:(NSNotification *)n {
    [self.listView removeFromSuperview];
}


- (void)controlTextDidChange:(NSNotification *)n {
    self.listView.selectedItemIndex = 0;
    [self.listView reloadData];
    [self resizeListView];
}

                            
#pragma mark -
#pragma mark TDListViewDataSource

- (NSUInteger)numberOfItemsInListView:(TDListView *)lv {
    //NSAssert(dataSource, @"must provide a FooBarDataSource");
    return [dataSource numberOfItemsInFooBar:self];
}


- (TDListItem *)listView:(TDListView *)lv itemAtIndex:(NSUInteger)i {
    //NSAssert(dataSource, @"must provide a FooBarDataSource");
    
    TDFooBarListItem *item = (TDFooBarListItem *)[listView dequeueReusableItemWithIdentifier:[TDFooBarListItem reuseIdentifier]];
    if (!item) {
        item = [[[TDFooBarListItem alloc] init] autorelease];
    }
    
    item.first = (0 == i);
    item.last = (i == [self numberOfItemsInListView:lv] - 1);
    item.selected = (i == listView.selectedItemIndex);
    item.labelText = [dataSource fooBar:self objectAtIndex:i];
    [item setNeedsDisplay:YES];
    
    return item;
}


#pragma mark -
#pragma mark TDListViewDelegate

- (CGFloat)listView:(TDListView *)lv extentForItemAtIndex:(NSUInteger)i {
    return [TDFooBarListItem defaultHeight];
}


- (void)listView:(TDListView *)lv willDisplayItem:(TDListItem *)item atIndex:(NSUInteger)i {
    
}


- (NSUInteger)listView:(TDListView *)lv willSelectItemAtIndex:(NSUInteger)i {
    return i;
}


- (void)listView:(TDListView *)lv didSelectItemAtIndex:(NSUInteger)i {
    
}


- (void)listView:(TDListView *)lv itemWasDoubleClickedAtIndex:(NSUInteger)i {
    
}


#pragma mark -
#pragma mark Properties

- (NSTextField *)textField {
    if (!textField) {
        NSRect r = [self textFieldRectForBounds:[self bounds]];
        self.textField = [[[TDFooBarTextField alloc] initWithFrame:r] autorelease];
        [textField setDelegate:self];
        [(TDFooBarTextField *)textField setBar:self];
        [self addSubview:textField];
    }
    return textField;
}


- (TDListView *)listView {
    if (!listView) {
        NSRect r = [self listViewRectForBounds:[self bounds]];
        self.listView = [[[TDFooBarListView alloc] initWithFrame:r] autorelease];
        [listView setAutoresizingMask:NSViewWidthSizable];
        listView.dataSource = self;
        listView.delegate = self;
    }
    return listView;
}

@synthesize dataSource;
@synthesize textField;
@synthesize listView;
@synthesize fieldEditor;
@end
