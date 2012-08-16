//
//  LSSearchBar.m
//  ragr
//
//  Created by Ludwig Schubert on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LSSearchBar.h"

@implementation LSSearchBar

- (void) setCloseButtonTitle: (NSString *) title forState: (UIControlState)state
{
    [self setTitle: title forState: state forView:self];
}

-(void) setTitle: (NSString *) title forState: (UIControlState)state forView: (UIView *)view
{
    UIButton *cancelButton = nil;
    for(UIView *subView in view.subviews){
        if([subView isKindOfClass:UIButton.class])
        {
            cancelButton = (UIButton*)subView;
        }
        else
        {
            [self setTitle:title forState:state forView:subView];
        }
    }
    
    if (cancelButton)
    {
        
        if (cancelButton.frame.size.width == cancelButton.frame.size.height) {
            return; // This is the button that clears the textfield, we don't want to skin this!
        }
        [cancelButton setTitle:title forState:state];
        [cancelButton setImage:[UIImage imageNamed:@"cancelButton"] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
}

@end
