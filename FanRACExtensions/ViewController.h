//
//  ViewController.h
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/13.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FanLoginViewModel.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;



@property(nonatomic,strong)FanLoginViewModel *loginViewModel;


@end

