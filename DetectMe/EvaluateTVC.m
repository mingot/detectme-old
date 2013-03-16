//
//  EvaluateTVC.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 14/03/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "EvaluateTVC.h"
#import "ConvolutionHelper.h"




@implementation TestImage

@synthesize imageHQ = _imageHQ;
@synthesize imageTN = _imageTN;
@synthesize boxes = _boxes;
@synthesize imageTitle = _imageTitle;

@end


@implementation EvaluateTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load all the templates
    
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/EvaluationImages",documentsDirectory];
    self.testImages = [[NSMutableArray alloc] init];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;    
}



#pragma mark
#pragma mark - Tag view controller delegate

- (void) storeImage:(UIImage *)image thumbNail:(UIImage *)imageTN withBoundingoxes:(NSArray *)boxes inIndex:(int)index
{
    if(index==-1){ //New image to add
        TestImage *newTestImage = [[TestImage alloc] init];
        newTestImage.imageHQ = image;
        newTestImage.imageTN = imageTN;
        newTestImage.boxes = boxes;
        newTestImage.imageTitle = @"random";
        [self.testImages addObject:newTestImage];
    }else{ //old image to update
        TestImage *oldImage = [self.testImages objectAtIndex:index];
        oldImage.boxes = boxes;
        oldImage.imageTN = imageTN;
    }

    [self.tableView reloadData];
}



#pragma mark
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.testImages.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"EvaluationImagesCell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"EvaluationImagesCell"];
    }
    
    if(self.testImages.count == 0 || indexPath.row == self.testImages.count) cell.textLabel.text = @"Add photo";
    else{
        cell.textLabel.text = [[self.testImages objectAtIndex:indexPath.row] imageTitle];
        cell.imageView.image = [[self.testImages objectAtIndex:indexPath.row] imageTN];
    }
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.testImages.count)
        return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.testImages removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Picture"]){
        TagViewController *tagVC = (TagViewController *) segue.destinationViewController;
        tagVC.delegate = self;
        tagVC.initialIndex =-1;
        
        //initialize it with the current image!
        int row = [[self.tableView indexPathForSelectedRow] row];
        if(row<self.testImages.count){
            TestImage *selectedTestImage = [self.testImages objectAtIndex:row];
            tagVC.initialImage = [selectedTestImage imageHQ];
            tagVC.initialBoxes = [selectedTestImage boxes];
            tagVC.initialIndex = row;
            printf("Entra!!\n");
        }
    }
    
}


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
