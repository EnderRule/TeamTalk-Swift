//
//  DDMTTLoginViewController.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "MTTLoginViewController.h"

#import "TeamTalk_Swift-Swift.h"


@interface MTTLoginViewController ()<UITextFieldDelegate>

@property(assign)CGPoint defaultCenter;

@property (nonatomic,weak)IBOutlet UITextField* userNameTextField;
@property (nonatomic,weak)IBOutlet UITextField* userPassTextField;
@property (nonatomic,weak)IBOutlet UIButton* userLoginBtn;
@property(assign)BOOL isRelogin;

@end

@implementation MTTLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWillShowKeyboard)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWillHideKeyboard)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    if ( [HMLoginManager shared].currentUserName.length > 0) {
        _userNameTextField.text = [HMLoginManager shared].currentUserName;
    }
    if ( [HMLoginManager shared].currentPassword.length > 0) {
        _userPassTextField.text= [HMLoginManager shared].currentPassword;
    }
    if (!self.isRelogin
            && _userNameTextField.text.length > 0
            && _userPassTextField.text.length > 0
            && [HMLoginManager shared].shouldAutoLogin ){
        [self loginButtonPressed:nil];
    }
    
    self.defaultCenter=self.view.center;
    self.userNameTextField.leftViewMode=UITextFieldViewModeAlways;
    self.userPassTextField.leftViewMode=UITextFieldViewModeAlways;
    
    UIImageView *usernameLeftView = [[UIImageView alloc] init];
    usernameLeftView.contentMode = UIViewContentModeCenter;
    usernameLeftView.frame=CGRectMake(0, 0, 18, 22.5);
    UIImageView *pwdLeftView = [[UIImageView alloc] init];
    pwdLeftView.contentMode = UIViewContentModeCenter;
    pwdLeftView.frame=CGRectMake(0, 0,18, 22.5);
    self.userNameTextField.leftView=usernameLeftView;
    self.userPassTextField.leftView=pwdLeftView;
    
//    UIColor *borderColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1];
    UIColor *borderColor = [[UIColor alloc]initWithIntr:211 g:211 b:211 a:1 ];
    [self.userNameTextField.layer setBorderColor:borderColor.CGColor];
    [self.userNameTextField.layer setBorderWidth:0.5];
    [self.userNameTextField.layer setCornerRadius:4];
    [self.userPassTextField.layer setBorderColor:borderColor.CGColor];
    [self.userPassTextField.layer setBorderWidth:0.5];
    [self.userPassTextField.layer setCornerRadius:4];
    
    [self.userLoginBtn.layer setCornerRadius:4];
    
    // 设置用户名
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden =YES;
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    self.defaultCenter=self.view.center;
}

#pragma mark - keyboard hide and show notification

-(void)handleWillShowKeyboard
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center=CGPointMake(self.view.center.x, self.defaultCenter.y-120);
    }];
}
-(void)handleWillHideKeyboard
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center=self.defaultCenter;
    }];
}


#pragma mark - button pressed

-(IBAction)hiddenKeyboard:(id)sender
{
    [_userNameTextField resignFirstResponder];
    [_userPassTextField resignFirstResponder];
}


- (IBAction)loginButtonPressed:(UIButton*)button{
    
    [self.userLoginBtn setEnabled:NO];
    NSString* userName = _userNameTextField.text ;
    NSString* password = _userPassTextField.text ;
    if (userName.length ==0 || password.length == 0) {
        [self.userLoginBtn setEnabled:YES];
        return;
    }
 
    [self.view makeToastActivity:self.view.center];
    
    
    [[HMLoginManager shared]loginWithUserName:userName password:password success:^(MTTUserEntity * _Nonnull user ) {
        NSLog(@"login success:\nid:%@ \nname:%@ \navatar:%@",user.userId,user.name ,user.avatar);
        [self.userLoginBtn setEnabled:YES];
        [self loginSuccessHandler];
    } failure:^(NSString * _Nonnull error ) {
        [self.userLoginBtn setEnabled:YES];
        NSLog(@"login error %@",error);
        UILabel *errorlabel = [[UILabel alloc]init];
        errorlabel.text = error;
        errorlabel.contentMode = UIViewContentModeCenter;
        [errorlabel sizeToFit];
        
        [self.view showToast:errorlabel duration:3 point:self.view.center completion:^(BOOL ss) {
            
        }];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self loginButtonPressed:nil];
    
    return YES;
}

-(void)loginSuccessHandler{
    UITabBarController *maintabbar = [[UITabBarController alloc]init];
    UINavigationController *recentsnavi = [[UINavigationController alloc]initWithRootViewController:[[HMRecentSessionsViewController alloc]init]];
    UINavigationController *contactsNavi = [[UINavigationController alloc]initWithRootViewController:[[HMContactsViewController alloc]init]];
    UINavigationController *centerNavi = [[UINavigationController alloc]initWithRootViewController: [[HMPersonCenterViewController alloc]init]];
    
    
    UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:@"消息" image:[UIImage imageNamed:@"conversation"] selectedImage:[UIImage imageNamed:@"conversation_selected"]];
    UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:@"联系人" image:[UIImage imageNamed:@"contact"] selectedImage:[UIImage imageNamed:@"contact_selected"]];
    UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:@"我" image:[UIImage imageNamed:@"myprofile"] selectedImage:[UIImage imageNamed:@"myprofile_selected"]];

    recentsnavi.tabBarItem = item1;
    contactsNavi.tabBarItem = item2;
    centerNavi.tabBarItem = item3;
    
    [maintabbar setViewControllers:@[recentsnavi,contactsNavi,centerNavi]];
    
    [self.navigationController pushViewController:maintabbar animated:true ];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self removeFromParentViewController];
    
//    HMRecentSessionsViewController *newvc = [[HMRecentSessionsViewController alloc]init];
//    newvc.hidesBottomBarWhenPushed = YES;
//    [self pushViewController:newvc animated:YES];
    
    //            [self pushViewController: [RecentUsersViewController shareInstance] animated:YES];
    
}

@end
