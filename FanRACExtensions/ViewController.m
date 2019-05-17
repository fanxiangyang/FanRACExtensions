//
//  ViewController.m
//  FanRACExtensions
//
//  Created by 向阳凡 on 2019/3/13.
//  Copyright © 2019 向阳凡. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <SBJson/SBJson5.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.userNameTextField.text=@"18611723209";
    self.passwordTextField.text=@"123456fan";
    self.view.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
    self.loginViewModel=[[FanLoginViewModel alloc]init];
    @weakify(self);
    //输入框文字改变添加订阅信息
//    [self.userNameTextField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
//        NSLog(@"=====:%@",x);
//    }];
   
   //把文本信号绑定到ViewModel里面的userName属性上
    RAC(self.loginViewModel,userName)=self.userNameTextField.rac_textSignal;
    RAC(self.loginViewModel,password)=self.passwordTextField.rac_textSignal;
    
    //订阅username改变（可以直接放在loginViewModel里面解决）
    [[[[RACObserve(self.loginViewModel, userName) ignore:nil]filter:^BOOL(id  _Nullable value) {
        //filter过滤 ignore忽略掉为""的字符串
        return [value length]>0;//长度大于0开始执行
    }] map:^id _Nullable(id  _Nullable value) {
        //这里可以改变原数据
        return value;
    }] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"=====:%@",x);
        //值改变的订阅 类似于rac_textSignal信号订阅一样
    }];
    //按钮信号绑定到ViewModel的两个信号上，便于在ViewModel里面操作
    self.listButton.rac_command=self.loginViewModel.listCommand;
    self.loginButton.rac_command=self.loginViewModel.loginCommand;
    
    //当用户名长度>0时，数据信号绑定到按钮的enable属性上  merge合并信号
//    RAC(self.loginButton,enabled) =[[RACObserve(self.userNameTextField, text)  merge:self.userNameTextField.rac_textSignal ] map:^id(NSString *value) {
//        return @(value.length>0);
//    }];
    
    //需要确保loginViewModel初始化，不然就没有信号
    //订阅方式一：rac_liftSelector会自动线执行一次  skip跳过第一次默认的执行
    [self rac_liftSelector:@selector(toggleHUD:) withSignals:[RACObserve(self.loginViewModel, executing) skip:1], nil];
    //订阅方式二：
    [self rac_liftSelector:@selector(showMessage:) withSignals:[[RACObserve(self.loginViewModel, error) ignore:nil] map:^id (id value) {
        return [value localizedDescription];
    }], nil];

    [[RACObserve(self.loginViewModel, modelDic) ignore:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self showMessage:@"登录成功"];
        //跳转到
        NSLog(@"登录结果：%@",x);
        
        NSDictionary *dic=(NSDictionary *)x;
        NSString *session=dic[@"data"][@"PHPSESSID"];
        [FanAppManager shareManager].phpsession=session;
    }];
    [[RACObserve(self.loginViewModel, error) ignore:nil] subscribeNext:^(id x) {
//        @strongify(self);
        NSLog(@"error:%@",x);
    }];
}
-(void)toggleHUD:(NSNumber *)state{
    if ([state boolValue]) {
        [self showMessage:@"正在执行"];
    }else{
        [self showMessage:@"执行完毕"];
    }
}

-(void)showMessage:(NSString *)msg{
    NSLog(@"msg:%@",msg);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    self.loginViewModel.running=YES;
//    self.loginViewModel.executing=@(YES);
}


@end
