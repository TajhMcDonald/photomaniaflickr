

#import "TopPlacesTVC.h"
#import "FlickrFetcher.h"
#import "PlaceFlickrPhotos.h"

@interface TopPlacesTVC ()


// словарей NSDictionary с ключом - страна, значением - массив словарей-мест
@property (nonatomic, strong) NSDictionary *placesByCountry;
@property (nonatomic, strong) NSArray *countries;

@end


@implementation TopPlacesTVC

// как только устанавливаем Модель, нужно адаптировать View

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self createPlacesByCountryForPlaces:_places];
    [self.tableView reloadData];
}

- (NSString *)countryForPlace: (NSDictionary *) topPlace {
    NSString *placeInformation = topPlace [FLICKR_PLACE_NAME];
    return [placeInformation componentsSeparatedByString:@", "].lastObject;
}

-(void)createPlacesByCountryForPlaces:(NSArray *)places
{
    
    // Нам нужно разделить места по странам, так что мы можем использовать
    // словарь с именами стран в качестве ключа и
    // массивом places в качестве значения
    NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    
    // Для каждого place
    for (NSDictionary *place in places) {
        // извлекаем имя страны
        NSString *country = [self countryForPlace:place];
        // если страны нет в словаре, то добавляем ее в словарь в качестве ключа,
        // а в качестве значения новый массив
        if (!placesByCountry[country]) {
            placesByCountry[country] = [NSMutableArray array];
        }
        // Добавляем place в массив для определенной страны
        [(NSMutableArray *)placesByCountry[country] addObject:place];
        
    }
    
    // Устанавливаем свойство : места по странам
    self.placesByCountry = placesByCountry;
    
    // Устанавливаем массив стран по алфавиту для заголовков секций
    self.countries = [[placesByCountry allKeys] sortedArrayUsingSelector:
                      @selector(caseInsensitiveCompare:)];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // число секций.
    return self.countries.count;
}

- (NSString *) tableView:(UITableView *)tableView
                     titleForHeaderInSection:(NSInteger)section {
    
    // Return the header at the given index
    return self.countries[section];
}


- (NSInteger)tableView:(UITableView *)tableView
                             numberOfRowsInSection:(NSInteger)section
{
    // число строк в секции.
    return [self.placesByCountry [self.countries [section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
                        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top places";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    // Конфигурируем ячейку..
    // Получаем словарь, содержащий информацию о топовом месте
    NSDictionary *topPlaceDictionary =
    self.placesByCountry [self.countries[indexPath.section]] [indexPath.row];
    
    // Извлекаем из словаря наименование топового места
    NSString *topPlaceDescription = topPlaceDictionary [FLICKR_PLACE_NAME];
    
    // Выделяем отдельные компоненты наименования (страна, город, провинция и т.д.)
    
    NSMutableArray *placeNameComponents =
                 [[topPlaceDescription componentsSeparatedByString:@", "] mutableCopy];
    // Убираем страну country
    [placeNameComponents removeLastObject];
    
    NSString *titleCell = placeNameComponents[0];
    // Убираем заголовок Title
    [placeNameComponents removeObjectAtIndex:0];
    
    NSString *subTitleCell = [placeNameComponents componentsJoinedByString:@", "];
    
    cell.textLabel.text = titleCell;
    cell.detailTextLabel.text = subTitleCell;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath =[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Place Photos"]) {
                if ([segue.destinationViewController isKindOfClass:[PlaceFlickrPhotos class]]) {
                    
                    // Идентифицируем выбранное топовое место из словаря мест по странам
                    NSDictionary *place = self.placesByCountry
                    [self.countries [indexPath.section]] [indexPath.row];
                    
                    [segue.destinationViewController setPlace:place ];
                    [segue.destinationViewController setTitle:[[sender textLabel] text]];
                }
            }
        }
    }
}


@end
