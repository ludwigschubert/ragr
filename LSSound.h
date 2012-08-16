//
//  LSSound.h
//  Helper Class
//  Should be named SoundPlayer, name was chosen for shortness rather than correctness
//
//  Created by Ludwig Schubert on 22.05.10.
//  No real copyright as this stuff is easy.
//
//	Play back sounds and caches them appropriately
//

#import <Foundation/Foundation.h>

@interface LSSound : NSObject

+ (void)play:(NSString*)soundFileName;
+ (void)vibrate;

@end
