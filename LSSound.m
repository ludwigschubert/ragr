//
//  LSSound.m
//
//  Created by Ludwig Schubert on 22.05.10.
//  No real copyright as this stuff is easy.
//

#import "LSSound.h"

#import <AudioToolbox/AudioToolbox.h>


@interface LSSound()

+ (LSSound*)sharedPlayer;
- (void)playSoundWithName:(NSString*)soundFileName;

@property (nonatomic, retain) NSMutableDictionary *soundToSystemSoundID;

@end


static LSSound *shared = nil;
static dispatch_once_t onceToken;

@implementation LSSound

@synthesize soundToSystemSoundID;

#pragma mark - Public Method

+ (void)play:(NSString*)soundFileName 
{
    [[self sharedPlayer] playSoundWithName:soundFileName];
}

+ (void)vibrate
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark - Private Methods

+ (LSSound*)sharedPlayer {
    dispatch_once(&onceToken, ^{
        if (shared == nil) {
            shared = [[self alloc] init];
        }
    });
    return shared;
}

- (void)playSoundWithName:(NSString*)soundFileName
{
    
    NSArray *nameAndExtension = [soundFileName componentsSeparatedByString:@"."];
    if(nameAndExtension.count != 2)
	{
		NSLog(@"Filename %@ is invalid, it doesn't contain exactly one '.' character.", soundFileName);
		return;
	}
    
	NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:[nameAndExtension objectAtIndex:0] 
                                          ofType:nameAndExtension.lastObject];
    if(!path)
	{
		NSLog(@"Could not find sound file %@", soundFileName);
		return;
	}
    
	NSURL *urlSound = [NSURL fileURLWithPath:path
								 isDirectory:NO];
	
	if(!urlSound)
	{
		NSLog(@"Could not load sound file %@", soundFileName);
		return;
	}
	
	NSNumber *numberSound = [self.soundToSystemSoundID objectForKey:urlSound];
	if(!numberSound)
	{
		SystemSoundID sound = (SystemSoundID)-1;
		OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)urlSound,
														  &sound);
		if (error != kAudioServicesNoError) 
		{
			NSLog(@"AudioServices could not create sound from %@", soundFileName);
			return;
		}
		
		numberSound = [NSNumber numberWithUnsignedInt:sound];
		[self.soundToSystemSoundID setObject:numberSound
									  forKey:urlSound];
	}

	AudioServicesPlaySystemSound([numberSound unsignedIntValue]);
}

- (void)dealloc
{
	for (NSNumber *numberSound in self.soundToSystemSoundID.allValues)
	{
		AudioServicesDisposeSystemSoundID((SystemSoundID)[numberSound unsignedIntValue]);
	}
    
    self.soundToSystemSoundID = nil;
}

@end
