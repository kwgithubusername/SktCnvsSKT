//
//  DeckViewController.m
//  starterkit
//
//  Created by Woudini on 11/26/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "DeckViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
//#import "DBCameraViewController.h"
//#import "DBCameraContainerViewController.h"

typedef void (^CancelTouchesInViewBlock)();

@interface DeckViewController () <UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imageView; // to display the image - lazily instantiate
@property (nonatomic, strong) UIImage *image; // the image we're displaying - no instance variable
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *currentView;
@property BOOL drawingEnabled;
@property BOOL touchDrawViewCreated;
@property (nonatomic, copy) CancelTouchesInViewBlock cancelTouchesInViewBlock;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *undoButton;


@end

@implementation DeckViewController

/* ATTEMPT TO FADE THE NAV BAR
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 self.view.window.backgroundColor = self.view.backgroundColor;
 UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeInFadeOut:)];
 [self.view.window addGestureRecognizer:tapper];
 
 }
 
 
 -(void)fadeInFadeOut:(UITapGestureRecognizer *)sender {
 static BOOL hide = YES;
 id hitView = [self.navigationController.view hitTest:[sender locationInView:self.navigationController.view] withEvent:nil];
 
 if (! [hitView isKindOfClass:[UINavigationBar class]] && hide == YES) {
 hide = ! hide;
 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
 [UIView animateWithDuration:.35 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
 self.navigationController.navigationBar.alpha = 0;
 //     self.bottomView.alpha = 0;
 } completion:nil];
 
 }else if (hide == NO){
 hide = ! hide;
 [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
 [UIView animateWithDuration:.35 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
 self.navigationController.navigationBar.alpha = 1;
 //    self.bottomView.alpha = 1;
 } completion:nil];
 }
 }
 */
#pragma mark View and Image Management

-(void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    _scrollView.delegate = self;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(UIImageView *)imageView // lazily instantiate.
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

-(UIImage *)image
{
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image
{
    self.imageView.image = nil;
    self.imageView.image = image;
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero; // If the struct becomes nil the result would be undefined
}

#pragma mark Translation, Transform, and Rotation

- (void)panDetected:(UIPanGestureRecognizer *)panRecognizer
{
    CGPoint translation = [panRecognizer translationInView:self.view];
    CGPoint imageViewPosition = self.imageView.center;
    imageViewPosition.x += translation.x;
    imageViewPosition.y += translation.y;
    
    self.imageView.center = imageViewPosition;
    [panRecognizer setTranslation:CGPointZero inView:self.view];
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer
{
    CGFloat scale = pinchRecognizer.scale;
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, scale, scale);
    pinchRecognizer.scale = 1.0;
}

- (void)rotationDetected:(UIRotationGestureRecognizer *)rotationRecognizer
{
    CGFloat angle = rotationRecognizer.rotation;
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, angle);
    rotationRecognizer.rotation = 0.0;
}

#pragma mark Add Photo

/*
 - (void) openCamera
 {
 DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
 [cameraContainer setFullScreenMode];
 
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
 [nav setNavigationBarHidden:YES];
 [self presentViewController:nav animated:YES completion:nil];
 }
 
 - (void) openCameraWithoutSegue
 {
 DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
 [cameraController setUseCameraSegue:NO];
 
 DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self];
 [container setCameraViewController:cameraController];
 [container setFullScreenMode];
 
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
 [nav setNavigationBarHidden:YES];
 [self presentViewController:nav animated:YES completion:nil];
 }
 
 - (void) openCameraWithoutContainer
 {
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[DBCameraViewController initWithDelegate:self]];
 [nav setNavigationBarHidden:YES];
 [self presentViewController:nav animated:YES completion:nil];
 }
 
 //Use your captured image
 #pragma mark - DBCameraViewControllerDelegate
 
 - (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
 {self.image = nil;
 //DetailViewController *detail = [[DetailViewController alloc] init];
 //[detail setDetailImage:image];
 self.image = image;
 // [self.navigationController pushViewController:detail animated:NO];
 [cameraViewController restoreFullScreenMode];
 [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
 }
 
 - (void) dismissCamera:(id)cameraViewController{
 [self dismissViewControllerAnimated:YES completion:nil];
 [cameraViewController restoreFullScreenMode];
 }
 */
- (IBAction)saveImage:(UIBarButtonItem *)sender {
    
    //UIImageWriteToSavedPhotosAlbum(imageToBeSaved, nil, nil, nil);
}

- (IBAction)addPhoto:(UIBarButtonItem *)sender
{   [self.spinner startAnimating];
    if (![[self class] canAddPhoto])
    {UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No camera detected" message:@"This device does not have a camera." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];     [self.spinner stopAnimating];} else {
            //  [self openCamera];}
            UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
            uiipc.delegate = self;
            uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
            uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            uiipc.allowsEditing = YES;
            [self presentViewController:uiipc animated:YES completion:NULL];}
    
}

- (IBAction)cameraRoll:(UIBarButtonItem *)sender
{   [self.spinner startAnimating];
    if (![[self class] canAddPhoto])
    {UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No camera detected" message:@"This device does not have a camera." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];    [self.spinner stopAnimating];} else {
            //  [self openCamera];}
            UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
            uiipc.delegate = self;
            uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
            uiipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            uiipc.allowsEditing = YES;
            [self presentViewController:uiipc animated:YES completion:NULL];}
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
        [self.spinner stopAnimating];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = nil;
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.currentView setNeedsDisplay];
    [self.spinner stopAnimating];
}

+(BOOL)canAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return YES;
    } return NO;
}

- (IBAction)enableDrawingButton:(UIBarButtonItem *)sender
{   NSLog(@"Drawing enabled:%hhd", self.drawingEnabled);
    if (self.drawingEnabled == NO)
    {
        for (TouchDrawView *tdv in self.view.subviews)
        {
            if (tdv.tag == 999)
            {
                // A TouchDrawView already exists
                tdv.drawingEnabled = YES;
                self.undoButton.enabled = YES;
                self.touchDrawViewCreated = YES;
                NSLog(@"A TouchDrawView already exists:%d", [self.view.subviews count]);
            }
        }
        
        if (!self.touchDrawViewCreated)
        {
            // Create a TouchDrawView
            TouchDrawView *tdv = [[TouchDrawView alloc] initWithFrame:self.view.frame];
            [self.view addSubview:tdv];
            tdv.tag = 999;
            tdv.drawingEnabled = YES;
            self.undoButton.enabled = YES;
            tdv.deckViewControllerProperty = self; // Enables TouchDrawView to set and pass the undo block back to self
            NSLog(@"draw view created");
        }

        if (self.cancelTouchesInViewBlock)
        {   // Cancel touches
            self.cancelTouchesInViewBlock();
        }
        // Tell DeckViewController that drawing is enabled
    sender.tintColor = [UIColor redColor];
    self.drawingEnabled = YES;
    NSLog(@"Drawing enabled:%hhd", self.drawingEnabled);

    }
    else
    {NSLog(@"Drawing enabled is YES");
        for (TouchDrawView *tdv in self.view.subviews)
        {
            if (tdv.tag == 999)
            {   // Disable drawing for TouchDrawView
                tdv.drawingEnabled = NO;
                self.undoButton.enabled = NO;
            }
        }
        
        if (self.cancelTouchesInViewBlock)
        {   // Enable touches
            self.cancelTouchesInViewBlock();
        }
       sender.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
       self.drawingEnabled = NO;
    }
}
- (IBAction)undoButtonClicked:(UIBarButtonItem *)sender
{
    if (self.passUndoMethodBlock)
        self.passUndoMethodBlock();
}


#pragma mark Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    self.drawingEnabled = NO;
    self.touchDrawViewCreated = NO;
    [self.spinner stopAnimating];
    self.navigationController.toolbarHidden = NO;
    
    [self.scrollView insertSubview:self.imageView atIndex:0];
    
    self.imageView.userInteractionEnabled = YES;
    //    self.scrollView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationDetected:)];
    [self.view addGestureRecognizer:rotationRecognizer];
    
    panRecognizer.delegate = self;
    pinchRecognizer.delegate = self;
    rotationRecognizer.delegate = self;
    
    DeckViewController __weak *weakself = self;
    [self setCancelTouchesInViewBlock:^{
        DeckViewController *innerSelf = weakself;
        if (innerSelf.drawingEnabled)
        {
            panRecognizer.cancelsTouchesInView = YES;
            pinchRecognizer.cancelsTouchesInView = YES;
            rotationRecognizer.cancelsTouchesInView = YES;
        }
        else if (!innerSelf.drawingEnabled)
        {
            panRecognizer.cancelsTouchesInView = NO;
            pinchRecognizer.cancelsTouchesInView = NO;
            rotationRecognizer.cancelsTouchesInView = NO;
        }
    }];

    
    if ([self.editor isEqualToString:@"deck"])
    {
        NSLog(@"We're making a deck");
        self.currentView = nil;
        DeckMakerView *v = [[DeckMakerView alloc] initWithFrame:self.view.frame];
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = v;
        [self.view addSubview:self.currentView];
    }
    
    if ([self.editor isEqualToString:@"truck"])
    {
        NSLog(@"We're making a truck");
        self.currentView = nil;
        TruckMakerView *v = [[TruckMakerView alloc] initWithFrame:self.view.frame];
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = v;
        [self.view addSubview:self.currentView];
    }
    
    if ([self.editor isEqualToString:@"wheel"])
    {
        NSLog(@"We're making a wheel");
        self.currentView = nil;
        WheelMakerView *v = [[WheelMakerView alloc] initWithFrame:self.view.frame];
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = v;
        [self.view addSubview:self.currentView];
    }
    
    if ([self.editor isEqualToString:@"tee"])
    {
        NSLog(@"We're making a tee");
        self.currentView = nil;
        TeeMakerView *v = [[TeeMakerView alloc] initWithFrame:self.view.frame];
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = v;
        [self.view addSubview:self.currentView];
    }
    
    
    
    // Do any additional setup after loading the view.
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
