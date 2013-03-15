//
//  EvaluateTVC.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 14/03/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "EvaluateTVC.h"
#import "ConvolutionHelper.h"

@interface EvaluateTVC ()

@property (strong, nonatomic) NSMutableArray *evaluationImages;

@end



@implementation EvaluateTVC

@synthesize evaluationImages = _evaluationImages;
@synthesize trainingSet = _trainingSet;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load all the templates
    
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/EvaluationImages",documentsDirectory];
    self.evaluationImages = [[filemng contentsOfDirectoryAtPath:path error:NULL] mutableCopy];
    if(self.evaluationImages == nil) self.evaluationImages = [[NSMutableArray alloc] init];
    [self.evaluationImages addObject:@""]; //add last object to contain the plus sign
    NSLog(@"%d", self.evaluationImages.count);
    
//    self.evaluationImages = [[NSMutableArray alloc] initWithObjects:@"SunDay",@"MonDay",@"TuesDay",@"WednesDay",@"ThursDay",@"FriDay",@"SaturDay",@"",nil];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;    
}



#pragma mark
#pragma mark - Tag view controller delegate

- (void) setImage:(UIImage *)image withBoundingBoxes:(NSArray *) boxes
{
    [self.trainingSet.images addObject:image];
    for(ConvolutionPoint *cp in boxes)
    {
        cp.imageIndex = self.trainingSet.images.count-1;
    }
}



#pragma mark
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.evaluationImages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"EvaluationImagesCell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"EvaluationImagesCell"];
    }
    
    NSString *imageName = [self.evaluationImages objectAtIndex:indexPath.row];
    cell.textLabel.text = imageName;
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.evaluationImages.count-1) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.evaluationImages removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        NSLog(@"Ramonet Added!");
        [self performSegueWithIdentifier: @"Show Tag View" sender: self];
    }   
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Tag View"]) {
        TagViewController *tagVC = (TagViewController *) segue.destinationViewController;
        tagVC.delegate = self;
    }
    
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}




@end
