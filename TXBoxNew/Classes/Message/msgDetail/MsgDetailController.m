//
//  MsgDetailController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "MsgDetailController.h"
#import "Message.h"
#import "MsgFrame.h"
#import "MsgDetailCell.h"
#import "TXSqliteOperate.h"

@interface MsgDetailController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
{
    TXSqliteOperate *txsqlite;
}
@property (strong, nonatomic) NSMutableArray *detailArray;
@property (strong, nonatomic) NSMutableArray *allMsgFrame;

@property (nonatomic,strong) UILabel *nameLabel;//姓名
@property (nonatomic,strong) UILabel *arearLabel;//号码归属地

@property (weak, nonatomic) IBOutlet UIBarButtonItem *callBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *contactsInfoBtn;

- (IBAction)callBtn:(UIBarButtonItem *)sender;
- (IBAction)ContactsInfo:(UIBarButtonItem *)sender;

@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *resultArray;

@property (strong, nonatomic)  UIView *inputView;
@property (strong, nonatomic)  UIButton *sendMsgBtn;
@property (strong,nonatomic) HPGrowingTextView *textView;


@end

@implementation MsgDetailController
@synthesize datailDatas;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    
    self.detailArray =[txsqlite searchARecordWithNumber:self.datailDatas.hisNumber fromTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:SELECT_A_CONVERSATION_SQL];
    
    [self getResouce];
    [self jumpToLastRow];
    [self.tableview reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    txsqlite =[[TXSqliteOperate alloc] init];
    self.detailArray = [[NSMutableArray alloc] init];
    VCLog(@"datailDatas:%@",self.datailDatas);
    
    // 显示左边按钮
    UIView *view = [[UIView alloc] init];
    view.userInteractionEnabled = YES;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, 150, 20)];
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    if (self.datailDatas.hisName.length>0) {
        self.nameLabel.text = self.datailDatas.hisName;
    }
    
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.arearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 230, 20)];
    if (self.datailDatas.hisNumber.length>0 && self.datailDatas.hisHome.length==0) {
        self.arearLabel.text = [NSString stringWithFormat:@"< %@",self.datailDatas.hisNumber];
    }else if(self.datailDatas.hisNumber.length>0 && self.datailDatas.hisHome.length>0)
    {
        self.arearLabel.text = [NSString stringWithFormat:@"< %@%@",self.datailDatas.hisNumber,self.datailDatas.hisHome];
        
    }else
    {
        self.arearLabel.text = [NSString stringWithFormat:@"< back"];
    }
    self.arearLabel.textColor = [UIColor whiteColor];
    
    //注册手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(initRecognizer:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.tableview addGestureRecognizer:swipe];
    [self.view addGestureRecognizer:swipe];

    //返回按钮
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(arearBtnClick:)];
    tap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:tap];
    
    [view addSubview:self.nameLabel];
    [view addSubview:self.arearLabel];
    
    self.contactsInfoBtn.customView = view;
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.allowsSelection = NO;//选中某一行cell时，不作任何显示
    [_tableview flashScrollIndicators ];
    
    [self.view addSubview:_tableview];
    
    [self initInputView];
    [self initKeyBoardNotif];
    
    
    
    
    
    
}

-(void) getResouce
{
    
    
    self.allMsgFrame = [[NSMutableArray alloc] init];
    NSString *previousTime = nil;
    
    for (TXData *data in self.detailArray) {
        
        MsgFrame *messageFrame = [[MsgFrame alloc] init];
        Message *message = [[Message alloc] init];
        
        message.data = data;
        messageFrame.showTime = ![previousTime isEqualToString:message.time];
        messageFrame.message = message;
        previousTime = message.time;
       
        [self.allMsgFrame addObject:messageFrame];
        
    }
}

#pragma --mark 给数据源增加内容-自己发送的内容
- (void)addMessageWithContent:(NSString *)content time:(NSString *)time{
    
    MsgFrame *mf = [[MsgFrame alloc] init];
    Message *msg = [[Message alloc] init];
    msg.content = content;
    msg.time = time;
    msg.type = MessageTypeMe;
    mf.message = msg;
    
    [self.allMsgFrame addObject:mf];
}

-(void)initKeyBoardNotif{
    //键盘显示消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotif:) name:UIKeyboardWillShowNotification object:nil];
    //键盘隐藏消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHiddenNotif:) name:UIKeyboardWillHideNotification object:nil];
    
}


#pragma mark - 键盘显示响应函数
-(void)keyboardWillShowNotif:(NSNotification*)notif{
    
    CGRect keyboardBounds;
    
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //NSNumber *curve = [notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.inputView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    //[UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.inputView.frame = containerFrame;
    
    CGRect rect = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.tableview.frame = CGRectMake(0,0 , DEVICE_WIDTH, DEVICE_HEIGHT-rect.size.height);//-rect.size.height
    [self jumpToLastRow];
    
    // commit animations
    [UIView commitAnimations];
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
#pragma mark - 键盘隐藏响应函数
-(void)keyboardHiddenNotif:(NSNotification*)notif{
    
    
    NSNumber *duration = [notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.inputView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.tableview.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    self.inputView.frame = containerFrame;
    // commit animations
    [UIView commitAnimations];

}


-(void) initInputView
{
    self.inputView = [[UIView alloc] init];
    self.inputView.backgroundColor = RGBACOLOR(240, 240, 240, 1);
    self.inputView.frame = CGRectMake(0, DEVICE_HEIGHT-40, DEVICE_WIDTH, 40);
    //self.inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 4, DEVICE_WIDTH*.8f, 40)];
    self.textView.delegate = self;
    self.textView.minNumberOfLines = 1;
    self.textView.maxNumberOfLines = 6;//最大伸缩行数
    self.textView.font = [UIFont systemFontOfSize:14.0f];
    self.textView.placeholder = NSLocalizedString(@"Message", nil);
    
    //textView的背景
    UIImage *rawEntryBackground = [UIImage imageNamed:@"msg_textView_bg"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, DEVICE_WIDTH*.8f, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //inputView的bgImg
    UIImage *rawBackground = [UIImage imageNamed:@"msg_inputView_bg"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.inputView.frame.size.width, self.inputView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.sendMsgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.sendMsgBtn.frame = CGRectMake(DEVICE_WIDTH-50, 0, 30, 40);
    [self.sendMsgBtn setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [self.sendMsgBtn addTarget:self action:@selector(sendMsgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.inputView];
    [self.inputView addSubview:imageView];
    
    
    [self.inputView addSubview:self.textView];
    [self.inputView addSubview:entryImageView];
    [self.inputView addSubview:self.sendMsgBtn];
    
    
    
}

-(void)jumpToLastRow
{
    //滚动到当前信息
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.detailArray.count-1 inSection:0];
    [self.tableview scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

#pragma mark -- HPGrowingTextView Delegate
-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.inputView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.inputView.frame = r;
}
//处理swipe
-(void) initRecognizer:(UIGestureRecognizer *)recognizer
{
    [self.textView resignFirstResponder];
}

//返回上一层界面
-(void)arearBtnClick:(UIGestureRecognizer *)recognizer
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -- UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allMsgFrame.count;
    //return _resultArray.count;
}


//cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [self.allMsgFrame [indexPath.row] cellHeight];
}

//返回cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MsgDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[MsgDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger aa = indexPath.row;
    // 设置数据
    cell.msgFrame = self.allMsgFrame[aa];
    //VCLog(@"state:%@",[array[indexPath.row] msgState]);
    return cell;
}

//选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//导航栏右边按钮拨-拨打电话
- (IBAction)callBtn:(UIBarButtonItem *)sender {
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.datailDatas.hisName,@"hisName",self.datailDatas.hisNumber,@"hisNumber", nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallingBtnClick object:self userInfo:dict]];
    
}

//导航栏左边按钮-返回
- (IBAction)ContactsInfo:(UIBarButtonItem *)sender {
   
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

//发送信息
- (void)sendMsgBtnClick:(UIButton *)sender {
    
    if (self.textView.text.length>0) {
        
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        NSDate *date = [NSDate date];
        fmt.dateFormat = @"yy/M/d HH:mm"; // @"yyyy-MM-dd HH:mm:ss"
        NSString *time = [fmt stringFromDate:date];
        [self addMessageWithContent:self.textView.text time:time];
        
        //关闭键盘
        [self.textView resignFirstResponder];
        
        //保存到数据库
        TXData *txdata =  [[TXData alloc] init];
        txdata.msgSender = @"";
        txdata.msgTime = time;
        txdata.msgContent = self.textView.text;
        txdata.msgAccepter = self.datailDatas.hisNumber;
        txdata.msgStates = @"0";
        
        [txsqlite addInfo:txdata inTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:MESSAGE_RECORDS_ADDINFO_SQL];
        //self.detailArray =[txsqlite searchARecordWithNumber:self.datailDatas.hisNumber fromTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:SELECT_A_CONVERSATION_SQL];
        
    }
    self.textView.text = nil;
    
    [self jumpToLastRow];
    [self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //移除键盘显示和隐藏消息注册信息
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
