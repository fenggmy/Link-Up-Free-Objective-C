//
//  GameView.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/14.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameService.h"
#import "LinkInfo.h"
#import "Piece.h"


@class GameView;
@protocol GameViewDelegate <NSObject>
-(void) checkWin:(GameView*) gameView;
@end

@interface GameView : UIView

// 游戏逻辑的实现类
@property(nonatomic,strong) GameService * gameService;
// 游戏是否正在进行的属性
@property(nonatomic,assign) BOOL isPlaying;
// 连接信息对象
@property(nonatomic,strong) LinkInfo * linkInfo;
// 保存当前已经被选中的方块
@property(nonatomic,strong) Piece * selectedPiece;

@property(nonatomic,weak) id<GameViewDelegate> delegate;
// 开始游戏方法
-(void)startGame;

@end
