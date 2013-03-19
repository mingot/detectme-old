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


-(void) saveAtPath: (NSString *)path
{
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *totalPath = [path stringByAppendingPathComponent:self.imageTitle];

    //If it dos not exist, create path and store HQ image
    if(![filemng fileExistsAtPath:totalPath]){
        [filemng createDirectoryAtPath:totalPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        //save imageHQ
        NSData *imgHQ = UIImageJPEGRepresentation(self.imageHQ, 0.75);
        if([filemng createFileAtPath:[totalPath stringByAppendingPathComponent:@"imageHQ.jpg"] contents:imgHQ attributes:nil]){
            NSLog(@"HQ image saved");
        }
    }
    
    //save the TN
    NSData *imgTN = UIImageJPEGRepresentation(self.imageTN, 0.75);
    if([filemng createFileAtPath:[totalPath stringByAppendingPathComponent:@"imageTN.jpg"] contents:imgTN attributes:nil]){
        NSLog(@"TN image saved");
    }
    
    //save boxes
    if([NSKeyedArchiver archiveRootObject:self.boxes toFile:[totalPath stringByAppendingPathComponent:@"boxes"]]){
        NSLog(@"Boxes saved");
    }
    
}

-(void) deleteAtPath:(NSString *)path
{
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *totalPath = [path stringByAppendingPathComponent:self.imageTitle];
    if([filemng fileExistsAtPath:totalPath]){
        [filemng removeItemAtPath:totalPath error:nil];
        NSLog(@"Image removed from HD");
    }
}

+ (TestImage *) getImage:(NSString *)imageTitle formPath:(NSString *)path
{
    TestImage *testImage = [[TestImage alloc] init];
    NSString *totalPath = [path stringByAppendingPathComponent:imageTitle];
    if(![[NSFileManager defaultManager] fileExistsAtPath:totalPath]){
        NSLog(@"Image not found");
        return nil;
    }else{
        testImage.imageTitle = imageTitle;
        testImage.imageHQ = [UIImage imageWithContentsOfFile:[totalPath stringByAppendingPathComponent:@"imageHQ.jpg"]];
        testImage.imageTN = [UIImage imageWithContentsOfFile:[totalPath stringByAppendingPathComponent:@"imageTN.jpg"]];
        testImage.boxes = [NSKeyedUnarchiver unarchiveObjectWithFile:[totalPath stringByAppendingPathComponent:@"boxes"]];
    }
    
    return testImage;
}

@end




@implementation EvaluateTVC


@synthesize testImages = _testImages;
@synthesize path = _path;
@synthesize svmClassifier = _svmClassifier;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.testImages = [[NSMutableArray alloc] init];
    
    //load all the images present
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.path = [NSString  stringWithFormat:@"%@/TestsSets",documentsDirectory];
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.path]){
       [[NSFileManager defaultManager] createDirectoryAtPath:self.path withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        //Load images
        NSArray *imagesPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:NULL];
        for(NSString *imageName in imagesPath){
            [self.testImages addObject:[TestImage getImage:imageName formPath:self.path]];
        }
    }
    
    //Add edit button for the table
    UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStyleBordered target:self action:@selector(testAction:)];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects: self.editButtonItem, testButton, nil];
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
        newTestImage.imageTitle = [NSString stringWithFormat:@"%d",self.testImages.count];
        [self.testImages addObject:newTestImage];
        
        // save to disk
        [newTestImage saveAtPath:self.path];
        
    }else{ //old image to update
        TestImage *oldImage = [self.testImages objectAtIndex:index];
        oldImage.boxes = boxes;
        oldImage.imageTN = imageTN;
        
        //update in disk
        [oldImage saveAtPath:self.path];
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
        // Delete from the disk
        TestImage *tiDeleted = [self.testImages objectAtIndex:indexPath.row];
        [tiDeleted deleteAtPath:self.path];
        
        //Delete from memory
        [self.testImages removeObjectAtIndex:indexPath.row];
        
        //Delete from table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Picture"]){
        TagViewController *tagVC = (TagViewController *) segue.destinationViewController;
        tagVC.delegate = self;
        tagVC.initialIndex =-1;
        tagVC.svmClassifier = self.svmClassifier;
        
        //initialize it with the current image!
        int row = [[self.tableView indexPathForSelectedRow] row];
        if(row<self.testImages.count){
            TestImage *selectedTestImage = [self.testImages objectAtIndex:row];
            tagVC.initialImage = [selectedTestImage imageHQ];
            tagVC.initialBoxes = [[selectedTestImage boxes] mutableCopy];
            tagVC.initialIndex = row;
        }
    }
    
}


-(IBAction) testAction:(id)sender
{
    NSLog(@"Test begin");
    //Create training set
    TrainingSet *testSet = [[TrainingSet alloc] init];
    
    for(TestImage *ti in self.testImages){
        [testSet.images addObject:ti.imageHQ];
        for(Box *bb in ti.boxes){
            ConvolutionPoint *cp = [[ConvolutionPoint alloc] init];
            cp.imageIndex = [ti.imageTitle intValue];
            cp.xmin = bb.upperLeft.x/self.tableView.frame.size.width; 
            cp.ymin = bb.upperLeft.y/self.tableView.frame.size.height; 
            cp.xmax = bb.lowerRight.x/self.tableView.frame.size.width; 
            cp.ymax = bb.lowerRight.y/self.tableView.frame.size.height; 
            
            [testSet.groundTruthBoundingBoxes addObject:cp];
        }
        
    }

    NSLog(@"Running the test set...");
    [self.svmClassifier testOnSet:testSet atThresHold:0];
}


@end
