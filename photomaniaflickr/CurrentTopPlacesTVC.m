

#import "CurrentTopPlacesTVC.h"
#import "FlickrFetcher.h"

@interface CurrentTopPlacesTVC ()

@end

@implementation CurrentTopPlacesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchTopPlaces];
}

-(IBAction)fetchTopPlaces{
    [self.refreshControl beginRefreshing]; // стартуем refresh control
    
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url
                                                completionHandler:
        ^(NSURL *location, NSURLResponse *response, NSError *error) {
              if (!error) {
                  NSData *jsonResults = [NSData dataWithContentsOfURL:url];
                  NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                          options:0
                                                                            error:NULL];
                  NSArray *places = [results valueForKeyPath:@"places.place"];
                  self.places =places;
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.refreshControl endRefreshing]; // останавливаем refresh control
              });
            }];
    [task resume];
}

@end
