//
//  RecipeTableViewController.m
//  DorothyParker
//
//  Created by Janice Garingo on 10/15/13.
//  Copyright (c) 2013 Janice Garingo. All rights reserved.
//

#import "RecipeTableViewController.h"
#import "RecipeDetailViewController.h"

@interface RecipeTableViewController ()

@property (nonatomic) NSString *imageBaseURL;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation RecipeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self requestObjects];
}

- (void)requestObjects
{
    
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"recipes.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error : %@" , error);
    }];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    

    if(!_fetchedResultsController)
    {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Recipe class])];
        
        fetchRequest.sortDescriptors = @[];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        NSError *error;
        
        self.fetchedResultsController.delegate = self;
        
        [self.fetchedResultsController performFetch:&error];
        
        NSAssert(!error, @"Error performing fetch request: ", error);
        
    }
    
    return _fetchedResultsController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"recipeDetailSegue"])
    {
        RecipeDetailViewController *recipeDetailViewController = [segue destinationViewController];
        NSInteger currentRow = [self.tableView indexPathForSelectedRow].row;
        
        Recipe *selectedRecipe = [[self.fetchedResultsController fetchedObjects] objectAtIndex:currentRow];
        
        recipeDetailViewController.ingredients = selectedRecipe.ingredients;
        recipeDetailViewController.recipedescription = selectedRecipe.recipedescription;
        recipeDetailViewController.thumbnail = [NSString stringWithFormat:@"%@%@", kBaseURL, selectedRecipe.thumbnail];
        recipeDetailViewController.thumbnailRetina = [NSString stringWithFormat:@"%@%@", kBaseURL, selectedRecipe.thumbnailretina];
        
    }
}

# pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

# pragma mark - UITableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"recipeDetailSegue" sender:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSLog(@" [sectionInfo numberOfObjects] : %i ", [sectionInfo numberOfObjects]);
    
    return [sectionInfo numberOfObjects];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    Recipe *recipe = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = recipe.title;
    
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
