//
//  TouchDrawView.h
//  starterkit
//
//  Created by Woudini on 12/17/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeckViewController.h"
@class DeckViewController;
@interface TouchDrawView : UIView
@property BOOL drawingEnabled;
@property (nonatomic, strong) DeckViewController *deckViewControllerProperty;
/*{
    NSMutableDictionary *linesInProcess;
    NSMutableArray *completeLines;
}

-(void)clearAll;
-(void)endTouches:(NSSet *)touches;
*/

@end
