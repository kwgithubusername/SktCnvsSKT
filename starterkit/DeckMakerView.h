//
//  DeckMaker.h
//  starterkit
//
//  Created by Woudini on 12/1/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeckViewController.h"
#import <iAd/iAd.h>
@interface DeckMakerView : UIView <ADBannerViewDelegate>
@property (nonatomic) CGRect imageCaptureRect;
@end
