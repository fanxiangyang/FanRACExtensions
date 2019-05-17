# ReactiveCocoa+MVVM
主要介绍ReactiveCocoa的使用(适合入门选手查看)，对于新手来说，先会用，然后慢慢推敲原理，理解加灵活运用。本文借鉴了这篇不错的文章：[最快上手ReactiveCocoa](https://www.jianshu.com/p/87ef6720a096)引用了部分注释和说明
## 前言
说起MVC架构大家都比较熟悉，也是使用很难广，但是MVVM这个项目架构，搭配函数响应式的编程，会变得更加如鱼得水，写出的项目也是很具特点，符合`高内聚，低耦合`的思想。本博客将主要通过[Github:FanRACExtensions](https://github.com/fanxiangyang/FanRACExtensions)项目来练习MVVM框架的[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)响应式编程，并且给出一些RAC的扩展。


## 1.ReactiveCocoa+MVVM简介
####1.1ReactiveCocoa简介
ReactiveCocoa（简称为RAC）,是Github上开源的一个iOS和OS平台新框架,该项目是函数响应式编程，借助大量KVO，KVC的绑定，这种设计思路代码可观性强，目前GitHub上有很多这种成熟框架。

* [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 	— 被重写swift版本。
* [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)		— 纯swift版本。
* [ReactiveObjCBridge](https://github.com/ReactiveCocoa/ReactiveObjCBridge)		— OC桥接版本。
* [ReactiveObjC](https://github.com/ReactiveCocoa/ReactiveObjC/)		— 纯Object-C版本。

####1.2什么是MVVM?
MVVM想对应于MVC，实质上没有本质区别，但是MVVM比MVC架构中多了一个ViewModel，就是这个ViewModel，却是MVVM相对于MVC改进的核心思想。在开发过程中，由于需求的变更或添加，项目的复杂度越来越高，代码量越来越大，此时我们会发现MVC维护起来有些吃力，所以有人想到把Controller的数据和逻辑处理部分从中抽离出来，用一个专门的对象去管理，这个对象就是ViewModel，是Model和Controller之间的一座桥梁。这样Controller中的代码变得非常少，变得易于测试和维护，只需要Controller和ViewModel做数据绑定即可，可是在实际使用过程中，MVVM写出的代码量并不比MVC的少，有时反而还会多点，毕竟多了一个数据绑定过程，但逻辑会清晰很多，对于多人开发的团队。

## 2.ReactiveCocoa使用和说明
学习ReactiveCocoa之前，首先要搞懂几个常用的类`RACSiganl`,`RACSubscriber`,`RACDisposable`,`RACCommand`等下面我们一一介绍
####2.1 RACSiganl创建于与使用
RACSignal的核心就是，创建信号`createSignal`,发送信号`sendNext`,完成信号`sendCompleted`，和销毁信号`[RACDisposable disposableWithBlock:^{ }];`,订阅信号`subscribeNext`.
```
//信号量创建
RACSignal *siganl=[[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    sleep(2);
    //sendNext通过信号量发送值，传值（可以是异步）订阅后能接受该值
    [subscriber sendNext:@{@"userName":"username",@"password":"123456"}];
    //报告信息执行完成，类似于回调完成一样
    [subscriber sendCompleted];
    
    return [RACDisposable disposableWithBlock:^{
            //block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
    }];
}]map:^id _Nullable(id  _Nullable value) {
    return value;
}] logError] replayLazily]; 

// 订阅信号,才会激活信号,只有发送了sendNext方法才会调用该订阅方法
[siganl subscribeNext:^(id x) {
    // block调用时刻：每当有信号发出数据，就会调用block.
    NSLog(@"接收到数据:%@",x);
}];
```
* `RACSubscriber`:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
* `RACDisposable`:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。在使用中如果不想监听某个信号时，可以通过它主动取消订阅信号。

* `RACSubject`:信号提供者，自己可以充当信号，又能发送信号,可以充当代理。

* `RACTuple`和`RACTupleUnpack`类似于数组，元组，集合，可以处理信号返回的数据

####2.2 RACSiganl其他方法及含义
因为RAC封装的原理是，一切皆信号，所以信号的其他方法也可以一并了解下
```
//map数据整合（纯数据），flattenMap数据过滤（内部返回的是信号）
[single map:^id _Nullable(RACTuple * value) {
        //这里可以过滤数据(RACTuple表示返回数据元组)
        RACTupleUnpack(id response,id responseObject)=value;
        //本来两个参数返回，传给下一层就一个参数
        return responseObject;
    }]flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        //过滤错误数据
        if ([value isKindOfClass:[NSError class]]) {
            return [RACSignal error:value];
        }
        return [RACSignal return:value];
    }]

```
* `map` 纯数据组合,返回数据
* `filter` 数据过滤，返回@(YES)or @(NO)
* `flattenMap` 过滤和返回数据信号量，错误信号和完成信号
* `ignore` 忽略掉什么样的数据一般配合filter使用
* `skip` 一般订阅消息，会默认执行一次初始化的操作，`[single skip:1]`跳过第一次
* `merge` 合并两个信号到一个信号上
## 3.RACCommand使用和说明
学习RACCommand之前，我们通过我这个例子简单来说，就是登录用户名和密码，这里面就用到了ViewModel了，即数据的绑定。首先我要知道几个概念或者宏。
* `@weakify(self);`=类似于弱引用 ，`@strongify(self);`=强引用，一般放block块里面；
* `RAC(<#TARGET, ...#>)`用来绑定UI的文本或属性值到viewModel里面对应的属性上(可以理解成KVC绑定)；
* `RACObserve(TARGET, KEYPATH)`订阅一个值信号，可以在viewmodel也可在VC里(可以理解成KVO监听)；
#### 3.1 使用步骤：
```
// 一、RACCommand使用步骤:
// 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
// 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
// 3.执行命令 - (RACSignal *)execute:(id)input

// 二、RACCommand使用注意:
// 1.signalBlock必须要返回一个信号，不能传nil.
// 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
// 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
// 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。

// 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
// 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
// 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。

// 四、如何拿到RACCommand中返回信号发出的数据。
// 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
// 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
// 3.还可以订阅errors信号，和executing信号，来获取错误信息和执行状态改变

// 五、监听当前命令是否正在执行executing

// 六、使用场景,监听按钮点击，网络请求

```

#### 3.2点击登录按钮VC文件
VC头属性
```
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property(nonatomic,strong)FanLoginViewModel *loginViewModel;

```
VC m文件里面可以简化成
```
{
    self.userNameTextField.text=@"18611723209";
    self.passwordTextField.text=@"123456fan";
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
        //这里可以改变原数据(直接修改输入框里面的值，返回)
        return value;
    }] subscribeNext:^(id  _Nullable x) {
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
    //这个错误也可以提到ViewModel里面，简化vc代码
    [[RACObserve(self.loginViewModel, error) ignore:nil] subscribeNext:^(id x) {
    //  @strongify(self);
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
```
#### 3.3 ViewModel实现
FanLoginViewModel.h
```
@interface FanLoginViewModel : FanRACViewModel
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) RACCommand *listCommand;
@property (nonatomic, strong) RACCommand *loginCommand;
/**
 *  错误
 */
@property (nonatomic, strong) NSError *error;
/**
 *  是否正在执行
 */
@property (nonatomic, strong) NSNumber *executing;
//网络请求接口的处理后的字典数据
@property (nonatomic, strong) NSMutableDictionary *modelDic;
@end
```
FanLoginViewModel.m
```

#import "FanLoginViewModel.h"
#import "FanAPIManager.h"

@interface FanLoginViewModel()

@property (nonatomic, strong) FanAPIManager *apiManager;
@end

@implementation FanLoginViewModel

- (instancetype)init{
    if((self = [super init])) {
        //初始化网络请求类
        self.apiManager=[[FanAPIManager alloc]init];
    }
    return self;
}

-(RACCommand *)loginCommand{
    if (_loginCommand==nil) {
        @weakify(self);
        _loginCommand=[[RACCommand alloc]initWithEnabled:[RACSignal combineLatest:@[RACObserve(self, userName), RACObserve(self, password)] reduce:^id (NSString *userName, NSString *password){
            //校验输入规则，同时会绑定按钮的enable属性(这里可以对输入校验)
            //这里可以用正则表达式  
            return @(YES);
        }] signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            //2.网络请求得到结果
            ShowHUDIMPMessage(@"加载中");
            @strongify(self);
            return [self.apiManager loginWithUserName:self.userName isEmail:NO countryCode:@"86" password:self.password];
        }] ;
        //concat: 连接信号,第一个信号必须发送完成，第二个信号才会被激活
        // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
        // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
        //把网络请求的信号的数据合并到这个输出里面
        [[_loginCommand.executionSignals concat] subscribeNext:^(id  _Nullable x) {
            //3.订阅结果
            @strongify(self);
            self.modelDic = x;
        }];
        // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
//        [_loginCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
//
//        }];
        [_loginCommand.errors subscribeNext:^(NSError * _Nullable x) {
            //4.订阅错误信息
            @strongify(self);
            self.error = x;
            //下面这个是我测试打印的消息，因为拿到的是二进制，后台的崩溃数据，不是正常的error
            NSData *errorData=self.error.userInfo[FanRACAFNErrorKey];
            NSString *resultStr=[[NSString alloc]initWithData:errorData encoding:NSUTF8StringEncoding];
            if (resultStr==nil) {
                resultStr=@"data->UTF8 = null";
            }
            NSLog(@"error:%@",resultStr);
        }];
        
        [_loginCommand.executing  subscribeNext:^(NSNumber * _Nullable x) {
            //订阅执行的状态
            @strongify(self);
            //如果VC文件里面订阅了这个值，就能拿到这个值的状态信息，做出不同的UI展示
            self.executing = x;
            if ([self.executing boolValue]) {
                HideHUDAll;
            }
        }];
         
    }
    return _loginCommand;
}

@end
```
#### 3.4 AFHTTPSessionManager+FanRACExtension 扩展实现
我把`AFHTTPSessionManager`这个类写了一个信号的扩展，以前有个pod库，但是很旧了，仿写了一个最新的，主要目的就是使用信号量可以从UI绑定到网络请求，全部弄成RAC框架模式，当然，其他的第三方库，你也可以仿照写一个信号量。
```
extern NSString *const FanRACAFNErrorKey;

@interface AFHTTPSessionManager (FanRACExtension)
///GET
-(RACSignal*)fan_racGET:(NSString *)URLString parameters:(nullable id)parameters;
///GET-Headers
-(RACSignal*)fan_racGET:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///HEAD
-(RACSignal*)fan_racHEAD:(NSString *)URLString parameters:(nullable id)parameters;
///HEAD-Headers
-(RACSignal*)fan_racHEAD:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///POST
-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters;
///POST-Headers
-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///PUT
-(RACSignal*)fan_racPUT:(NSString *)URLString parameters:(nullable id)parameters;
///PUT-Headers
-(RACSignal*)fan_racPUT:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///PATH
-(RACSignal*)fan_racPATCH:(NSString *)URLString parameters:(nullable id)parameters;
///PATH-Headers
-(RACSignal*)fan_racPATCH:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///DELETE
-(RACSignal*)fan_racDELETE:(NSString *)URLString parameters:(nullable id)parameters;
///DELETE-Headers
-(RACSignal*)fan_racDELETE:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

///GET-POST-PUT等等-通用方法
- (RACSignal *)fan_racWithHTTPMethod:(NSString *)method
                           URLString:(NSString *)URLString
                          parameters:(nullable id)parameters
                             headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                      uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                    downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress;


///POST-Headers-Upload File(上传文件)
-(RACSignal*)fan_racPOST:(NSString *)URLString parameters:(nullable id)parameters headers:(nullable NSDictionary<NSString *,NSString *> *)headers constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block progress:(void (^)(NSProgress * _Nonnull))uploadProgress;

```
m文件可以在源码里面查看
#### 3.5 ReactiveCocoa其他注意点和方法
我们知道`RACCommand`主要用于按钮绑定事件,那么其他的UIKit常用框架都被RAC封装了一遍，都有我们需要常用的信号量，使用起来可以通过一个按钮，和文本框，逐渐，由浅入深，深入了解ReactiveCocoa的强大，和他的响应式设计理念，及配合MVVM框架使用方法
* `FanAPIManager`可以看下这个类封装，就是一个基本网络库的封装，可以继承他，实现比如分模块处理，用户登录，其他模块，可以把网络请求数据解析的动作封装进入，用户信号订阅的直接是需要的数据，或者需要的错误数据（当然需要后台配合写一条完善的接口，不然乱七八糟，不容易封装）
* `rac_signalForSelector`：用于替代代理。
* `rac_valuesAndChangesForKeyPath`：用于监听某个对象的属性改变。
* `rac_signalForControlEvents`：用于监听某个事件。
* `rac_addObserverForName`:用于监听某个通知。
* `rac_textSignal`:只要文本框发出改变就会发出这个信号。
* `rac_liftSelector:withSignalsFromArray:Signals`:当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法。
使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。


更新历史(Version Update)
==============
### Release 0.0.1
* 通过简单的用户登录接口实现 网络信号封装，VM封装

Like(喜欢)
==============
#### 有问题请直接在文章下面留言,喜欢就给个Star(小星星)吧！ 
#### Email:fqsyfan@gmail.com
