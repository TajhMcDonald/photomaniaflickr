//
//  ResentsTVC.m
//  TopPlaces

#import "ResentsTVC.h"
#import "RecentsUserDefaults.h"

@interface ResentsTVC ()

@end

@implementation ResentsTVC

// если вы разместите код в viewDidLoad, то он будет вызван
// только один раз при запуске приложения

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.photos = [RecentsUserDefaults retrieveRecentsUserDefaults];
}

@end
