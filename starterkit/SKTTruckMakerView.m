//
//  TruckMakerView.m
//  starterkit
//
//  Created by Woudini on 12/15/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "SKTTruckMakerView.h"
#import <QuartzCore/QuartzCore.h>

@interface SKTTruckMakerView ()

@end

@implementation SKTTruckMakerView
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

- (void)drawRect:(CGRect)aRect {
    // NSLog(@"drawRect called");
    CGFloat width = self.bounds.size.width; //width of the screen
    CGFloat height = self.bounds.size.height; //height of the screen
    
    CGFloat scaleFactor = [self scaleFactorForDevice];
    
        UIBezierPath *path = [[UIBezierPath alloc] init];
    
        // top left corner
        CGPoint a = CGPointMake(width/2-140*scaleFactor, height/2-40*scaleFactor);
    
        // top axle
        CGPoint b = CGPointMake(width/2+140*scaleFactor,a.y);
    
        // axle diameter, right side
        CGPoint c = CGPointMake(b.x,b.y+20*scaleFactor);
    
        // starting arc towards pivot cup
        CGPoint d = CGPointMake(b.x-50*scaleFactor,b.y+30*scaleFactor);
    
        // control point for arc towards pivot cup
        CGPoint e = CGPointMake(b.x-100*scaleFactor,b.y+43*scaleFactor);
    
        // point at pivot cup
        CGPoint f = CGPointMake(width/2+15*scaleFactor,b.y+65*scaleFactor);
    
        [path moveToPoint:a];
        [path addLineToPoint:b];
        [path addLineToPoint:c];
        [path addLineToPoint:d];
        [path addQuadCurveToPoint:f controlPoint:e];
        
        // !point at pivot cup
        [path addLineToPoint:CGPointMake(width/2-15*scaleFactor,f.y)];
    
        // !control point + arc towards pivot cup
        [path addQuadCurveToPoint:CGPointMake(width/2-90*scaleFactor,d.y) controlPoint:CGPointMake(width/2-40*scaleFactor,e.y)];
    
        // !starting arc towards pivot cup
        [path addLineToPoint:CGPointMake(width/2-140*scaleFactor,c.y)];
    
        // axle diameter, right side
        [path addLineToPoint:CGPointMake(width/2-140*scaleFactor,b.y)];
        [path closePath];
    
        // draw the path
        [[UIColor blackColor] setStroke];
        [path stroke];
        [path fillWithBlendMode:kCGBlendModeClear alpha:0];
    
        // baseplate
        UIBezierPath *path2 = [[UIBezierPath alloc] init];
    
        // baseplate length1
        CGPoint g = CGPointMake(width/2+25*scaleFactor,f.y);
    
        // baseplate height1
        CGPoint h = CGPointMake(g.x,g.y+10*scaleFactor);
    
        // baseplate length2
        CGPoint i = CGPointMake(g.x+70*scaleFactor,h.y+10*scaleFactor);
    
        // baseplate height2
        CGPoint j = CGPointMake(i.x,i.y+10*scaleFactor);
    
        // baseplate bottom
        CGPoint k = CGPointMake(width/2-90*scaleFactor,j.y);
    
        // !baseplate height2
        CGPoint l = CGPointMake(width/2-90*scaleFactor,i.y);
    
        // !baseplate length2
        CGPoint m = CGPointMake(width/2-25*scaleFactor,h.y);
    
        // !basepplate height1
        CGPoint n = CGPointMake(width/2-25*scaleFactor,g.y);
    
        [path2 moveToPoint:g];
        [path2 addLineToPoint:h];
        [path2 addLineToPoint:i];
        [path2 addLineToPoint:j];
        [path2 addLineToPoint:k];
        [path2 addLineToPoint:l];
        [path2 addLineToPoint:m];
        [path2 addLineToPoint:n];
        [path2 closePath];
        [path2 stroke];
        
        // Fill the area outside of the bezier path we created with white
        // [path fill] does not cover the outside area with white; image shows through outside of the shape
        [[UIColor whiteColor] setFill];
        UIRectFill(aRect);
    
        // Cut a hole in the shape of the path, revealing the image in DeckViewController
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut);
        [path fill];
        [path2 fill];
    
        // Redraw the paths, as they have been changed to white
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        [path stroke];
        [path2 stroke];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
