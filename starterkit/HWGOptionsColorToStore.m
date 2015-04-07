//
//  HWGOptionsColorToStore.m
//  StudyAid
//
//  Created by Woudini on 1/7/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "HWGOptionsColorToStore.h"
@interface HWGOptionsColorToStore ()
@property (nonatomic) UIColor *color;
@end
@implementation HWGOptionsColorToStore

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.color = [aDecoder decodeObjectForKey:@"color"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.color forKey:@"color"];
}

-(void)saveColor:(UIColor *)color
{
    self.color = color;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"color"];
}

-(UIColor *)loadColor
{
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    NSData *colorData = [userDefaults objectForKey:@"color"];
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    return color;
}

@end
