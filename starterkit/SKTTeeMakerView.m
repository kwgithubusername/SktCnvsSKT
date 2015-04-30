//
//  TeeMakerView.m
//  starterkit
//
//  Created by Woudini on 12/15/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "SKTTeeMakerView.h"
@interface SKTTeeMakerView ()

@end


@implementation SKTTeeMakerView


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

-(int)scaleFactorForDevice
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2 : 1;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)aRect
{
    // Drawing code
    // width of the screen
    CGFloat width = self.bounds.size.width;
    // height of the screen
    CGFloat height = self.bounds.size.height-25;
    
    CGFloat scaleFactor = [self scaleFactorForDevice];
    
        UIBezierPath *path = [[UIBezierPath alloc] init];
    
        // left sleeve, top corner
        CGPoint a = CGPointMake(width/2-140*scaleFactor, height/2-40*scaleFactor);
    
        // shoulder point 1
        CGPoint b = CGPointMake(width/2-90*scaleFactor,a.y-60*scaleFactor);
    
        // shoulder point 2
        CGPoint c = CGPointMake(width/2-30*scaleFactor,a.y-80*scaleFactor);
    
        // shoulder point!2
        CGPoint p = CGPointMake(width/2+30*scaleFactor,c.y);
    
        // collar control point
        CGPoint cp = CGPointMake(width/2, c.y+20*scaleFactor);
    
        // shoulder point !1
        CGPoint d = CGPointMake(width/2+90*scaleFactor,b.y);
    
        // right sleeve, top corner
        CGPoint e = CGPointMake(width/2+140*scaleFactor,a.y);
    
        // right sleeve, bottom corner
        CGPoint f = CGPointMake(width/2+95*scaleFactor,a.y+40*scaleFactor);
    
        // armpit of sleeve
        CGPoint g = CGPointMake(width/2+75*scaleFactor,e.y+15*scaleFactor);
    
        // right side
        CGPoint h = CGPointMake(g.x, g.y+180*scaleFactor);
    
        // bottom
        CGPoint i = CGPointMake(width/2-75*scaleFactor,h.y);
    
        // left side
        CGPoint j = CGPointMake(width/2-75*scaleFactor,g.y);
    
        // left sleeve, bottom corner
        CGPoint k = CGPointMake(width/2-95*scaleFactor,f.y);
    
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
}


@end
