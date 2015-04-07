//
//  HWGOptionsColorToStore.h
//  StudyAid
//
//  Created by Woudini on 1/7/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWGOptionsColorToStore : NSObject <NSCoding>

-(instancetype)init;
-(void)saveColor:(UIColor *)color;
-(UIColor *)loadColor;

@end
