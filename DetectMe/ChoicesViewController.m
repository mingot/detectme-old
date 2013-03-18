//
//  ChoicesViewController.m
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChoicesViewController.h"
#import "CameraViewController.h"
#import "EvaluateTVC.h"


@implementation ChoicesViewController

@synthesize optionsViewController = _optionsViewController;
@synthesize templateName = _templateName;
@synthesize selectedTemplateLabel = _selectedTemplateLabel;
@synthesize imageTakeForStillDetect = _imageTakeForStillDetect;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.templateName = @"bottle.txt"; //Default template
    self.selectedTemplateLabel.text = [self.templateName substringToIndex:self.templateName.length-4];
}



#pragma mark
#pragma mark - Segue

// Preapre for segueshowCameraVC showCameraVC
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show TemplateVC"]) {
        TemplateTableViewController *templateTableVC = (TemplateTableViewController *) segue.destinationViewController;
        templateTableVC.delegate = self; // For obtaining the selected template
        
    } else if ([segue.identifier isEqualToString:@"show CameraVC"]) {
        CameraViewController *cameraVC = (CameraViewController *) segue.destinationViewController;
        cameraVC.templateName = self.templateName;

    }else if ([segue.identifier isEqualToString:@"show DetectPhotoVC"]) {
        DetectPhotoViewController *detectPhotoVC = (DetectPhotoViewController *) segue.destinationViewController;
        detectPhotoVC.originalImage = self.imageTakeForStillDetect;
        detectPhotoVC.templateName = self.templateName;
    }else if ([segue.identifier isEqualToString:@"show EvaluateTVC"]){
        EvaluateTVC *evaluateTVC = (EvaluateTVC *) segue.destinationViewController;
        evaluateTVC.templateName = self.templateName;
        NSLog(@"TEMPLATE NAME: %@", evaluateTVC.templateName);
    }
    
}


//TODO: needs to be passed through segue
-(IBAction)photoAction:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *photoSourceSheet = [[UIActionSheet alloc] initWithTitle:@"Select source:" delegate:self
                                           cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                           otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil];
        [photoSourceSheet showInView:self.view];
        
    }else { // No camera, just use the library.
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES];
    }
}



#pragma mark
#pragma mark - TemplateTableViewControllerDelegate method

-(void) setTemplate:(NSString *)name
{
    self.templateName = name;
    self.selectedTemplateLabel.text = [self.templateName substringToIndex:self.templateName.length-4];
}


#pragma mark - UIActionSheetDelegate methods

- (void) actionSheet:(UIActionSheet * ) actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == actionSheet.cancelButtonIndex){
        NSLog(@"The user cancelled adding an image.");
        return;
    }
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];

    picker.delegate = self; //Once choose the photo, we are the delegate to manage the action done
    
    switch (buttonIndex){
            
        case 0: //@"Take Photo"
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:picker animated:YES];
            break;
            
        case 1: //@"Choose Existing Photo"
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:picker animated:YES];
            break;
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageTakeForStillDetect = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
    [self performSegueWithIdentifier:@"show DetectPhotoVC" sender:self]; 
}


@end
