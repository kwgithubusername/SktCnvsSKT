//
//  DeckViewController.h
//  starterkit
//
//  Created by Woudini on 11/26/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKTDeckMakerView.h"
#import "SKTTruckMakerView.h"
#import "SKTWheelMakerView.h"
#import "SKTTeeMakerView.h"
#import "SKTMenuViewController.h"
typedef void (^PassUndoMethodFromTouchDrawViewBlock)();
@interface SKTEditorViewController : UIViewController <ADBannerViewDelegate>
@property (nonatomic, weak) NSString *editorString;
@property (nonatomic, copy) PassUndoMethodFromTouchDrawViewBlock passUndoMethodBlock;
@end
