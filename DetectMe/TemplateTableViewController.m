//
//  TemplateTableViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "TemplateTableViewController.h"

@interface TemplateTableViewController ()
@property (strong, nonatomic) NSArray *templateList;

@end

@implementation TemplateTableViewController

@synthesize templateList =_templateList;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //load all the templates
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/Templates",documentsDirectory];
    self.templateList = [filemng contentsOfDirectoryAtPath:path error:NULL];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.templateList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSString *templateName = [self.templateList objectAtIndex:indexPath.row];
    cell.textLabel.text = [templateName substringToIndex:templateName.length-4];
    return cell;
}


#pragma mark - Table view delegate
//What to do when a row is activated

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate setTemplate:[self.templateList objectAtIndex:indexPath.row]];
}

@end
