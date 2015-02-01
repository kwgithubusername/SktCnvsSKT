//
//  WheelMakerView.m
//  starterkit
//
//  Created by Woudini on 12/15/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "WheelMakerView.h"
@interface WheelMakerView ()
{
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
}
@end
@implementation WheelMakerView


- (void)setup
{
    
    self.backgroundColor = [UIColor clearColor];
    
    // I'm not opaque
    self.opaque = NO;
    
    // want to redraw if bounds change
    self.contentMode = UIViewContentModeRedraw;
    [self setNeedsDisplay];
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    [self setup];
    return self;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}


-(int)scaleFactorForDevice
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2 : 1;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)aRect
{
    // Drawing code
    CGFloat width = self.bounds.size.width; //width of the screen
    CGFloat height = self.bounds.size.height-20; //height of the screen
    
    CGFloat scaleFactor = [self scaleFactorForDevice];
    
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, height/2)
                                                            radius:150*scaleFactor
                                                        startAngle:0
                                                          endAngle:180
                                                         clockwise:YES];
        
        // Fill the area outside of the bezier path we created with white
        // [path fill] does not cover the outside area with white; image shows through outside of the shape
        [[UIColor whiteColor] setFill];
        UIRectFill(aRect);
    
        // Cut a hole in the shape of the path, revealing the image in DeckViewController
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut);
        [path fill];
    
        // Inside circle of the wheel should be filled with white
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, height/2)
                                                             radius:50*scaleFactor
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        [path2 fill];
    
        // Redraw the paths, as they have been changed to white
        [path stroke];
        [path2 stroke];
    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-45, 320, 50)];
    _adBanner.delegate = self;
}


@end
