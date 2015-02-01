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

@interface DeckViewController () <UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) UIImageView *imageView; // to display the image - lazily instantiate
@property (nonatomic, strong) UIImage *image; // the image we're displaying - no instance variable
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *currentView;
@property BOOL drawingEnabled;
@property BOOL touchDrawViewCreated;
@property (nonatomic, copy) CancelTouchesInViewBlock cancelTouchesInViewBlock;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *undoButton;
@property (nonatomic) CGRect imageForInstagramRect;


@end

@implementation DeckViewController

#pragma mark Instagram sharing

- (IBAction)shareButtonClicked:(UIBarButtonItem *)sender
{
    [self ShareInstagram];
}

-(void)ShareInstagram
{
    UIImagePickerController *imgpicker=[[UIImagePickerController alloc] init];
    imgpicker.delegate=self;
    [self storeimage];
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        
        CGRect rect = CGRectMake(0 ,0 , 612, 612);
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/15717.ig"];
        
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
        self.documentController = [[UIDocumentInteractionController alloc] init];
        self.documentController.UTI = @"com.instagram.photo";
        self.documentController.delegate=self;
        self.documentController = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
        self.documentController=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        self.documentController.delegate=self;
        [self.documentController presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
        //  [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        //   NSLog(@"instagramImageShare");
        UIAlertView *errorToShare = [[UIAlertView alloc] initWithTitle:@"Instagram unavailable " message:@"You need to install Instagram in your device in order to share this image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        errorToShare.tag=3010;
        [errorToShare show];
    }
}

- (UIImage *)captureView:(UIView *)view
{
    CGRect screenRect = self.imageForInstagramRect;
    NSLog(@"origin.y in captureview is %f", screenRect.origin.y);
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    CGContextTranslateCTM(ctx, 0, -screenRect.origin.y);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)storeimage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"15717.ig"];
    UIImage *NewImg=[self resizedImage:[self captureView:self.view] inImage:CGRectMake(0, 0, 612, 612) ];
    NSData *imageData = UIImagePNGRepresentation(NewImg);
    [imageData writeToFile:savedImagePath atomically:NO];
}

-(UIImage*)resizedImage:(UIImage *)image inImage:(CGRect)thumbRect
{
    CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    
    // There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
    // see Supported Pixel Formats in the Quartz 2D Programming Guide
    // Creating a Bitmap Graphics Context section
    // only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
    // and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
    // The images on input here are likely to be png or jpeg files
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    // Build a bitmap context that's the size of the thumbRect
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,       // width
                                                thumbRect.size.height,      // height
                                                CGImageGetBitsPerComponent(imageRef),   // really needs to always be 8
                                                4 * thumbRect.size.width,   // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                (CGBitmapInfo)alphaInfo
                                                );
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, thumbRect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    
    return result;
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    interactionController.delegate = self;
    
    return interactionController;
}

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
{   //NSLog(@"Drawing enabled:%hhd", self.drawingEnabled);
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
                //NSLog(@"A TouchDrawView already exists:%d", [self.view.subviews count]);
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
    //NSLog(@"Drawing enabled:%hhd", self.drawingEnabled);

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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageCaptureRect"])
    {
        self.imageForInstagramRect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
    }
}

- (void)loadEditorView
{
    if ([self.editorString isEqualToString:@"deck"])
    {
        NSLog(@"We're making a deck");
        self.currentView = nil;
        DeckMakerView *v = [[DeckMakerView alloc] initWithFrame:self.view.frame];
        v.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = v;
        [v addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
        //NSLog(@"Numberofsubviews: %d", [[self.view subviews] count]);
    }
    
    if ([self.editorString isEqualToString:@"truck"])
    {
        NSLog(@"We're making a truck");
        self.currentView = nil;
        TruckMakerView *v = [[TruckMakerView alloc] initWithFrame:self.view.frame];
        v.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = v;
        [v addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
        //NSLog(@"Numberofsubviews: %d", [[self.view subviews] count]);
    }
    
    if ([self.editorString isEqualToString:@"wheel"])
    {
        NSLog(@"We're making a wheel");
        self.currentView = nil;
        WheelMakerView *v = [[WheelMakerView alloc] initWithFrame:self.view.frame];
        v.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = v;
        [v addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
    }
    
    if ([self.editorString isEqualToString:@"tee"])
    {
        NSLog(@"We're making a tee");
        self.currentView = nil;
        TeeMakerView *v = [[TeeMakerView alloc] initWithFrame:self.view.frame];
        v.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = v;
        [v addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
    }
}

- (void)addPanPinchAndRotationGestureRecognizers
{
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
}

- (void)viewDidLoad
{
#warning too many lines of code here!
    [super viewDidLoad];
    self.drawingEnabled = NO;
    self.touchDrawViewCreated = NO;
    [self.spinner stopAnimating];
    self.navigationController.toolbarHidden = NO;
    
    [self.scrollView insertSubview:self.imageView atIndex:0];
    
    self.imageView.userInteractionEnabled = YES;
    //    self.scrollView.userInteractionEnabled = YES;
    [self addPanPinchAndRotationGestureRecognizers];

    [self loadEditorView];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    for (UIView *subview in self.view.subviews)
    {
        if (subview.tag == 999)
        {
            [subview removeObserver:self forKeyPath:@"imageCaptureRect"];
        }
    }
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
