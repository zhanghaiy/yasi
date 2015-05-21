//
//  CheckSuccessViewController.m
//  oral
//
//  Created by cocim01 on 15/5/20.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "CheckSuccessViewController.h"
#import "TPCCheckpointViewController.h"
#import "CheckKeyWordViewController.h"
#import "CheckAskViewController.h"


@interface CheckSuccessViewController ()

@end

@implementation CheckSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)backToLastPage:(id)sender
{
    for (UIViewController *viewControllers in self.navigationController.viewControllers)
    {
        if ([viewControllers isKindOfClass:[TPCCheckpointViewController class]])
        {
            [self.navigationController popToViewController:viewControllers animated:YES];
            break;
        }
    }
}
- (IBAction)continueNextPoint:(id)sender
{
    if (_pointCount<=2)
    {
        CheckKeyWordViewController *keyVC = [[CheckKeyWordViewController alloc]initWithNibName:@"CheckKeyWordViewController" bundle:nil];
        keyVC.pointCounts = _pointCount;
        [self.navigationController pushViewController:keyVC animated:YES];
    }
    else
    {
        CheckAskViewController *askVC = [[CheckAskViewController alloc]initWithNibName:@"CheckAskViewController" bundle:nil];
        [self.navigationController pushViewController:askVC animated:YES];
    }
}
@end
