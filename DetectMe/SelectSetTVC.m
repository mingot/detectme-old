//
//  SelectSetTVC.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 19/03/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "SelectSetTVC.h"
#import "EvaluateTVC.h"


@implementation SelectSetTVC

@synthesize setsList = _setsList;
@synthesize path = _path;
@synthesize svmClassifier = _svmClassifier;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load all the sets
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.path = [NSString stringWithFormat:@"%@/Sets",documentsDirectory];
    
    //Create directory if it does not exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:self.path withIntermediateDirectories:YES attributes:nil error:nil];
        self.setsList = [[NSMutableArray alloc] init];
        
    }else self.setsList = [[filemng contentsOfDirectoryAtPath:self.path error:NULL] mutableCopy];

    //edit button
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark
#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.editing ? self.setsList.count + 1 : self.setsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *CellIdentifier = @"SetsCell";
    BOOL b_addCell = (indexPath.row == self.setsList.count);

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if (!b_addCell) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    if (b_addCell)
        cell.textLabel.text = @"Add ...";
    else
        cell.textLabel.text = [self.setsList objectAtIndex:indexPath.row];
    
    return cell;
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if(editing) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.setsList.count inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    } else {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.setsList.count inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == self.setsList.count)
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete from hd
        NSString *directoryName = [self.path stringByAppendingPathComponent:[self.setsList objectAtIndex:indexPath.row]];
        [[NSFileManager defaultManager] removeItemAtPath:directoryName error:nil];
        
        // Delete from model
        [self.setsList removeObjectAtIndex:indexPath.row];
        
        // Delete from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
         NSLog(@"deleted row! elements:%d", self.setsList.count);
        
    }else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Add to hd
        NSString *newDirectoryName = [self.path stringByAppendingPathComponent:[NSString stringWithFormat:@"Set%d",self.setsList.count]];
        [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryName withIntermediateDirectories:YES attributes:nil error:nil];
        
        // Add to model
        [self.setsList addObject:[NSString stringWithFormat:@"Set%d",self.setsList.count]];
        
        //Add to table
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        NSLog(@"add new row! elements:%d", self.setsList.count);
        
        
        
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


#pragma mark
#pragma mark - Table view delegate
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"show EvaluateTVC"]){
        EvaluateTVC *evaluateTVC = (EvaluateTVC *) segue.destinationViewController;
        evaluateTVC.svmClassifier = self.svmClassifier;
        NSString *setName = [self.setsList objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        evaluateTVC.path = [self.path stringByAppendingPathComponent:setName];
        NSLog(@"selected directory: %@", evaluateTVC.path);
    }
}


@end
