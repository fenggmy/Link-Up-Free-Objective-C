//
//  ViewController.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameView.h"

@interface ViewController ()<GameViewDelegate>

@property(nonatomic ,strong) UILabel * timeText;

@end

@implementation ViewController{
    
    // 游戏界面类
    GameView * _gameView;
    // 游戏剩余时间
    NSInteger  _leftTime;
    // 定时器
    NSTimer * _timer;
    
    UIAlertController * _lostAlert;
    UIAlertController * _successAlert;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect viewBounds = self.view.bounds;
    // 获取AppDelegate对象
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    // 根据屏幕宽度来计算游戏界面的横向、纵向应该包含多少个方块
    switch ((int)viewBounds.size.width) {
            // iPhone 5/iPhone 5s的屏幕
        case 320:
            appDelegate.xSize = 8;
            appDelegate.ySize = 12;
            break;
            // iPhone 6/6s/7/8的屏幕
        case 375:
            appDelegate.xSize = 10;
            appDelegate.ySize = 14;
            break;
        default:
            appDelegate.xSize = 10;
            appDelegate.ySize = 16;
            break;
    }
    // 使用room.png作为游戏背景图片
    UIColor * bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"images/room.png"]];
    self.view.backgroundColor = bgColor;
    
    UIView * container = [[UIView alloc]initWithFrame:CGRectMake(0, viewBounds.size.height - 49, viewBounds.size.width, 49)];
    [self.view addSubview:container];
    container.backgroundColor = [UIColor colorWithRed:30.0 / 255 green:114.0 / 255 blue:187.0 / 255 alpha:1];
    self.timeText = [[UILabel alloc]initWithFrame:CGRectMake(184, 0, viewBounds.size.width - 184, 49)];
    [container addSubview:self.timeText];
    
    self.timeText.textColor = [UIColor colorWithRed:1 green:1 blue:9.0 / 15 alpha:1];
    UIButton * startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    startButton.frame = CGRectMake(0, 0, 170, 49);
    [container addSubview:startButton];
    
    // 为startBn按钮设置图片
    [startButton setBackgroundImage:[UIImage imageNamed:@"images/start.png"] forState:UIControlStateNormal];
    [startButton setBackgroundImage:[UIImage imageNamed:@"images/start_down.png"] forState:UIControlStateHighlighted];
    // 为startBn的Touch Up Inside事件绑定事件处理方法
    [startButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    CGFloat gameViewWidth = PIECE_WIDTH * appDelegate.xSize;
    // 创建GameView控件
    _gameView = [[GameView alloc]initWithFrame:CGRectMake((viewBounds.size.width - gameViewWidth) / 2, 20, gameViewWidth, PIECE_HEIGHT * appDelegate.ySize + beginImageY)];
    // 创建GameService对象
    _gameView.gameService = [[GameService alloc]init];
    _gameView.delegate = self;
    _gameView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_gameView];
    // 初始化游戏失败的对话框
    _lostAlert = [UIAlertController alertControllerWithTitle:@"啊哦，游戏失败了！" message:@"游戏失败，重新开始？" preferredStyle:UIAlertControllerStyleAlert];
    [_lostAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self endGame];
    }]];
    [_lostAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self startGame];
    }]];
    _successAlert = [UIAlertController alertControllerWithTitle:@"哎哟，不错哦！" message:@"恭喜你，挑战成功！重新开始？" preferredStyle:UIAlertControllerStyleAlert];
    [_successAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self endGame];
    }]];
    [_successAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self startGame];
    }]];
    
}

-(void)startGame{
    // 如果之前的_timer还未取消，取消_timer
    if (_timer != nil) {
        [_timer invalidate];
    }
    _leftTime = DEFAULT_TIME;// 重新设置游戏时间
    [_gameView startGame];// 开始新的游戏游戏
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshView) userInfo:nil repeats:YES];
    // 将选中方块设为nil
    _gameView.selectedPiece = nil;
}

-(void)endGame{
    [_gameView.gameService end];
    _gameView.selectedPiece = nil;// 将选中方块设为nil
    [_gameView setNeedsDisplay];
    self.timeText.text = @"";// 不再显示剩余时间
}

-(void)refreshView{
    self.timeText.text = [NSString stringWithFormat:@"剩余时间：%ld", (long)_leftTime];
    _leftTime--;
    if (_leftTime < 0) {// 时间小于0, 游戏失败
        
        [_timer invalidate];
        _gameView.isPlaying = NO;// 更改游戏的状态
        [self presentViewController:_lostAlert animated:YES completion:nil];
        return;
    }
}

-(void)checkWin:(GameView*)gameView{
    // 判断是否还有剩下的方块, 如果没有, 游戏胜利
    if (![gameView.gameService hasPiece]) {
        [self presentViewController:_successAlert animated:YES completion:nil];
        [_timer invalidate];// 停止定时器
        _gameView.isPlaying = NO;// 更改游戏状态
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
