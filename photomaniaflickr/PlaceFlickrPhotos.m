

#import "PlaceFlickrPhotos.h"
#import "FlickrFetcher.h"

@implementation PlaceFlickrPhotos
#define MAX_RESULTS 50


- (void)setPlace:(NSDictionary *)place
{
    _place = place;
    [self fetchPhotos];
}
- (IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing]; // стартуем refresh control
    
     [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height)
                             animated:YES];
    
   NSURL *url = [FlickrFetcher URLforPhotosInPlace:
                 [self.place valueForKeyPath:FLICKR_PLACE_ID] maxResults:MAX_RESULTS];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url
                                                completionHandler:
              ^(NSURL *location, NSURLResponse *response, NSError *error) {
                  if (!error) {
                      NSData *jsonResults = [NSData dataWithContentsOfURL:url];
                      NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                              options:0
                                                                                error:NULL];
                      NSArray *photos =[results valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                      self.photos =photos;
                  }
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.refreshControl endRefreshing]; // останавливаем refresh control
                   
                  });
              }];
    [task resume];
}

@end
