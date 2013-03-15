//
//  AnnotationToolViewController.m
//  AnnotationTool
//
//  Created by Dolores Blanco Almazán on 31/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "TagViewController.h"
#import "UIImage+Resize.h"


#define UPPERBOUND 0
#define LOWERBOUND 504
#define LEFTBOUND 0
#define RIGHTBOUND 320

#define IMAGES 0
#define THUMB 1
#define OBJECTS 2


@implementation TagViewController

@synthesize scrollView = _scrollView;
@synthesize tagView = _tagView;
@synthesize imageView = _imageView;
@synthesize deleteButton = _deleteButton;

@synthesize filename = _filename;
@synthesize paths = _paths;
@synthesize delegate = _delegate;



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    srand(time(NULL));
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *doc = [NSString  stringWithFormat:@"%@/labelme/%@",documentsDirectory,@"Ramon"];
    self.paths = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@/iphoneimages",doc],[NSString stringWithFormat:@"%@/galleryimages",doc],[NSString stringWithFormat:@"%@/objects",doc], nil];;
    
    self.filename = [[NSString alloc] init];
    
    //scrollView initialization
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(LEFTBOUND, UPPERBOUND, RIGHTBOUND, LOWERBOUND)];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
	[self.scrollView setCanCancelContentTouches:NO];
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	self.scrollView.clipsToBounds = YES; // default is NO, we want to restrict drawing within our scrollview
	self.scrollView.scrollEnabled = YES;    
    
    //tagView initialization
    self.tagView = [[TagView alloc] initWithFrame:CGRectMake(LEFTBOUND, UPPERBOUND, RIGHTBOUND, LOWERBOUND)];
    [self.scrollView setContentSize:CGSizeMake(RIGHTBOUND, LOWERBOUND)];
    self.imageView.frame = self.scrollView.frame;
    
    [self.scrollView addSubview:self.imageView];
    [self.scrollView addSubview:self.tagView];
    [self.view addSubview:self.scrollView];

    //Push the modal for selecting the picture from the camera
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - UIImage Picker Controller

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.imageView.image = image;
    [picker dismissModalViewControllerAnimated:YES];
}

//-(IBAction)addAction:(id)sender
//{
//    int num = [annotationView numLabels];
//    Box *box = [[[Box alloc]initWithPoints:CGPointMake(110, 136) :CGPointMake(210, 236)] autorelease];
//    box.color=[[annotationView colorArray] objectAtIndex:(rand()%8)];
//    [[annotationView dictionaryBox] setObject:box forKey:[NSString stringWithFormat:@"%d",num]];
//    [annotationView setSelectedBox:num];
//    
//
//    num++;
//    [annotationView setNumLabels:num];
//    label.text=@"";
//    label.hidden=NO;
//    [annotationView setNeedsDisplay];
//    [self.table reloadData];
//
//}




-(IBAction)deleteAction:(id)sender
{
    int num = [[self.tagView dictionaryBox] count];
    
    if((num<1)||(self.tagView.selectedBox == -1)) return;

    Box *b;
    for (int i = self.tagView.selectedBox+1; i<num; i++) {
        b = [[self.tagView dictionaryBox] objectForKey:[NSString stringWithFormat:@"%d",i]];
        [[self.tagView dictionaryBox] setObject:b forKey:[NSString stringWithFormat:@"%d",i-1]];
    }
    [[self.tagView dictionaryBox] removeObjectForKey:[NSString stringWithFormat:@"%d",num-1]];
    self.tagView.selectedBox = -1;
    
    [self.tagView setNeedsDisplay];
}


-(void)saveImage
{
    NSFileManager * filemng = [NSFileManager defaultManager];
    //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [self.tagView setSelectedBox:-1];
    [self.tagView setNeedsDisplay];
    NSData *image = UIImageJPEGRepresentation(self.imageView.image, 0.75);
    UIGraphicsBeginImageContext(self.scrollView.frame.size);
    [self.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *thumbnailImage = [viewImage thumbnailImage:100 transparentBorder:0 cornerRadius:0 interpolationQuality:0];
    NSData *thumImage = UIImageJPEGRepresentation(thumbnailImage, 0.75);

    if([filemng createFileAtPath:[[self.paths objectAtIndex:IMAGES ] stringByAppendingPathComponent:self.filename] contents:image attributes:nil]){
        NSLog(@"Foto %@ creada correctamente",self.filename);
        NSLog(@"Bytes HQ: %d",image.length);


        if([filemng createFileAtPath:[[self.paths objectAtIndex:THUMB ] stringByAppendingPathComponent:self.filename] contents:thumImage attributes:nil]){
            NSLog(@"Foto %@ creada correctamente",self.filename);
            NSLog(@"Bytes pequeña: %d",thumImage.length);

        }
        else {
            NSLog(@" Foto %@ (gallery)no creada",self.filename);

        }
    }
    else {
        NSLog(@" Foto %@ (HQ)no creada",self.filename);
    }
}


-(void)saveDictionary
{
    NSString *path = [[self.paths objectAtIndex:OBJECTS ] stringByAppendingPathComponent:self.filename ];
    
    if([NSKeyedArchiver archiveRootObject:self.tagView.dictionaryBox toFile:path]){
        NSLog(@"DICCIONARIO GUARDADO OK");
    }else {
        NSLog(@"DICCIONARIO no GUARDADO ");
    }
}

-(void)createFilename
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    int icnt;
 
    //change defaultuser to [serverconnect.. username]
    NSString *cnt=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/labelme/%@/counter_file.txt",documentsDirectory,@"Ramon"] encoding:NSUTF8StringEncoding error:NULL];
    icnt= [cnt intValue] +1;
        
    NSLog(@"Count file: %d",icnt);
        
    cnt= [NSString stringWithString:[NSString stringWithFormat: @"%d",icnt]];
    [cnt writeToFile:[NSString stringWithFormat:@"%@/labelme/%@/counter_file.txt",documentsDirectory,@"Ramon"] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
    self.filename = [NSString stringWithFormat:@"%@-%@-%d.jpg", [[[NSDate date] description] substringToIndex:19],@"Ramon", icnt];
}

@end
