//
//  KTTextView.m
//
//  Created by Kirby Turner on 10/29/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//
//  The MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "KTTextView.h"


@implementation KTTextView

@synthesize placeholderText = _placeholderText;
@synthesize placeholderColor = _placeholderColor;
@synthesize placeholderInset = _placeholderInset;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_placeholderText = nil;
	_placeholderColor = nil;
	_placeholder = nil;
	
}

- (void)setup
{
	[self setPlaceholderText:@""];
	[self setPlaceholderColor:[UIColor lightGrayColor]];
	
	CGRect frame = CGRectMake(8+self.placeholderInset.x, 8+self.placeholderInset.y, self.bounds.size.width - 16, 0);
	
	_placeholder = [[UILabel alloc] initWithFrame:frame];
	[_placeholder setLineBreakMode:NSLineBreakByWordWrapping];
	[_placeholder setNumberOfLines:0];
	[_placeholder setBackgroundColor:[UIColor clearColor]];
	[_placeholder setAlpha:0];
	[self addSubview:_placeholder];
	[_placeholder sizeToFit];
	//[self sendSubviewToBack:_placeholder];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidBeginEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidEndEditingNotification object:nil];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setup];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setup];
	}
	return self;
}

- (UIEdgeInsets)contentInset {
    return UIEdgeInsetsZero;
}

- (void)textChanged:(NSNotification *)notification
{
	if ([_placeholderText length] == 0) {
		return;
	}
	
	if ([[self text] length] == 0 && ![self isFirstResponder]) {
		[UIView animateWithDuration:0.35 animations:^{
			[_placeholder setAlpha:1.0];
		}];
	} else {
		[_placeholder setAlpha:0.0];
	}
}

- (void)drawRect:(CGRect)rect
{
	if ([_placeholderText length] > 0) {
		[_placeholder setAlpha:0.0];
		[_placeholder setFont:[self font]];
		[_placeholder setTextColor:_placeholderColor];
		[_placeholder setText:_placeholderText];
		_placeholder.frame = CGRectMake(8+self.placeholderInset.x, 8+self.placeholderInset.y, _placeholder.frame.size.width, _placeholder.frame.size.height);
		[_placeholder sizeToFit];
	}
	
	if ([[self text] length] == 0 && [_placeholderText length] > 0) {
		[_placeholder setAlpha:1.0];
	}
}

@end
