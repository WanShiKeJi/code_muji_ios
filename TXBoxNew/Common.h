


// 1.判断是否为iPhone5
#define iPhone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iPhone4s ([UIScreen mainScreen].bounds.size.height == 480)

//2.dock（Tabbar） 高度
#define kDockHeight 49
#define TXNavigationHeight 44
//3.通知
#define ktextChangeNotify @"textChangeNotification"//输入文本时，显示callBtn
#define kCallingBtnClick @"callingBtnClick"     //点击callBtn
#define kCustomKeyboardHide @"customKeyboardHide"//自定键盘隐藏
#define kKeyboardAndTabViewHide @"keyboardAndTabBarHide"//自定键盘、callBtn,tabbar隐藏
#define kHideCusotomTabBar @"hideCustomTabBar"//隐藏自定tabbar
#define kShowCusotomTabBar @"showCustomTabBar"//显示自定tabbar
#define kShowAddContacts @"showAddContacts" //显示add联系人界面
#define kShowValueToMsgDetail @"showValue"

//4.键盘高宽
#define keyWidth DEVICE_WIDTH/3.f
#define keyHight keyWidth/2.f

//5.颜色
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)/1.f]

//6.设备版本
#define IOS_DEVICE_VERSION [[UIDevice currentDevice].systemVersion floatValue]

//7设备宽度,高度
#define DEVICE_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define DEVICE_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//8.字符串-文件名
#define HistoryRecords @"HistoryRecords"

//9.字符串-数据库名
#define DB_NAME @"txbox.sqlite"

//10.表名
#define CALL_RECORDS_TABLE_NAME @"CALL_RECORDS"

//11.首页输入框的view
#define InputBoxView 50.f

//12.searchBar高度
#define kSearchH 44.f

//13.表格高度
#define kCellHeight   40.0f

//14.cell中图标width
#define cellIconWidth 320/3.f

//15.slider的宽高
#define SliderHeight 5
#define SliderWidth 200

//16.号码归属地的网址
#define TelNumAddress @"http://virtual.paipai.com/extinfo/GetMobileProductInfo?mobile=%@&amount=10000&callname=getPhoneNumInfoExtCallback"

//17.其它
#define OtherNumber NSLocalizedString(@"Other", nil)

//18.状态栏高度 默认20
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

//tabBar高度 默认49
#define  TabBarHeight self.tabBarController.tabBar.frame.size.height
//导航栏高度 默认44
#define NaviBarHeight self.navigationController.navigationBar.frame.size.height

//邮箱和拇机号码
#define email_number @"e_mail_number"
#define muji_bind_number @"muji_bind_number"
//呼转状态
#define call_divert @"call_divert"
//window窗口
#define WINDOW  [[UIApplication sharedApplication]keyWindow]

