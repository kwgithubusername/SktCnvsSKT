//
//  TouchDrawView.m
//  starterkit
//
//  Created by Woudini on 12/17/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "TouchDrawView.h"
#import "Line.h"
@interface TouchDrawView ()
@property (strong, nonatomic) UIBezierPath *path;
//@property CGPoint beginningPointofLastStroke;
//@property CGPoint lastPointOfLastStroke;
@property NSMutableArray *pathArray;
@end

@implementation TouchDrawView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //linesInProcess = [[NSMutableDictionary alloc] init];
        //completeLines = [[NSMutableArray alloc] init];
        self.pathArray = [[NSMutableArray alloc] init];
        self.path = [[UIBezierPath alloc]init];
        self.BackgroundColor = [UIColor clearColor];
            NSLog(@"gets called");
        self.userInteractionEnabled = YES;
       // [self setMultipleTouchEnabled:YES]; // Not sure if I want to do this yet
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.drawingEnabled)
    {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        [self.path moveToPoint:[touch locationInView:self]];
        [self setNeedsDisplay];
        //self.beginningPointofLastStroke = [touch locationInView:self];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.drawingEnabled)
    {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        [self.path addLineToPoint:[touch locationInView:self]];
        [self setNeedsDisplay];
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.drawingEnabled)
    {
    [self touchesMoved:touches withEvent:event];
    //UITouch *touch = [[touches allObjects] objectAtIndex:0];
    //self.lastPointOfLastStroke = [touch locationInView:self];
    UIBezierPath *instanceOfLastPath = self.path;
    [self.pathArray addObject:instanceOfLastPath];
    //NSLog(@"Number of paths:%d", [self.pathArray count]);
        
        
    if (self.deckViewControllerProperty.passUndoMethodBlock)
    {TouchDrawView __weak *weakSelf = self;
            [self.deckViewControllerProperty setPassUndoMethodBlock:^{
                if ([weakSelf.pathArray count])
                {
                    if([[weakSelf.pathArray objectAtIndex:[weakSelf.pathArray count]-1] isMemberOfClass:[UIBezierPath class]])
                    {
                        [weakSelf.pathArray removeObject:[weakSelf.pathArray objectAtIndex:[weakSelf.pathArray count]-1]];
                        [weakSelf undo];
                    }
                    
                }
            }];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.drawingEnabled)
    {
        [self touchesMoved:touches withEvent:event];
    }
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    [[UIColor blackColor] setStroke];
    [self.path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];

}

-(void)undo
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    [[UIColor blackColor] setStroke];
    for (UIBezierPath *path in self.pathArray)
    {
    [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
}


/*
 
 self.drawImage = [[UIImageView alloc] initWithFrame:self.frame];
 [self.drawImage setBackgroundColor:[UIColor clearColor]];
 [self.drawImage setUserInteractionEnabled:YES];
 [self addSubview:self.drawImage];
 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint p = [touch locationInView:self.drawImage];
    self.startPoint = p;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved");
    UITouch *touch = [[[touches allObjects] objectAtIndex:0];
    CGPoint p = [touch locationInView:self.drawImage];
    [self drawLineFrom:self.startPoint endPoint:p];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

-(void)drawLineFrom:(CGPoint)from endPoint:(CGPoint)to
{
    self.drawImage.image = [UIImage imageNamed:@""];
    UIGraphicsBeginImageContext(self.bounds.size);
    //[self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    
    [self.drawImage.image drawInRect:CGRectMake(0, 0, self.drawImage.frame.size.width, self.drawImage.frame.size.height)];
    NSLog(@"width %f, height %f", self.drawImage.frame.size.width, self.drawImage.frame.size.height);
    [[UIColor blackColor] set];
    
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0f);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), from.x, from.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), to.x , to.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    UIGraphicsEndImageContext();
}

*/

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // Draw complete lines in black
    [[UIColor blackColor] set];
    for (Line *line in completeLines)
    {
        CGContextMoveToPoint(context, line.begin.x, line.begin.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        CGContextStrokePath(context);
    }
    
    // Draw lines in the process in red
    [[UIColor redColor] set];
    for (NSValue *v in linesInProcess)
    {
        Line *line = [linesInProcess objectForKey:v];
        CGContextMoveToPoint(context, line.begin.x, line.begin.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        CGContextStrokePath(context);
    }
    
}

-(void)clearAll
{
    // Clear the collections
    [linesInProcess removeAllObjects];
    [completeLines removeAllObjects];
    
    // Redraw
    [self setNeedsDisplay];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
    {
        // Is this a double tap?
        if ([t tapCount] > 1)
        {
            [self clearAll];
            return;
        }
    
    NSValue *key = [NSValue valueWithNonretainedObject:t];
    
    // Create a line for the value
        CGPoint loc = [t locationInView:self];
        Line *newLine = [[Line alloc] init];
        newLine.begin = loc;
        newLine.end = loc;
        
    // Put pair in dictionary
        [linesInProcess setObject:newLine forKey:key];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Update linesInProcess with moved touches
    for (UITouch *t in touches)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        // Find the line for this touch
        Line *line = [linesInProcess objectForKey:key];
        
        // Update the line
        CGPoint loc = [t locationInView:self];
        line.end = loc;
    }
    // Redraw
    [self setNeedsDisplay];
}

-(void)endTouches:(NSSet *)touches
{
    // Remove ending touches from dictionary
    for (UITouch *t in touches)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = [linesInProcess objectForKey:key];
        
        // If this is a double tap, 'line' will be nil, so make sure not to add it to the array
        if (line)
        {
            [completeLines addObject:line];
            [linesInProcess removeObjectForKey:key];
        }
    }
    // Redraw
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}
 */
@end
