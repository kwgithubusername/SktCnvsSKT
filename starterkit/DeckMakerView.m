//
//  DeckMaker.m
//  starterkit
//
//  Created by Woudini on 12/1/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "DeckMakerView.h"
#import <QuartzCore/QuartzCore.h>
@interface DeckMakerView ()
{
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
}
@end

@implementation DeckMakerView

- (void)setup
{
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO; // I'm not opaque
    self.contentMode = UIViewContentModeRedraw; // want to redraw if bounds change
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

- (void)drawRect:(CGRect)aRect
{
    NSLog(@"drawRect called");
    CGFloat width = self.bounds.size.width; //width of the screen
    CGFloat height = self.bounds.size.height; //height of the screen
    NSLog(@"%f", height);
    // widths: iphone 6: 375; iphone 6+: 414; 320 other models
        UIBezierPath *path = [[UIBezierPath alloc] init];
    
        // MISC NOTES:
        //  CGPoint topLeft = CGPointMake(self.navbarheight, 150); It would be nice to get the nav bar height
        //  Create scale factor for screen size- truck is too small

        //top left corner
        [path moveToPoint:CGPointMake(width/2-50, height/2-90)];
        [path addQuadCurveToPoint:CGPointMake(width/2,height/2-168) controlPoint:CGPointMake(width/2-50,height/2-168)];
    
        //top right corner
        [path addQuadCurveToPoint:CGPointMake(width/2+50,height/2-90) controlPoint:CGPointMake(width/2+50,height/2-168)];
    
        //right side
        [path addLineToPoint:CGPointMake(width/2+50, height/2+140)];
    
        //bottom right corner
        [path addQuadCurveToPoint:CGPointMake(width/2,height/2+218) controlPoint:CGPointMake(width/2+50,height/2+218)];
    
        //bottom left corner
        [path addQuadCurveToPoint:CGPointMake(width/2-50,height/2+140) controlPoint:CGPointMake(width/2-50,height/2+218)];
        [path closePath];
        
        [[UIColor blackColor] setStroke];
        
        [path stroke];
        
        // Fill the area outside of the bezier path we created with white
        // [path fill] does not cover the outside area with white; image shows through outside of the shape
        [[UIColor whiteColor] setFill];
        UIRectFill(aRect);
    
        // Cut a hole in the shape of the path, revealing the image in DeckViewController
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut); 
        [path fill];
        
    
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        
        // Draw bolts
        UIBezierPath *bolt1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2-10, height/2-90)
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        UIBezierPath *bolt2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2+10, height/2-90)
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        UIBezierPath *bolt3 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2-10, height/2-65)
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        UIBezierPath *bolt4 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2+10, height/2-65)
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        UIBezierPath *bolt5 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2-10, height/2+140-25)
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        UIBezierPath *bolt6 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2+10, height/2+140-25)
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        UIBezierPath *bolt7 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2-10, height/2+140)
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        UIBezierPath *bolt8 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2+10, height/2+140)
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:180
                                                          clockwise:YES];
        [[UIColor blackColor] setFill];
    
        // Fill in bolts
        [bolt1 stroke];
        [bolt1 fill];
        [bolt2 stroke];
        [bolt2 fill];
        [bolt3 stroke];
        [bolt3 fill];
        [bolt4 stroke];
        [bolt4 fill];
        [bolt5 stroke];
        [bolt5 fill];
        [bolt6 stroke];
        [bolt6 fill];
        [bolt7 stroke];
        [bolt7 fill];
        [bolt8 stroke];
        [bolt8 fill];
    
        // Attempt to draw shadow
   /*     CGContextRef ctx2 = UIGraphicsGetCurrentContext();
        CGContextSetShadowWithColor(ctx2, CGSizeMake(-2,+2), 5, [[UIColor blackColor] CGColor]);
        [[UIColor grayColor] setStroke]; */
    
    // Redraw the path, as it has been changed to white
    [path stroke];

    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-45, 320, 50)];
    _adBanner.delegate = self;
    
}

@end
