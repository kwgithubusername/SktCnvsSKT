//
//  ViewController.m
//  starterkit
//
//  Created by Woudini on 11/26/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "ViewController.h"
#import "DeckViewController.h"
@interface ViewController ()

@end

// TO DO:
// Stop spinner if no camera available - done
// REDO DECK SHAPE- MAKE EACH CORNER THE SAME ARC - done
// MAKE BARS FADE IN AND OUT ON TOUCH - attempted
// FIX SHADOWS - attempted and abandoned for now
// ENABLE SIMULTANEOUS CAMERA ROLL AND IMAGE CAPTURE - now alternating

@implementation ViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[DeckViewController class]])
    {
        if ([segue.identifier isEqualToString: @"deckEditor"])
        {
            DeckViewController *dvc = (DeckViewController *)segue.destinationViewController;
            dvc.editorString = @"deck";
            NSLog(@"deck selected");
            
        }
        if ([segue.identifier isEqualToString:@"truckEditor"])
        {
            DeckViewController *dvc = (DeckViewController *)segue.destinationViewController;
            dvc.editorString = @"truck";
            NSLog(@"truck selected");
            
        }
        if ([segue.identifier isEqualToString:@"wheelEditor"])
        {
            DeckViewController *dvc = (DeckViewController *)segue.destinationViewController;
            dvc.editorString = @"wheel";
            NSLog(@"wheel selected");
            
        }
        if ([segue.identifier isEqualToString:@"teeEditor"])
        {
            DeckViewController *dvc = (DeckViewController *)segue.destinationViewController;
            dvc.editorString = @"tee";
            NSLog(@"tee selected");
            
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *backgroundImage = [UIImage imageNamed:@"warehouse.jpg"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundImageView.image=backgroundImage;
 [self.view insertSubview:backgroundImageView atIndex:0];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
