//
//  ChoicesViewController.m
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChoicesViewController.h"
#import "CameraViewController.h"


#pragma mark
#pragma mark - Auxiliary class for PhotoDetectVC

@interface FakePhotoViewController:NSObject //Auxiliar class to pass information to the DetectPhotoVC

@property (strong,nonatomic) UIImageView *picture;
@property (strong,nonatomic) UIImage *originalImage;
@property (strong,nonatomic) DetectView *detectView;
@property BOOL photoFromCamera;

@end


@implementation FakePhotoViewController

@synthesize picture = _picture;
@synthesize originalImage = _originalImage;
@synthesize detectView = _detectView;

//lazy instantiantion
- (UIImageView *) picture
{
    if(!_picture) _picture = [[UIImageView alloc] init];
    return _picture;
}

- (DetectView *) detectView
{
    if(!_detectView) _detectView = [[DetectView alloc] init];
    return _detectView;
    
}
@end



@interface ChoicesViewController ()

@property (strong,nonatomic) FakePhotoViewController *detectPhotoViewController;

@end


@implementation ChoicesViewController

@synthesize detectPhotoViewController = _detectPhotoViewController;
@synthesize optionsViewController = _optionsViewController;
@synthesize templateName = _templateName;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.templateName = @"bottle.txt"; //Default template
    [self selectedTemplate]; //TODO: needs to be done via segues
    self.selectedTemplateLabel.text = [self.templateName substringToIndex:self.templateName.length-4];
}

-(void)selectedTemplate
{
    self.optionsViewController.templateName = self.templateName;
}


#pragma mark
#pragma mark - Buttons

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
        detectPhotoVC.picture = self.detectPhotoViewController.picture;
        detectPhotoVC.originalImage = self.detectPhotoViewController.originalImage;
        detectPhotoVC.detectView = self.detectPhotoViewController.detectView;
        detectPhotoVC.templateName = self.templateName;

    }
    
}


//TODO: needs to be passed through segue
-(IBAction)photoAction:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *photoSourceSheet = [[UIActionSheet alloc] initWithTitle:@"Select source:" delegate:self
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
#pragma mark - TemplateTableViewControllerDelegate method

-(void) setTemplate:(NSString *)name
{
    self.templateName = name;
    self.selectedTemplateLabel.text = [self.templateName substringToIndex:self.templateName.length-4];
    [self selectedTemplate];
}


#pragma mark - UIActionSheetDelegate methods

- (void) actionSheet:(UIActionSheet * ) actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        NSLog(@"The user cancelled adding an image.");
        return;
    }
    
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/TestImages",documentsDirectory];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    NSArray *items = [filemng contentsOfDirectoryAtPath:path error:NULL ];

    picker.delegate = self; //Once choose the photo, we are the delegate to manage the action done
    
    //picker.allowsEditing = YES;
    switch (buttonIndex)
    {
        case 0: //@"Take Photo"
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:picker animated:YES];
            break;
            
        case 1: //@"Choose Existing Photo"
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:picker animated:YES];
            break;
            
        case 2: //@"Test Images"
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
        
            [self performSegueWithIdentifier:@"show DetectPhotoVC" sender:self]; 
            break;
    }
}


#pragma mark - UIImagePickerControllerDelegate methods


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    //TODO: clean up this methods
    self.detectPhotoViewController  = [[FakePhotoViewController alloc] init];
    self.detectPhotoViewController.picture.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.detectPhotoViewController.originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) //Photo taken with the camera
    {
        UIImageWriteToSavedPhotosAlbum([info objectForKey:UIImagePickerControllerOriginalImage], nil, nil, nil);
        [self.detectPhotoViewController setPhotoFromCamera:YES];

    }else { // Photo chosen from the library
        if (self.detectPhotoViewController.picture.image.size.width > self.detectPhotoViewController.picture.image.size.height){
            [self.detectPhotoViewController setPhotoFromCamera:NO];

        }else {
            [self.detectPhotoViewController setPhotoFromCamera:YES];

        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
    double f = self.detectPhotoViewController.originalImage.size.height / self.detectPhotoViewController.originalImage.size.width;
    
    if (416 - 320*f < 0) {
        [self.detectPhotoViewController.picture setFrame:CGRectMake((320-416/f)/2, 0, 416/f, 416)];
        [self.detectPhotoViewController.detectView setFrame:CGRectMake((320-416/f)/2, 0, 416/f, 416)];

    }else {
        [self.detectPhotoViewController.picture setFrame:CGRectMake(0, (416-320*f)/2,320 , 320*f)];
        [self.detectPhotoViewController.detectView setFrame:CGRectMake(0, (416-320*f)/2,320 , 320*f)];

    }
    
    [self performSegueWithIdentifier:@"show DetectPhotoVC" sender:self]; 
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

@end
