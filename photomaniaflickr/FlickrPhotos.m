

#import "FlickrPhotos.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"
#import "RecentsUserDefaults.h"

@interface FlickrPhotos ()

@property (nonatomic,strong) ImageViewController *imageViewController;

@end

@implementation FlickrPhotos

-(void)setPhotos:(NSArray *)photos
{
    _photos =photos;
    [self.tableView reloadData];
}


#define FLICKR_UNKNOWN_PHOTO @"Unknown"

-(NSString *)titleForRow:(NSUInteger)row
{
    NSString *titleCell = [self.photos[row] valueForKeyPath:FLICKR_PHOTO_TITLE];
    if ([titleCell length]== 0) {
        titleCell = [self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        if ([titleCell length]== 0) {
            titleCell = FLICKR_UNKNOWN_PHOTO;
        }
    }
    return titleCell;
    
}

-(NSString *)subTitleForRow:(NSUInteger)row
{
    NSString *subTitle = [self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
                          
    // description может быть NSNull
    if ([[self titleForRow:row] isEqualToString:subTitle] ||
        [[self titleForRow:row] isEqualToString:FLICKR_UNKNOWN_PHOTO]) {
        subTitle = @"";
    }
    return subTitle;
    
}

#pragma mark - UITableViewDaraSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Число секций.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
                                        numberOfRowsInSection:(NSInteger)section
{
    // Число строк в секции.
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
                                     cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    // Конфигурируем cell
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];
    
    return cell;
}

#pragma mark - Navigation

-(void)prepareImageViewController:(ImageViewController *)ivc
                   toDisplayPhoto:(NSDictionary *)photo
                           forRow:(NSUInteger)row
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo
                                       format:FlickrPhotoFormatLarge];
    ivc.title = [self titleForRow:row];
    ivc.navigationItem.leftBarButtonItem.title = self.title;
    ivc.navigationItem.leftBarButtonItem =
                self.splitViewController.displayModeButtonItem;
    ivc.navigationItem.leftItemsSupplementBackButton = YES;
    
    [RecentsUserDefaults saveRecentsUserDefaults:self.photos[row]];
    
}

// нам необходима некоторая подготовка перед навигацией
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Получаем новый View Controller,
    // используя [segue destinationViewController].
    // Это может быть Navigation Controller, в этом случае берем его topViewController
    // Передаем выбранное photo новому View Controller
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath =[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                id vc = segue.destinationViewController;
                id ivc =vc;
                if ([vc isKindOfClass:[UINavigationController class]]) {
                   ivc = [(UINavigationController  *)vc topViewController] ;
                }

                if ([ivc isKindOfClass:[ImageViewController class]]) {
                    self.imageViewController = ivc;
                    [self prepareImageViewController:ivc
                                      toDisplayPhoto:self.photos[indexPath.row]
                                              forRow:indexPath.row];
                    
             
                }
            }
        }
    }
}



@end
