

#import <UIKit/UIKit.h>
#define RECENTS_PHOTO_AMOUNT 20

@interface RecentsUserDefaults : NSObject

+(NSArray *)retrieveRecentsUserDefaults;

+(void)saveRecentsUserDefaults:(NSDictionary *)photo;

@end
