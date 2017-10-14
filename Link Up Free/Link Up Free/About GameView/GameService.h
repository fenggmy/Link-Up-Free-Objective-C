//
//  GameService.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Piece.h"
#import "LinkInfo.h"

@interface GameService : NSObject
@property(nonatomic,strong) NSArray * pieces;

/**
 控制游戏开始的方法
 */
-(void) start;

/**
 控制游戏结束的方法
 */
-(void) end;

/**
 判断参数Piece二维数组中是否还存在非空的Piece对象

 @return 如果还剩Piece对象返回YES, 没有返回NO
 */
-(BOOL)hasPiece;

/**
 根据触碰点的X坐标和Y坐标, 查找出一个Piece对象

 @param touchX 触碰点的X坐标
 @param touchY 触碰点的Y坐标
 @return 返回对应的Piece对象, 没有返回nil
 */
-(Piece*) findPieceAtTouchX:(CGFloat) touchX TouchY:(CGFloat)touchY;

/**
 判断两个Piece是否可以相连, 可以连接, 返回LinkInfo对象

 @param p1 第一个Piece对象
 @param p2 第二个Piece对象
 @return 如果可以相连，返回LinkInfo对象, 如果两个Piece不可以连接, 返回nil
 */
-(LinkInfo*) linkWithBeginPiece:(Piece*)p1 endPiece:(Piece*)p2;

@end
