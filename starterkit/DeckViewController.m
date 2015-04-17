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
typedef void (^RemoveColorGestureBlock)();

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
@property (nonatomic, copy) RemoveColorGestureBlock removeColorGestureBlock;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *undoButton;
@property (nonatomic) CGRect imageForInstagramRect;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *drawButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *baseColorBarButton;
@property (nonatomic) ColorMapView *colorView;
@property (nonatomic) HWGOptionsColorToStore *colorStorage;
@property (nonatomic) BOOL isPickingColor;


@end

@implementation DeckViewController

#pragma mark - Base color picker -

-(HWGOptionsColorToStore *)colorStorage
{
    if (!_colorStorage) _colorStorage = [[HWGOptionsColorToStore alloc] init];
    return _colorStorage;
}

- (IBAction)baseColorButtonClicked:(UIBarButtonItem *)sender
{
    if (!self.isPickingColor)
    {
        [self showColorPicker];
    }
    else
    {
        [self hideColorPicker];
    }
}

-(void)showColorPicker
{
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.colorView = [[ColorMapView alloc] initWithFrame:CGRectMake(viewFrame.origin.x, viewFrame.origin.y+statusBarHeight+44, viewFrame.size.width, viewFrame.size.height-44*3-statusBarHeight)];
    self.colorView.tag = 130;
    
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^ { [self.view addSubview:self.colorView]; }
                    completion:nil];
    
    [self.view bringSubviewToFront:self.colorView];
    UITapGestureRecognizer *tapToSelectColorGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectColor:)];
    [self.view addGestureRecognizer:tapToSelectColorGestureRecognizer];
    tapToSelectColorGestureRecognizer.view.tag = 131;
    self.isPickingColor = YES;
}

-(void)hideColorPicker
{
    [self removeColorView];
    [self removeColorTapGestureRecognizer:nil];
    [self checkForExistingGestureRecognizersAndReapplyGestureRecognizersAsNeeded];
    self.isPickingColor = NO;
}

-(void)selectColor:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer && self.isPickingColor)
    {
        CGPoint point = [tapGestureRecognizer locationInView:self.colorView];
        UIColor *selectedColor = [self.colorView getColorAtLocation:point];
        self.baseColorBarButton.tintColor = selectedColor;
        self.view.backgroundColor = selectedColor;
        [self.colorStorage saveColor:selectedColor];
    }

    [self removeColorView];
    [self removeColorTapGestureRecognizer:tapGestureRecognizer];
    [self checkForExistingGestureRecognizersAndReapplyGestureRecognizersAsNeeded];
    self.isPickingColor = NO;
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
            [UIView transitionWithView:self.view duration:0.2
                               options:UIViewAnimationOptionTransitionFlipFromLeft //change to whatever animation you like
                            animations:^ { [view removeFromSuperview]; }
                            completion:nil];
        }
    }
}

-(void)removeColorTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view removeGestureRecognizer:tapGestureRecognizer];
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

#pragma mark - View and Image Management -

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

#pragma mark - Add Photo -

- (IBAction)saveImage:(UIBarButtonItem *)sender {
    
    //UIImageWriteToSavedPhotosAlbum(imageToBeSaved, nil, nil, nil);
}

- (IBAction)addPhoto:(UIBarButtonItem *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner startAnimating];
    });
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
    [self makeNavigationBarTransparent];
}

+(BOOL)canAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return YES;
    } return NO;
}

#pragma mark - Setup -

- (void)loadEditorView
{
    if ([self.editorString isEqualToString:@"deck"])
    {
        // NSLog(@"We're making a deck");
        self.currentView = nil;
        DeckMakerView *view = [[DeckMakerView alloc] initWithFrame:self.view.frame];
        view.tag = 999;
        self.currentView = [[UIView alloc] initWithFrame:self.view.frame];
        self.currentView = view;
        [view addObserver:self forKeyPath:@"imageCaptureRect" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.currentView];
        // NSLog(@"Numberofsubviews: %d", [[self.view subviews] count]);
    }
    
    if ([self.editorString isEqualToString:@"truck"])
    {
        // NSLog(@"We're making a truck");
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
        // NSLog(@"We're making a wheel");
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
        // NSLog(@"We're making a tee");
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

-(void)makeNavigationBarTransparent
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeNavigationBarTransparent];
    self.drawingEnabled = NO;
    self.touchDrawViewCreated = NO;
    [self.spinner stopAnimating];
    self.navigationController.toolbarHidden = NO;
    
    [self.scrollView insertSubview:self.imageView atIndex:0];
    
    self.imageView.userInteractionEnabled = YES;
    [self addPanPinchAndRotationGestureRecognizers];
    
    [self loadBaseColor];
    [self loadEditorView];
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
    [self.navigationController.navigationBar setBackgroundImage:nil
    forBarMetrics:UIBarMetricsDefault];
}

@end
