//
//  ChoicesViewController.m
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChoicesViewController.h"


@implementation ChoicesViewController

@synthesize cameraViewController = _cameraViewController;
@synthesize detectPhotoViewController = _detectPhotoViewController;
@synthesize optionsViewController = _optionsViewController;
@synthesize templateViewController = _templateViewController;
@synthesize templateName = _templateName;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cameraViewController = [[CameraViewController alloc]initWithNibName:@"CameraViewController" bundle:NULL];
        self.detectPhotoViewController = [[DetectPhotoViewController alloc]initWithNibName:@"DetectPhotoViewController" bundle:NULL];
        self.optionsViewController = [[OptionsViewController alloc] initWithNibName:@"OptionsViewController" bundle:NULL];
        self.templateViewController = [[TemplateViewController alloc] initWithNibName:@"TemplateViewController" bundle:NULL];
        self.templateViewController.delegate = self;
        self.templateName = [[NSString alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.title = @"DetectMe";
    self.templateName = @"bottle.txt";
    [self selectedTemplate];
    self.label.text = [self.templateName substringToIndex:self.templateName.length-4];
}

-(void)selectedTemplate
{
    self.cameraViewController.templateName = self.templateName;
    self.detectPhotoViewController.templateName = self.templateName;
    self.optionsViewController.templateName = self.templateName;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark 
#pragma mark - Buttons



-(IBAction)photoAction:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *photoSourceSheet = [[UIActionSheet
                                            alloc] initWithTitle:@"Select source:" delegate:self
                                           cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                           otherButtonTitles:@"Take Photo", @"Choose Existing Photo", @"Test Images", nil];
        [photoSourceSheet showInView:self.view];
    }
    else { // No camera, just use the library.
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        //picker.allowsEditing = YES;
        [self presentModalViewController:picker animated:YES];
    }
}


#pragma mark
#pragma mark - TemplateViewControllerDelegate method

-(void) setTemplate:(NSString *)name
{
    self.templateName = name;
    self.label.text = [self.templateName substringToIndex:self.templateName.length-4];
    [self selectedTemplate];
}


#pragma mark - UIActionSheetDelegate methods

- (void) actionSheet:(UIActionSheet * ) actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"The user cancelled adding an image.");
    return;
    }
    
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/TestImages",documentsDirectory];
    UIImagePickerController *picker = [[UIImagePickerController alloc]
                                   init];
    NSArray *items = [filemng contentsOfDirectoryAtPath:path error:NULL ];

    picker.delegate = self;
    //picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:picker animated:YES];
            break;
            
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:picker animated:YES];
            break;
            
        case 2:
            self.detectPhotoViewController.picture.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:[items objectAtIndex:8]]];
            self.detectPhotoViewController.originalImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:[items objectAtIndex:8]]];
            double f =self.detectPhotoViewController.originalImage.size.height/self.detectPhotoViewController.originalImage.size.width;
            if (416 - 320*f < 0){
                [self.detectPhotoViewController.picture setFrame:CGRectMake((320-416/f)/2, 0, 416/f, 416)];
                [self.detectPhotoViewController.detectView setFrame:CGRectMake((320-416/f)/2, 0, 416/f, 416)];
            
            }else {
                [self.detectPhotoViewController.picture setFrame:CGRectMake(0, (416-320*f)/2,320 , 320*f)];
                [self.detectPhotoViewController.detectView setFrame:CGRectMake(0, (416-320*f)/2,320 , 320*f)];
                
            }
            
            [self.navigationController pushViewController:self.detectPhotoViewController animated:YES];
            break;
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    self.detectPhotoViewController.picture.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.detectPhotoViewController.originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum([info objectForKey:UIImagePickerControllerOriginalImage], nil, nil, nil);
        [self.detectPhotoViewController setPhotoFromCamera:YES];

    }else {
        if (self.detectPhotoViewController.picture.image.size.width>self.detectPhotoViewController.picture.image.size.height){
            [self.detectPhotoViewController setPhotoFromCamera:NO];

        }else {
            [self.detectPhotoViewController setPhotoFromCamera:YES];

        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
    double f =self.detectPhotoViewController.originalImage.size.height/self.detectPhotoViewController.originalImage.size.width;
    
    if (416 - 320*f < 0) {
        [self.detectPhotoViewController.picture setFrame:CGRectMake((320-416/f)/2, 0, 416/f, 416)];
        [self.detectPhotoViewController.detectView setFrame:CGRectMake((320-416/f)/2, 0, 416/f, 416)];

    }else {
        [self.detectPhotoViewController.picture setFrame:CGRectMake(0, (416-320*f)/2,320 , 320*f)];
        [self.detectPhotoViewController.detectView setFrame:CGRectMake(0, (416-320*f)/2,320 , 320*f)];

    }
   
    [self.navigationController pushViewController:self.detectPhotoViewController animated:YES];
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

@end
