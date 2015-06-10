


// 判断是否为iPhone5
#define iPhone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iPhone4s ([UIScreen mainScreen].bounds.size.height == 480)

// dock（customTabbar） 高度
#define kDockHeight 49
#define TXNavigationHeight 44
// 通知
#define ktextChangeNotify @"textChangeNotification"//输入文本时，显示callBtn
#define kCallingBtnClick @"callingBtnClick"     //点击callBtn
#define kCustomKeyboardHide @"customKeyboardHide"//自定键盘隐藏
#define kKeyboardAndTabViewHide @"keyboardAndTabBarHide"//自定键盘、callBtn,tabbar隐藏
#define kHideCusotomTabBar @"hideCustomTabBar"//隐藏自定tabbar
#define kShowCusotomTabBar @"showCustomTabBar"//显示自定tabbar
#define kHideTabBarAndCallBtn @"hideTabBarAndCallBtn" //隐藏tabbar和callBtn
#define kShowValueToMsgDetail @"showValue"
#define KRefreshDisvView @"KrefreshDisvView"

#define kDeleteCharNoti @"deleteCharNoti"
#define kInputCharNoti @"inputCharNoti"

#define kCallViewReloadData @"callViewReloadData"
// custom键盘高宽
#define keyWidth DEVICE_WIDTH/3.f
#define keyHight keyWidth/3.f

// 颜色
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)/1.f]

// 设备版本
#define IOS_DEVICE_VERSION [[UIDevice currentDevice].systemVersion floatValue]

// 设备宽度,高度
#define DEVICE_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define DEVICE_HEIGHT ([UIScreen mainScreen].bounds.size.height)



// =================数据库==============//
#define DB_NAME @"txbox.sqlite"
#define DB_PHONE_AREAR_NAME @"PhoneArea.db"
#define SELECT_ALL_SQL @"select *from %@"


// =================通话记录表===========//
#define CALL_RECORDS_TABLE_NAME @"CALL_RECORDS"
//创建通话记录表的sql语句
#define CALL_RECORDS_CREATE_TABLE_SQL @"create table if not exists %@(tel_id integer primary key AUTOINCREMENT,hisName text,hisNumber text,callDirection text,callLength text,callBeginTime text,hisHome text,hisOperator text)"
//添加call——records
#define CALL_RECORDS_ADDINFO_SQL @"insert into %@(hisName ,hisNumber ,callDirection ,callLength,callBeginTime ,hisHome ,hisOperator ) values(?,?,?,?,?,?,?)"
//删除一条通话记录
#define DELETE_CALL_RECORD_SQL @"delete from %@ where hisNumber=%@"


//===================信息表=============//
#define MESSAGE_RECEIVE_RECORDS_TABLE_NAME @"MESSAGE_RECORDS"
//创建d短信记录表的sql语句
#define MESSAGE_RECEIVE_RECORDS_CREATE_TABLE_SQL  @"create table if not exists %@(peopleId integer primary key AUTOINCREMENT,msgSender text,msgTime text,msgContent text,msgAccepter text,msgState text)"
//添加msg记录
#define MESSAGE_RECORDS_ADDINFO_SQL @"insert into %@(msgSender,msgTime,msgContent,msgAccepter,msgState) values(?,?,?,?,?)"
//删除单条短信记录
#define DELETE_MESSAGE_RECORD_SQL @"delete from %@ where msgSender=%@ and peopleId = %@"
//删除整个短信会话
#define DELETE_MESSAGE_RECORD_CONVERSATION_SQL  @"delete from %@ where msgSender=%@ or msgAccepter = %@"

//查询某一次整个会话
#define SELECT_A_CONVERSATION_SQL @"select *from %@ where msgSender=%@ or msgAccepter = %@"
//查询某一次会话的最后一条
#define SELECT_A_LAST_MESSAGE_RECORDS @"select *from %@ where msgSender=%@ or msgAccepter=%@"

//查询所有短信联系人,不需要重复显示
#define SELECT_ALL_MSG_CONTACTER_SQL @"select msgAccepter from %@ "

//查询所有与输入匹配的短信内容
#define SELECT_ALL_COINTENT_FROM_MSG @"select *from %@ where msgSender LIKE '%@' or msgAccepter LIKE '%@' or msgContent LIKE '%@' "

//===================================//
// 首页输入框的view
#define InputBoxView 50.f

// searchBar高度
#define kSearchH 44.f

// 表格高度
#define kCellHeight   40.0f

// cell中图标width
#define cellIconWidth 320/3.f

// slider的宽高
#define SliderHeight 5
#define SliderWidth 200

// 其它
#define OtherNumber NSLocalizedString(@"Other", nil)

// 状态栏高度 默认20
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

// tabBar高度 默认49
#define  TabBarHeight self.tabBarController.tabBar.frame.size.height
// 导航栏高度 默认44
#define NaviBarHeight self.navigationController.navigationBar.frame.size.height

// 邮箱和拇机号码
#define email_number @"e_mail_number"
#define muji_bind_number @"muji_bind_number"
// 呼转状态
#define call_divert_state @"call_divert_state"
// window窗口
#define WINDOW  [[UIApplication sharedApplication]keyWindow]

#define PopViewHeight 140   //弹出框高度
#define PopViewWidth 0.9*DEVICE_WIDTH    //弹出框宽度

#define China_Mobile @"China Mobile"
#define China_Unicom @"China Unicom"
#define China_Telecom @"China Telecom"
#define China_TieTong @"China Tietong"




#define CallForwardStartTime @"CallForwardStartTime"
#define CallForwardEndTime @"CallForwardEndTime"
//登录状态
#define LOGIN_STATE @"loginState"
#define BIND_STATE @"bindState"
#define CONFIG_STATE @"configState"

#define CurrentUser @"currentUser"
