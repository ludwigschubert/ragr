//
//  UISearchBar+TextField.m
//  ragr
//
//  Created by Ludwig Schubert on 16.08.12.
//
//

#import "UISearchBar+TextField.h"

@implementation UISearchBar (TextField)

@dynamic textField;
- (UITextField*)textField {
    return self.subviews[1];
}

@end
