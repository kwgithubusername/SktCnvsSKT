//
//  OMMColouredPath.h
//  TouchDraw
//
//  Created by Tyler Bindon on 12-04-15.
//  Copyright (c) 2012 Martica.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMMColouredPath : NSObject

@property (strong,nonatomic) UIColor *colour;
@property (strong,nonatomic) UIBezierPath *path;

- (void)draw;

@end
