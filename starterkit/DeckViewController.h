//
//  DeckViewController.h
//  starterkit
//
//  Created by Woudini on 11/26/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeckMakerView.h"
#import "TruckMakerView.h"
#import "WheelMakerView.h"
#import "TeeMakerView.h"
#import "ViewController.h"
#import "OMMTouchableView.h"
typedef void (^PassUndoMethodFromTouchDrawViewBlock)();
@interface DeckViewController : UIViewController
@property (nonatomic, weak) NSString *editorString;
@property (nonatomic, copy) PassUndoMethodFromTouchDrawViewBlock passUndoMethodBlock;
@end
