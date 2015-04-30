//
//  ViewController.m
//  starterkit
//
//  Created by Woudini on 11/26/14.
//  Copyright (c) 2014 Hi Range. All rights reserved.
//

#import "SKTMenuViewController.h"
#import "SKTEditorViewController.h"


@interface SKTMenuViewController ()

@end

// TO DO:
// Stop spinner if no camera available - done
// REDO DECK SHAPE- MAKE EACH CORNER THE SAME ARC - done
// MAKE BARS FADE IN AND OUT ON TOUCH - attempted
// FIX SHADOWS - attempted and abandoned for now
// ENABLE SIMULTANEOUS CAMERA ROLL AND IMAGE CAPTURE - now alternating

@implementation SKTMenuViewController

-(NSSet *)editorNameStringsSet
{
    return [[NSSet alloc] initWithObjects:@"deck",@"truck",@"wheel",@"tee", nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SKTEditorViewController class]])
    {
        if ([[self editorNameStringsSet] containsObject:segue.identifier])
        {
            SKTEditorViewController *dvc = (SKTEditorViewController *)segue.destinationViewController;
            dvc.editorString = segue.identifier;
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
