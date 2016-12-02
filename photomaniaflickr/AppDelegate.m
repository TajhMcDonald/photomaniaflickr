#import "AppDelegate.h"
#import "ImageViewController.h"
#import "FlickrPhotos.h"
#import "FlickrFetcher.h"

@interface AppDelegate ()<UISplitViewControllerDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
                               didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
    
    // показываем storyboard
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
       UISplitViewController *splitViewController =
                                         (UISplitViewController *)self.window.rootViewController;
    //-----------------Detail------------------------------
    UINavigationController *navigationController =
                                                [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem =
                                                      splitViewController.displayModeButtonItem;
    navigationController.topViewController.navigationItem.leftItemsSupplementBackButton = YES;

    splitViewController.preferredDisplayMode =  UISplitViewControllerDisplayModeAllVisible;
    splitViewController.delegate = self;
}

     [self.window makeKeyAndVisible];
    return YES;
}

-(NSUInteger )rowForPhotos: (NSArray *)photos imageURL:(NSString *)urlString{
    NSUInteger row = 0;
    for (NSDictionary *photo in photos) {
        NSString *urlStringPhoto = [[FlickrFetcher URLforPhoto:photo
                                format:FlickrPhotoFormatLarge] absoluteString];
        if ([urlString isEqualToString:urlStringPhoto]) {
            row = [photos indexOfObject:photo];
        }
    }
    return row;
}

#define FLICKR_UNKNOWN_PHOTO @"Unknown"

-(NSString *)titleForRow:(NSUInteger)row inPhotos:(NSArray *)photos
{
    NSString *titleCell = [photos[row] valueForKeyPath:FLICKR_PHOTO_TITLE];
    if ([titleCell length]== 0) {
        titleCell = [photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        if ([titleCell length]== 0) {
            titleCell = FLICKR_UNKNOWN_PHOTO;
        }
    }
    return titleCell;
    
}

#pragma mark - Split view Controller

#define FLICKR_UNKNOWN_PHOTO @"Unknown"

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
separateSecondaryViewControllerFromPrimaryViewController:
(UIViewController *)primaryViewController {
  NSString *urlString = @"";
    if ([primaryViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *masterNav =
                    ((UITabBarController *)primaryViewController).selectedViewController;
        if ([masterNav isKindOfClass:[UINavigationController class]]) {
            UINavigationController *primaryNav = (UINavigationController *)masterNav;
            
            //---Если ImageView Controller как top в  NavigationController для Master,
            //---то убираем из стэка NavigationController
                if ([primaryNav.topViewController isKindOfClass:[ImageViewController class]]) {
                    
                    urlString =
                    [((ImageViewController *)primaryNav.topViewController).imageURL absoluteString];
                    
                   [primaryNav popViewControllerAnimated:NO];
                    
            }
            //---------- Работаем со списком фотографий  и находим строку в списке по imageURL---
            
            if ( [[primaryNav topViewController] isKindOfClass:[FlickrPhotos class]]) {
                FlickrPhotos *masterView = (FlickrPhotos *)[primaryNav topViewController];
                NSArray *photos = masterView.photos;
                
                NSUInteger row = [self rowForPhotos:photos imageURL:urlString];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                
                //--------Выбираем autoselectedPhoto-------------------------------------------
                NSDictionary *autoselectedPhoto = (NSDictionary *)masterView.photos [indexPath.row];
                NSURL *imageURLSelectedPhoto = [FlickrFetcher URLforPhoto:autoselectedPhoto
                                                                   format:FlickrPhotoFormatLarge];
                NSString *title = [self titleForRow:indexPath.row inPhotos:masterView.photos] ;
             
                //------ Получаем Detail со storyboard-----------------------
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
                UINavigationController *detailView =
                [storyboard instantiateViewControllerWithIdentifier:@"detailNavigation"];
                [masterView.tableView  selectRowAtIndexPath:indexPath
                                                   animated:YES scrollPosition:row];
                
                
                // Обеспечиваем появление обратной кнопки
                UIViewController *controller = [detailView visibleViewController];
                controller.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
                controller.navigationItem.leftItemsSupplementBackButton = YES;
                
                //---устанавливаем фотографию для autoselectedPhoto в качестве Модели----
                if ([controller isKindOfClass:[ImageViewController class]]) {
                    if (autoselectedPhoto) {
                        [masterView.tableView  selectRowAtIndexPath:indexPath
                                                           animated:YES scrollPosition:0];
                        ((ImageViewController *)controller).imageURL = imageURLSelectedPhoto;
                        ((ImageViewController *)controller).title = title ;
                    }
                }
                return detailView;
            }
        }
    }
    return  nil;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]) {
        
        // Navigation Controller для Detail
        UINavigationController *secondaryNav = (UINavigationController *)secondaryViewController;
        
        if ([secondaryNav.topViewController isKindOfClass:[ImageViewController class]]) {
            ImageViewController *detailView = (ImageViewController *)secondaryNav.topViewController;
            
            if (detailView.imageURL == nil) {
                
                // Возвращаем YES, чтобы показать, что мы сами будем управлять
                // Detail для collapsed интерфейса
                //  и ничего не делаем;  следовательно Detail будет отвергнуто.
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
   showDetailViewController:(UIViewController *)detailVC
                     sender:(id)sender
{
    //--------Если ImageView Controller и режим collapsed,
    // то ImageViewController помещаем в стэк NavigationController для  Master----
    
    if (splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact){
        if ([splitViewController.viewControllers[0] isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController *masterVC = splitViewController.viewControllers[0];
            if ([masterVC.selectedViewController isKindOfClass:[ UINavigationController class]]) {
                UINavigationController *masterNav = masterVC.selectedViewController;
                
                if ([detailVC isKindOfClass:[ UINavigationController class]]) {
                    UINavigationController *detailNav = (UINavigationController *)detailVC;
                    if ([detailNav.topViewController isKindOfClass:[ImageViewController class]]) {
                        ImageViewController *ivc = (ImageViewController *)detailNav.topViewController;
                        ivc.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
                        ivc.navigationItem.leftItemsSupplementBackButton = YES;
                        
                        [masterNav showViewController:ivc sender:sender];
                        
                        return  YES;
                    }
                }
            }
        }
    }
    return  NO;
    
}

@end
