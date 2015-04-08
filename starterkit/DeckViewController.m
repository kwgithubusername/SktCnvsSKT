//
//  DeckViewController.m
//  starterkit
//
//  Created by Woudini on 11/26/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "DeckViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ColorMapView/ColorMapView.h>
#import "HWGOptionsColorToStore.h"
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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *drawButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *baseColorBarButton;
@property (nonatomic) ColorMapView *colorView;
@property (nonatomic) HWGOptionsColorToStore *colorStorage;
@property (nonatomic) BOOL viewPushedByNavigationBar;

@end

@implementation DeckViewController

-(HWGOptionsColorToStore *)colorStorage
{
    if (!_colorStorage) _colorStorage = [[HWGOptionsColorToStore alloc] init];
    return _colorStorage;
}

- (IBAction)baseColorButtonClicked:(UIBarButtonItem *)sender
{
    self.colorView = [[ColorMapView alloc] initWithFrame:self.view.frame];
    self.colorView.tag = 130;
    [self.view addSubview:self.colorView];
    [self.view bringSubviewToFront:self.colorView];
    UITapGestureRecognizer *tapToSelectColorGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectColor:)];
    [self.view addGestureRecognizer:tapToSelectColorGestureRecognizer];
    tapToSelectColorGestureRecognizer.view.tag = 131;
}

-(void)selectColor:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:self.colorView];
    UIColor *selectedColor = [self.colorView getColorAtLocation:point];
    self.baseColorBarButton.tintColor = selectedColor;
    self.view.backgroundColor = selectedColor;
    [self.colorStorage saveColor:selectedColor];
    
    [self removeColorView];
    
    [self removeColorTapGestureRecognizer:tapGestureRecognizer];
    
    [self checkForExistingGestureRecognizersAndReapplyGestureRecognizersAsNeeded];
}

-(void)checkForExistingGestureRecognizersAndReapplyGestureRecognizersAsNeeded
{
    int gestureRecognizerCount = (int)[self.view.gestureRecognizers count];
    for (int i = 0; i < gestureRecognizerCount; i++)
    {
        if ([self.view.gestureRecognizers[i] isKindOfClass:[UIPanGestureRecognizer class]])
        {
            break;
        }
        if (i == gestureRecognizerCount-1)
        {
            [self addPanPinchAndRotationGestureRecognizers];
        }
    }
}

-(void)removeColorView
{
    for (UIView *view in self.view.subviews)
    {
        if (view.tag == 130)
        {
            [view removeFromSuperview];
        }
    }
}

-(void)removeColorTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    for (UIGestureRecognizer *gestureRecognizer in self.view.gestureRecognizers)
    {
        if (gestureRecognizer.view.tag == 131)
        {
            [gestureRecognizer removeTarget:self action:@selector(selectColor:)];
            [self.view removeGestureRecognizer:tapGestureRecognizer];
        }
    }
}

-(void)loadBaseColor
{
    UIColor *color = [self.colorStorage loadColor];
    if (color)
    {
        self.view.backgroundColor = color;
        self.baseColorBarButton.tintColor = color;
    }
}

#pragma mark Instagram sharing

- (IBAction)shareButtonClicked:(UIBarButtonItem *)sender
{
    [self ShareInstagram];
}

-(void)ShareInstagram
{
    [self storeimage];
//    UIImagePickerController *imgpicker=[[UIImagePickerController alloc] init];
//    imgpicker.delegate=self;
//    [self storeimage];
//    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
//    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
//    {
//        
//        CGRect rect = CGRectMake(0 ,0 , 612, 612);
//        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/15717.ig"];
//        
//        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
//        self.documentController = [[UIDocumentInteractionController alloc] init];
//        self.documentController.UTI = @"com.instagram.photo";
//        self.documentController.delegate=self;
//        self.documentController = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
//        self.documentController=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
//        self.documentController.delegate=self;
//        [self.documentController presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
//        //  [[UIApplication sharedApplication] openURL:instagramURL];
//    }
//    else
//    {
//        //   NSLog(@"instagramImageShare");
//        UIAlertView *errorToShare = [[UIAlertView alloc] initWithTitle:@"Instagram unavailable " message:@"You need to install Instagram in your device in order to share this image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        
//        errorToShare.tag=3010;
//        [errorToShare show];
//    }
}

- (UIImage *)captureView:(UIView *)view
{
    CGRect screenRect = self.imageForInstagramRect;
    NSLog(@"origin.y in captureview is %f", screenRect.origin.y);
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    CGContextTranslateCTM(ctx, -screenRect.origin.x, -screenRect.origin.y);
    
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
    UIImageWriteToSavedPhotosAlbum(NewImg, nil, nil, nil);
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

#pragma mark Drawing

- (IBAction)drawButtonClicked:(UIBarButtonItem *)sender
{
    if (self.drawingEnabled == NO)
    {
        for (OMMTouchableView *touchableView in self.view.subviews)
        {
            if (touchableView.tag == 998)
            {
                // A TouchDrawView already exists
                touchableView.drawingEnabled = YES;
                self.undoButton.enabled = YES;
                self.touchDrawViewCreated = YES;
                //NSLog(@"A TouchDrawView already exists:%d", [self.view.subviews count]);
            }
        }
        
        if (!self.touchDrawViewCreated)
        {
            // Create a TouchDrawView
            OMMTouchableView *touchableView = [[OMMTouchableView alloc] initWithFrame:self.view.frame];
            [self.view addSubview:touchableView];
            touchableView.tag = 998;
            touchableView.drawingEnabled = YES;
            self.undoButton.enabled = YES;
            //touchableView.deckViewControllerProperty = self; // Enables TouchDrawView to set and pass the undo block back to self
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
        
    {
        NSLog(@"Drawing enabled is YES");
        for (OMMTouchableView *touchableView in self.view.subviews)
        {
            if (touchableView.tag == 998)
            {   // Disable drawing for TouchDrawView
                touchableView.drawingEnabled = NO;
                self.undoButton.enabled = NO;
            }
        }
        
        [self addPanPinchAndRotationGestureRecognizers];
        sender.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        self.drawingEnabled = NO;
    }

}

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

#pragma mark Add Photo

- (IBAction)saveImage:(UIBarButtonItem *)sender {
    
    //UIImageWriteToSavedPhotosAlbum(imageToBeSaved, nil, nil, nil);
}

- (IBAction)addPhoto:(UIBarButtonItem *)sender
{   [self.spinner startAnimating];
    if (![[self class] canAddPhoto])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No camera detected" message:@"This device does not have a camera." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [self.spinner stopAnimating];
    } else
    {
            UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
            uiipc.delegate = self;
            uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
            uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            uiipc.allowsEditing = YES;
            [self presentViewController:uiipc animated:YES completion:NULL];
    }
    
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
        DeckMakerView *view = [[DeckMakerView alloc] initWithFrame:self.view.frame];
        view.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = view;
        [view addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
        //NSLog(@"Numberofsubviews: %d", [[self.view subviews] count]);
    }
    
    if ([self.editorString isEqualToString:@"truck"])
    {
        NSLog(@"We're making a truck");
        self.currentView = nil;
        TruckMakerView *view = [[TruckMakerView alloc] initWithFrame:self.view.frame];
        view.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = view;
        [view addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
        //NSLog(@"Numberofsubviews: %d", [[self.view subviews] count]);
    }
    
    if ([self.editorString isEqualToString:@"wheel"])
    {
        NSLog(@"We're making a wheel");
        self.currentView = nil;
        WheelMakerView *view = [[WheelMakerView alloc] initWithFrame:self.view.frame];
        view.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = view;
        [view addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
    }
    
    if ([self.editorString isEqualToString:@"tee"])
    {
        NSLog(@"We're making a tee");
        self.currentView = nil;
        TeeMakerView *view = [[TeeMakerView alloc] initWithFrame:self.view.frame];
        view.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = view;
        [view addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
    }
}

#pragma mark - Translation, Transform, and Rotation -

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
    
    DeckViewController __weak *weakSelf = self;
    [self setCancelTouchesInViewBlock:^{
        [weakSelf.view removeGestureRecognizer:panRecognizer];
        [weakSelf.view removeGestureRecognizer:rotationRecognizer];
        [weakSelf.view removeGestureRecognizer:pinchRecognizer];
    }];
}

#pragma mark - View methods -

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.drawingEnabled = NO;
    self.touchDrawViewCreated = NO;
    [self.spinner stopAnimating];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.hidden = YES;
    
    [self.scrollView insertSubview:self.imageView atIndex:0];
    
    self.imageView.userInteractionEnabled = YES;
    [self addPanPinchAndRotationGestureRecognizers];
    
    [self loadBaseColor];
    [self loadEditorView];
    
    __weak DeckViewController *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UIViewAnimationDidCommitNotification"
                              object:nil
                               queue:nil
                          usingBlock:^(NSNotification* notification){
                    
                                    if ([[notification userInfo][@"name"] isEqual:@"UINavigationControllerHideShowNavigationBar"])
                                    {
                                        [weakSelf pushViewBasedOnNavigationBarChange];
                                    };
                          }];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound)
    {
        for (UIView *subview in self.view.subviews)
        {
            if (subview.tag == 999)
            {
                [subview removeObserver:self forKeyPath:@"imageCaptureRect"];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UINavigationControllerHideShowNavigationBar" object:nil];
}

-(void)pushViewBasedOnNavigationBarChange
{
    if (self.navigationController.navigationBarHidden == YES)
    {
        NSLog(@"navbar is being hidden");
        [self pushViewDownToCounterNavigationBarBeingHidden];
    }
    else
    {
        NSLog(@"navbar is becoming visible");
        [self pushViewUpToCounterNavigationBarBeingShown];
    }
}

-(void)pushViewDownToCounterNavigationBarBeingHidden
{
    if (!self.viewPushedByNavigationBar)
    {
        self.imageView.frame = CGRectOffset(self.imageView.frame, 0, 88);
        self.viewPushedByNavigationBar = YES;
    }
}

-(void)pushViewUpToCounterNavigationBarBeingShown
{
    if (self.viewPushedByNavigationBar)
    {
        self.imageView.frame = CGRectOffset(self.imageView.frame, 0, -88);
        self.viewPushedByNavigationBar = NO;
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
