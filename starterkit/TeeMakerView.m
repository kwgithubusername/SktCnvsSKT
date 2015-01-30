//
//  TeeMakerView.m
//  starterkit
//
//  Created by Woudini on 12/15/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "TeeMakerView.h"
@interface TeeMakerView ()
{
    // Ad Banner
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
}
@end


@implementation TeeMakerView


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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)aRect
{
    // Drawing code
    // width of the screen
    CGFloat width = self.bounds.size.width;
    // height of the screen
    CGFloat height = self.bounds.size.height;
    
        UIBezierPath *path = [[UIBezierPath alloc] init];
    
        // left sleeve, top corner
        CGPoint a = CGPointMake(width/2-140, height/2-40);
    
        // shoulder point 1
        CGPoint b = CGPointMake(width/2-90,a.y-60);
    
        // shoulder point 2
        CGPoint c = CGPointMake(width/2-30,a.y-80);
    
        // shoulder point!2
        CGPoint p = CGPointMake(width/2+30,c.y);
    
        // collar control point
        CGPoint cp = CGPointMake(width/2, c.y+20);
    
        // shoulder point !1
        CGPoint d = CGPointMake(width/2+90,b.y);
    
        // right sleeve, top corner
        CGPoint e = CGPointMake(width/2+140,a.y);
    
        // right sleeve, bottom corner
        CGPoint f = CGPointMake(width/2+95,a.y+40);
    
        // armpit of sleeve
        CGPoint g = CGPointMake(width/2+75,e.y+15);
    
        // right side
        CGPoint h = CGPointMake(g.x, g.y+180);
    
        // bottom
        CGPoint i = CGPointMake(width/2-75,h.y);
    
        // left side
        CGPoint j = CGPointMake(width/2-75,g.y);
    
        // left sleeve, bottom corner
        CGPoint k = CGPointMake(width/2-95,f.y);
    
        [path moveToPoint:a];
        [path addLineToPoint:b];
        [path addLineToPoint:c];
    
        // collar
        [path addQuadCurveToPoint:p controlPoint:cp];
    
        [path addLineToPoint:d];
        [path addLineToPoint:e];
        [path addLineToPoint:f];
        [path addLineToPoint:g];
        [path addLineToPoint:h];
        [path addLineToPoint:i];
        [path addLineToPoint:j];
        [path addLineToPoint:k];
        [path closePath];
    
        // Create the outline
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
    
        // Redraw the path, as it has been changed to white
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        [path stroke];

    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-45, 320, 50)];
    _adBanner.delegate = self;
}


@end
