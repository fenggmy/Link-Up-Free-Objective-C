//
//  GameService.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "GameService.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "BaseBoard.h"
#import "HorizontalBoard.h"
#import "FullBoard.h"
#import "VerticalBoard.h"

@implementation GameService{
    AppDelegate * _appDelegate;
}
-(void)start{
    // 定义一个BaseBoard对象
    BaseBoard * baseBoard = nil;
    // 获取应用的AppDelegate对象
    _appDelegate = [UIApplication sharedApplication].delegate;
    // 获取一个随机数, 可取值0、1、2
    int index = arc4random() % 3;
    // 随机生成BaseBoard的子类实例
    switch (index) {
        case 0:// 0返回VerticalBoard(竖向)
            baseBoard = [[VerticalBoard alloc]init];
            break;
        case 1:// 1返回HorizontalBoard(横向)
            baseBoard = [[HorizontalBoard alloc]init];
            break;
        default:// 默认返回FullBoard
            baseBoard = [[FullBoard alloc]init];
            break;
    }
    // 初始化Piece二维数组
    self.pieces = [baseBoard create];
}

// 结束游戏，清空所有方块
-(void)end{
    for (int i = 0; i < self.pieces.count; i++) {
        for (int j = 0; j < [self.pieces[i] count]; j++) {
            self.pieces[i][j] = [NSObject new];
        }
    }
}

-(BOOL)hasPiece{
    // 遍历Piece二维数组的每个元素
    for (int i = 0; i < self.pieces.count; i++) {
        for (int j = 0; j < [self.pieces[i] count]; j++) {
            // 只要某个数组元素是Piece对象，也就是还剩有非空的Piece对象
            if ([self.pieces[i][j] class] == [Piece class]) {
                return YES;
            }
        }
    }
    return NO;
}

// 根据触碰点的位置查找相应的方块
-(Piece *)findPieceAtTouchX:(CGFloat)touchX TouchY:(CGFloat)touchY{
    // 由于在创建Piece对象时, 将每个Piece的开始坐标加了
    // beginImageX/beginImageY常量值, 因此这里要减去这个值
    CGFloat relativeX = touchX - beginImageX;
    CGFloat relativeY = touchY - beginImageY;
    // 如果鼠标点击的地方比board中第一张图片的开始x坐标或开始y坐标要小,
    // 即没有找到相应的方块
    if (relativeX < 0 || relativeY < 0) {
        return nil;
    }
    // 获取relativeX坐标在Piece二维数组中第一维的索引值
    // 第二个参数为每张图片的宽
    NSInteger indexX = [self getIndexWithRelative:relativeX size:PIECE_WIDTH];
    // 获取relativeY坐标在Piece二维数组中第二维的索引值
    // 第二个参数为每张图片的高
    NSInteger indexY = [self getIndexWithRelative:relativeY size:PIECE_HEIGHT];
    // 这两个索引比数组的最小索引还小，返回nil
    if (indexX < 0 || indexY < 0) {
        return nil;
    }
    // 这两个索引比数组的最大索引还大（或者等于），返回nil
    if (indexX >= _appDelegate.xSize || indexY >= _appDelegate.ySize) {
        return nil;
    }
    // 返回Piece二维数组的指定元素
    return self.pieces[indexX][indexY];
}

/**
 工具方法根据relative坐标计算相对于Piece二维数组的第一维或第二维的索引值

 @param relative 坐标
 @param size 每张图片边的长或者宽
 @return 索引
 */
-(NSInteger)getIndexWithRelative:(NSInteger)relative size:(NSInteger)size{
    // 让坐标除以边长, 没有余数, 用商减1作为索引
    // 有余数，直接用除得的商作为索引
    return relative % size == 0 ? relative / size - 1 : relative / size;
}


/**
 判断界面上的x, y坐标中是否有Piece对象

 @param x x
 @param y y
 @return YES 表示有该坐标有piece对象 NO 表示没有
 */
-(BOOL)hasPieceAtX:(NSInteger)x Y:(NSInteger)y{
    return [[self findPieceAtTouchX:x TouchY:y] class] == Piece.class;
}

// 实现接口部分的linkWithBeginPiece:endPiece:方法
-(LinkInfo *)linkWithBeginPiece:(Piece *)p1 endPiece:(Piece *)p2{
    // 两个Piece是同一个, 即选中了同一个方块, 返回nil
    if (p1 == p2) {
        return nil;
    }
    if (![p1 isEqual:p2]) {
        return nil;// 如果p1的图片与p2的图片不相同, 则返回nil
    }
    // 如果p2在p1的左边, 则需要重新执行本方法, 两个参数互换
    if (p2.indexX < p1.indexX) {
        return [self linkWithBeginPiece:p2 endPiece:p1];
    }
    // 获取p1、p2的中心点
    FKPoint *p1Point = p1.getCenter;
    FKPoint *p2Point = p2.getCenter;
    
    // 如果两个Piece在同一行
    if (p1.indexY == p2.indexY) {
        // 它们在同一行并可以相连, 没有转折点
        if (![self isXBlockFromP1:p1Point toP2:p2Point pieceWidth:PIECE_WIDTH]) {
            return [[LinkInfo alloc]initWithP1:p1Point P2:p2Point];
        }
    }
    // 如果两个Piece在同一列
    if (p1.indexX == p2.indexX) {
        // 它们在同一列并可以相连, 没有转折点
        if (![self isYBlockFromP1:p1Point toP2:p2Point pieceHeight:PIECE_HEIGHT]) {
            return [[LinkInfo alloc]initWithP1:p1Point P2:p2Point];
        }
    }
    // 有一个转折点的情况
    // 获取两个点的直角相连的点, 即只有一个转折点
    FKPoint * cornerPoint = [self getCornerPointFromStartPoint:p1Point toEndPoint:p2Point width:PIECE_WIDTH height:PIECE_HEIGHT];
    if (cornerPoint != nil) {
        return [[LinkInfo alloc]initWithP1:p1Point P2:cornerPoint P3:p2Point];
    }
    // 该NSDictionaryp的key存放第一个转折点, value存放第二个转折点,
    // NSDictionary的count说明有多少种可以连的方式
    NSDictionary * turns = [self getLinkPointsFromPoint:p1Point toPoint:p2Point width:PIECE_WIDTH height:PIECE_HEIGHT];
    if (turns.count != 0) {
        return [self getShortCutFromPoint1:p1Point toPoint2:p2Point turns:turns distance:[self getDistanceFromPoint1:p1Point toPoint2:p2Point]];
    }
    return nil;
}

/**
 获取两个转折点的情况

 @param point1 起点
 @param point2 终点
 @param pieceWidth 图片的宽度
 @param pieceHeight 图片的高度
 @return NSDictionary对象的每个key-value对代表一种连接方式，其中key、value分别代表第1个、第2个连接点
 */
-(NSDictionary*) getLinkPointsFromPoint:(FKPoint*)point1 toPoint:(FKPoint*)point2 width:(NSInteger)pieceWidth height:(NSInteger)pieceHeight{
    NSMutableDictionary* result = [[NSMutableDictionary alloc]init];
    // 获取以point1为中心的向上, 向右, 向下的通道
    NSArray *p1UpChanel = [self getUpChanelFromPoint:point1 min:point2.y height:pieceHeight];
    NSArray *p1RightChanel = [self getRightChanelFromPoint:point1 max:point2.x width:pieceWidth];
    NSArray * p1DownChanel = [self getDownChanelFromPoint:point1 max:point2.y height:pieceHeight];
    // 获取以point2为中心的向下, 向左, 向上的通道
    NSArray *p2DownChanel = [self getDownChanelFromPoint:point2 max:point1.y height:pieceHeight];
    NSArray *p2LeftChanel = [self getLeftChanelFromPoint:point2 min:point1.x width:pieceWidth];
    NSArray *p2UpChanel = [self getUpChanelFromPoint:point2 min:point1.y height:pieceHeight];
    
    // 获取BaseBoard的最大高度与宽度
    NSInteger maxHeight = (_appDelegate.ySize + 1) * pieceHeight + beginImageY;
    NSInteger maxWidth = (_appDelegate.xSize + 1) * pieceWidth + beginImageX;
    // 先确定两个点的关系, 如果point2在point1的左上角或者左下角，参数换位, 调用本方法
    if ([self isLeftUpToP1:point1 P2:point2] || [self isLeftDownToP1:point1 P2:point2]) {
        return [self getLinkPointsFromPoint:point2 toPoint:point1 width:pieceWidth height:pieceHeight];
    }
    // p1、p2位于同一行不能直接相连
    if (point1.y == point2.y) {
        // 在同一行,向上遍历
        // 以point1的中心点向上遍历获取点集合
        p1UpChanel = [self getUpChanelFromPoint:point1 min:0 height:pieceHeight];
        // 以point2的中心点向上遍历获取点集合
        p2UpChanel = [self getUpChanelFromPoint:point2 min:0 height:pieceHeight];
        NSDictionary *upLinkPoints = [self getLinkXPointsFromP1chanel:p1UpChanel p2Chanel:p2UpChanel pieceWidth:pieceWidth];
        // 向下遍历,不超过Board(有方块的地方)的边框
        // 以p1中心点向下遍历获取点集合
        p1DownChanel = [self getDownChanelFromPoint:point1 max:maxHeight height:pieceHeight];
        p2DownChanel = [self getDownChanelFromPoint:point1 max:maxHeight height:pieceHeight];
        NSDictionary *downLinkPoints = [self getLinkXPointsFromP1chanel:p1DownChanel p2Chanel:p2DownChanel pieceWidth:pieceWidth];
        [result addEntriesFromDictionary:upLinkPoints];
        [result addEntriesFromDictionary:downLinkPoints];
    }
    // p1、p2位于同一列不能直接相连
    if (point1.x == point2.x) {
        // 在同一列, 向左遍历
        // 以p1、p2的中心点向左遍历获取点集合
        NSArray *p1LeftChanel = [self getLeftChanelFromPoint:point1 min:0 width:pieceWidth];
        p2LeftChanel = [self getLeftChanelFromPoint:point2 min:0 width:pieceWidth];
        NSDictionary *leftLinkPoints = [self getLinkYPointsFromP1chanel:p1LeftChanel p2Chanel:p2LeftChanel pieceHeight:pieceHeight];
        // 向右遍历, 不得超过Board的边框（有方块的地方）
        // 以p1、p2的中心点向右遍历获取点集合
        p1RightChanel = [self getRightChanelFromPoint:point1 max:maxWidth width:pieceWidth];
        NSArray * p2RightChanel = [self getRightChanelFromPoint:point2 max:maxWidth width:pieceWidth];
        NSDictionary *rightLinkPoints = [self getLinkYPointsFromP1chanel:p1RightChanel p2Chanel:p2RightChanel pieceHeight:pieceHeight];
        [result addEntriesFromDictionary:rightLinkPoints];
        [result addEntriesFromDictionary:leftLinkPoints];
    }
    // point2位于point1的右上角
    if ([self isRightUpToP1:point1 P2:point2]) {
        // 获取point1向上遍历, point2向下遍历时横向可以连接的点
        NSDictionary* upDownLinkPoints = [self getLinkXPointsFromP1chanel:p1UpChanel p2Chanel:p2DownChanel pieceWidth:pieceWidth];
        // 获取point1向右遍历, point2向左遍历时纵向可以连接的点
        NSDictionary* rightLeftLinkPoints = [self getLinkYPointsFromP1chanel:p1RightChanel p2Chanel:p2LeftChanel pieceHeight:pieceHeight];
        // 获取以p1、p2为中心的向上通道
        p1UpChanel = [self getUpChanelFromPoint:point1 min:0 height:pieceHeight];
        p2UpChanel = [self getUpChanelFromPoint:point2 min:0 height:pieceHeight];
        // 获取point1向上遍历, point2向上遍历时横向可以连接的点
        NSDictionary* upUpLinkPoints = [self getLinkXPointsFromP1chanel:p1UpChanel p2Chanel:p2UpChanel pieceWidth:pieceWidth];
        // 获取以p1、p2为中心的向下通道
        p1DownChanel = [self getDownChanelFromPoint:point1 max:maxHeight height:pieceHeight];
        p2DownChanel = [self getDownChanelFromPoint:point2 max:maxHeight height:pieceHeight];
        NSDictionary* downDownLinkPoints = [self getLinkXPointsFromP1chanel:p1DownChanel p2Chanel:p2DownChanel pieceWidth:pieceWidth];
        // 获取以p1、p2为中心的向左通道
        NSArray * p1LeftChanel = [self getLeftChanelFromPoint:point1 min:0 width:pieceWidth];
        p2LeftChanel = [self getLeftChanelFromPoint:point2 min:0 width:pieceWidth];
        NSDictionary* leftLeftLinkPoints = [self getLinkYPointsFromP1chanel:p1LeftChanel p2Chanel:p2LeftChanel pieceHeight:pieceHeight];
        // 获取以p1、p2为中心的向右通道
        p1RightChanel = [self getRightChanelFromPoint:point1 max:maxWidth width:pieceWidth];
        NSArray * p2RightChanel = [self getRightChanelFromPoint:point2 max:maxWidth width:pieceWidth];
        NSDictionary* rightRightLinkPoints = [self getLinkYPointsFromP1chanel:p1RightChanel p2Chanel:p2RightChanel pieceHeight:pieceHeight];
        [result addEntriesFromDictionary:leftLeftLinkPoints];
        [result addEntriesFromDictionary:rightLeftLinkPoints];
        [result addEntriesFromDictionary:upUpLinkPoints];
        [result addEntriesFromDictionary:upDownLinkPoints];
        [result addEntriesFromDictionary:downDownLinkPoints];
        [result addEntriesFromDictionary:rightRightLinkPoints];
    }
    // point2位于point1的右下角
    if ([self isRightDownToP1:point1 P2:point2]) {
        // 获取point1向下遍历, point2向上遍历时横向可连接的点
        NSDictionary* downUpLinkPoints = [self getLinkXPointsFromP1chanel:p1DownChanel p2Chanel:p2UpChanel pieceWidth:pieceWidth];
        // 获取point1向右遍历, point2向左遍历时纵向可连接的点
        NSDictionary* rightLeftLinkPoints = [self getLinkYPointsFromP1chanel:p1RightChanel p2Chanel:p2LeftChanel pieceHeight:pieceHeight];
        // 获取以p1、p2为中心的向上通道
        p1UpChanel = [self getUpChanelFromPoint:point1 min:0 height:pieceHeight];
        p2UpChanel = [self getUpChanelFromPoint:point2 min:0 height:pieceHeight];
        // 获取point1向上遍历, point2向上遍历时横向可连接的点
        NSDictionary* upUpLinkPoints = [self getLinkXPointsFromP1chanel:p1UpChanel p2Chanel:p2UpChanel pieceWidth:pieceWidth];
        // 获取以p1、p2为中心的向下通道
        p1DownChanel = [self getDownChanelFromPoint:point1 max:maxHeight height:pieceHeight];
        p2DownChanel = [self getDownChanelFromPoint:point2 max:maxHeight height:pieceHeight];
        NSDictionary* downDownLinkPoints = [self getLinkXPointsFromP1chanel:p1DownChanel p2Chanel:p2DownChanel pieceWidth:pieceWidth];
        // 获取以p1、p2为中心的向左通道
        NSArray *p1LeftChanel = [self getLeftChanelFromPoint:point1 min:0 width:pieceWidth];
        p2LeftChanel = [self getLeftChanelFromPoint:point2 min:0 width:pieceWidth];
        NSDictionary* leftLeftLinkPoints = [self getLinkYPointsFromP1chanel:p1LeftChanel p2Chanel:p2LeftChanel pieceHeight:pieceHeight];
        // 获取以p1、p2为中心的向右通道
        p1RightChanel = [self getRightChanelFromPoint:point1 max:maxWidth width:pieceWidth];
        NSArray * p2RightChanel = [self getRightChanelFromPoint:point2 max:maxWidth width:pieceWidth];
        NSDictionary* rightRightLinkPoints = [self getLinkYPointsFromP1chanel:p1RightChanel p2Chanel:p2RightChanel pieceHeight:pieceHeight];
        [result addEntriesFromDictionary:upUpLinkPoints];
        [result addEntriesFromDictionary:leftLeftLinkPoints];
        [result addEntriesFromDictionary:rightLeftLinkPoints];
        [result addEntriesFromDictionary:rightRightLinkPoints];
        [result addEntriesFromDictionary:downUpLinkPoints];
        [result addEntriesFromDictionary:downDownLinkPoints];
    }
    return result;
}

/**
 获取两个不在同一行或者同一列的坐标点的直角连接点, 即只有一个转折点

 @param point1 第一个点
 @param point2 第二个点
 @param pieceWidth Piece图片的宽度
 @param pieceHeight Piece图片的高度
 @return 两个不在同一行或者同一列的坐标点的直角连接点
 */
-(FKPoint*) getCornerPointFromStartPoint:(FKPoint*)point1 toEndPoint:(FKPoint*)point2 width:(NSInteger)pieceWidth height:(NSInteger)pieceHeight{
    // 先判断这两个点的位置关系
    // point2在point1的左上角, point2在point1的左下角
    if ([self isLeftUpToP1:point1 P2:point2] || [self isLeftDownToP1:point1 P2:point2]) {
        // 参数换位, 重新调用本方法
        return [self getCornerPointFromStartPoint:point2 toEndPoint:point1 width:pieceWidth height:pieceHeight];
    }
    // 获取point1向右, 向上, 向下的三个通道
    NSArray *point1RightChanel = [self getRightChanelFromPoint:point1 max:point2.x width:pieceWidth];
    NSArray *point1UpChanel = [self getUpChanelFromPoint:point1 min:point2.y height:pieceHeight];
    NSArray *point1DownChanel = [self getDownChanelFromPoint:point1 max:point2.y height:pieceHeight];
    // 获取point2向下, 向左, 向上的三个通道
    NSArray *point2DownChanel = [self getDownChanelFromPoint:point2 max:point1.y height:pieceHeight];
    NSArray *point2LeftChanel = [self getLeftChanelFromPoint:point2 min:point1.x width:pieceWidth];
    NSArray *point2UpChanel = [self getUpChanelFromPoint:point2 min:point1.y height:pieceHeight];
    
    if ([self isRightUpToP1:point1 P2:point2]) {
        // point2在point1的右上角
        // 获取p1向右和p2向下的交点
        FKPoint *linkPoint1 = [self getWrapPointChanel1:point1RightChanel Chanel2:point2DownChanel];
        // 获取p1向上和p2向左的交点
        FKPoint *linkPoint2 = [self getWrapPointChanel1:point1UpChanel Chanel2:point2LeftChanel];
        // 返回其中一个交点, 如果没有交点, 则返回nil
        return linkPoint1 == nil ? linkPoint2 : linkPoint1;
    }
    if ([self isRightDownToP1:point1 P2:point2]) {
        // point2在point1的右下角
        // 获取p1向下和p2向左的交点
        FKPoint *linkPoint1 = [self getWrapPointChanel1:point1DownChanel Chanel2:point2LeftChanel];
        // 获取p1向右和p2向上的交点
        FKPoint *linkPoint2 = [self getWrapPointChanel1:point1RightChanel Chanel2:point2UpChanel];
        // 返回其中一个交点, 如果没有交点, 则返回nil
        return linkPoint1 == nil ? linkPoint2 : linkPoint1;
    }
    return nil;
}

/**
 判断两个y坐标相同的点对象之间是否有障碍, 以p1为中心向右遍历
 @param P1 点对象1
 @param P2 点对象2
 @param pieceWidth Piece对象的宽度
 @return 两个Piece之间有障碍返回YES，否则返回NO
 */
-(BOOL)isXBlockFromP1:(FKPoint*)P1 toP2:(FKPoint*)P2 pieceWidth:(CGFloat)pieceWidth{
    if (P2.x < P1.x) {// 如果p2在p1左边, 调换参数位置调用本方法
        return [self isXBlockFromP1:P2 toP2:P1 pieceWidth:pieceWidth];
    }
    for (int i = P1.x + pieceWidth; i < P2.x; i += pieceWidth) {
        if ([self hasPieceAtX:i Y:P1.y]) {// 有障碍
            return YES;
        }
    }
    return NO;
}

/**
 判断两个x坐标相同的点对象之间是否有障碍, 以p1为中心向下遍历

 @param P1 点对象1
 @param P2 点对象2
 @param pieceHeight Piece对象的高度
 @return 两个Piece之间有障碍返回YES，否则返回NO
 */
-(BOOL)isYBlockFromP1:(FKPoint *)P1 toP2:(FKPoint *)P2 pieceHeight:(CGFloat)pieceHeight{
    if (P2.y < P1.y) {// 如果p2在p1上边, 调换参数位置调用本方法
        return [self isYBlockFromP1:P2 toP2:P1 pieceHeight:pieceHeight];
    }
    for (int i = P1.y + pieceHeight; i < P2.y; i += pieceHeight) {
        if ([self hasPieceAtX:P1.x Y:i]) {// 有障碍
            return YES;
        }
    }
    return NO;
}


/**
 遍历两个集合,找到可以横向直线连接的连接点的键值对
 先判断第一个集合的元素的y坐标与另一个集合中的元素y坐标相同(横向),
 如果相同, 即在同一行, 再判断是否有障碍, 没有则加到NSMutableDictionary中去
 @param p1Chanel 集合1
 @param p2Chanel 集合2
 @param pieceWidth Piece图片的宽度
 @return 可以横向直线连接的连接点的键值对
 */
-(NSDictionary*) getLinkXPointsFromP1chanel:(NSArray*)p1Chanel p2Chanel:(NSArray*)p2Chanel pieceWidth:(NSInteger)pieceWidth{
    NSMutableDictionary * result = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < p1Chanel.count; i++) {
        // 从第一通道中取一个点
        FKPoint * temp1 = p1Chanel[i];
        // 再遍历第二个通道, 看下第二通道中是否有点可以与temp1横向相连
        for (int j = 0; j < p2Chanel.count; j++) {
            FKPoint * temp2 = p2Chanel[j];
            // 如果y坐标相同(在同一行), 再判断它们之间是否有直接障碍
            if (temp1.y == temp2.y) {
                if (![self isXBlockFromP1:temp1 toP2:temp2 pieceWidth:pieceWidth]) {
                    // 没有障碍则加到结果的NSMutableDictionary中
                    [result setObject:temp2 forKey:temp1];
                }
            }
        }
    }
    return [result copy];
}

/**
 遍历两个集合,找到可以纵向直线连接的连接点的键值对
 先判断第一个集合的元素的x坐标与另一个集合中的元素x坐标相同(纵向),
 如果相同, 即在同一列, 再判断是否有障碍, 没有则加到NSMutableDictionary中去

 @param p1Chanel 集合1
 @param p2Chanel 集合2
 @param pieceHeight Piece图片的高度
 @return 可以纵向直线连接的连接点的键值对
 */
-(NSDictionary*) getLinkYPointsFromP1chanel:(NSArray*)p1Chanel p2Chanel:(NSArray*)p2Chanel pieceHeight:(NSInteger)pieceHeight{
    NSMutableDictionary * result = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < p1Chanel.count; i++) {
        // 从第一通道中取一个点
        FKPoint * temp1 = p1Chanel[i];
        // 再遍历第二个通道, 看下第二通道中是否有点可以与temp1纵向相连
        for (int j = 0; j < p2Chanel.count; j++) {
            FKPoint * temp2 = p2Chanel[j];
            // 如果x坐标相同(在同一列), 再判断它们之间是否有直接障碍
            if (temp1.x == temp2.x) {
                if (![self isYBlockFromP1:temp1 toP2:temp2 pieceHeight:pieceHeight]) {
                    // 没有障碍则加到结果的NSMutableDictionary中
                    [result setObject:temp2 forKey:temp1];
                }
            }
        }
    }
    return [result copy];
}

/**
 遍历两个通道, 获取它们的交点

 @param p1Chanel 第一个点的通道
 @param p2Chanel 第二个点的通道
 @return 两个通道有交点，返回交点，否则返回nil
 */
-(FKPoint*) getWrapPointChanel1:(NSArray*)p1Chanel Chanel2:(NSArray*)p2Chanel{
    for (int i = 0; i < p1Chanel.count; i++) {
        FKPoint* temp1 = p1Chanel[i];
        for (int j = 0; j < p2Chanel.count; j++) {
            FKPoint *temp2 = p2Chanel[j];
            if ([temp1 isEqual:temp2]) {// 如果两个NSArray中有元素是同一个, 表明这两个通道有交点
                return temp1;
            }
        }
    }
    return nil;
}

/**
 返回指定Point对象的左边通道

 @param point 给定的Point参数
 @param min 向左遍历时最小的界限
 @param pieceWidth Piece图片的宽
 @return 给定Point左边的通道
 */
-(NSArray*) getLeftChanelFromPoint:(FKPoint*)point min:(NSInteger)min width:(NSInteger)pieceWidth{
    NSMutableArray * result = [[NSMutableArray alloc]init];
    // 获取向左通道, 由一个点向左遍历, 步长为Piece图片的宽
    for (NSInteger i = point.x - pieceWidth; i >= min; i -= pieceWidth) {
        // 遇到障碍, 表示通道已经到尽头, 直接返回
        if ([self hasPieceAtX:i Y:point.y]) {
            return result;
        }
        [result addObject:[[FKPoint alloc]initWithX:i Y:point.y]];
    }
    return result;
}

/**
  返回指定Point对象的右边通道

 @param point 给定的Point参数
 @param max 向右遍历时最小的界限
 @param pieceWidth Piece图片的宽
 @return 给定Point对象的右边通道
 */
-(NSArray*) getRightChanelFromPoint:(FKPoint*)point max:(NSInteger)max width:(NSInteger)pieceWidth{
    NSMutableArray * result = [[NSMutableArray alloc]init];
    // 获取向右通道, 由一个点向右遍历, 步长为Piece图片的宽
    for (NSInteger i = point.x - pieceWidth; i <= max; i += pieceWidth) {
        // 遇到障碍, 表示通道已经到尽头, 直接返回
        if ([self hasPieceAtX:i Y:point.y]) {
            return result;
        }
        [result addObject:[[FKPoint alloc]initWithX:i Y:point.y]];
    }
    return result;
}

/**
 返回指定Point对象的上边通道

 @param point 给定的Point参数
 @param min 向上遍历时最小的界限
 @param pieceHeight Piece图片的高
 @return 给定Point对象的上边通道
 */
-(NSArray*) getUpChanelFromPoint:(FKPoint*)point min:(NSInteger)min height:(NSInteger)pieceHeight{
    NSMutableArray * result = [[NSMutableArray alloc]init];
    // 获取向上通道, 由一个点向上遍历, 步长为Piece图片的高
    for (NSInteger i = point.y - pieceHeight; i >= min; i -= pieceHeight) {
        // 遇到障碍, 表示通道已经到尽头, 直接返回
        if ([self hasPieceAtX:point.x Y:i]) {
            return result;
        }
        [result addObject:[[FKPoint alloc]initWithX:point.x Y:i]];
    }
    return result;
}

/**
 返回指定Point对象的下边通道

 @param point 给定的Point参数
 @param max 向下遍历时最大的界限
 @param pieceHeight Piece图片的高
 @return 给定Point对象的下边通道
 */
-(NSArray*) getDownChanelFromPoint:(FKPoint*)point max:(NSInteger)max height:(NSInteger)pieceHeight{
    NSMutableArray * result = [[NSMutableArray alloc]init];
    // 获取向下通道, 由一个点向下遍历, 步长为Piece图片的高
    for (NSInteger i = point.y + pieceHeight; i <= max; i += pieceHeight) {
        // 遇到障碍, 表示通道已经到尽头, 直接返回
        if ([self hasPieceAtX:point.x Y:i]) {
            return result;
        }
        [result addObject: [[FKPoint alloc]initWithX:point.x Y:i]];
    }
    return result;
}

/**
 判断point2是否在point1的左上角

 @param point1 point1
 @param point2 point2
 @return point2位于point1的左上角时返回YES，否则返回NO
 */
-(BOOL) isLeftUpToP1:(FKPoint*)point1 P2:(FKPoint*)point2{
    return (point2.x < point1.x && point2.y < point1.y);
}


/**
 判断point2是否在point1的左下角

 @param point1 point1
 @param point2 point2
 @return point2位于point1的左下角时返回YES，否则返回NO
 */
-(BOOL) isLeftDownToP1:(FKPoint*)point1 P2:(FKPoint*)point2{
    return (point2.x < point1.x && point2.y > point1.y);
}

/**
 判断point2是否在point1的右上角

 @param point1 point1
 @param point2 point2
 @return point2位于point1的右上角时返回YES，否则返回NO
 */
-(BOOL) isRightUpToP1:(FKPoint*)point1 P2:(FKPoint*)point2{
    return (point2.x > point1.x && point2.y < point1.y);
}

/**
 判断point2是否在point1的右下角

 @param point1 point1
 @param point2 point2
 @return point2位于point1的右下角时返回YES，否则返回NO
 */
-(BOOL) isRightDownToP1:(FKPoint*)point1 P2:(FKPoint*)point2{
    return (point2.x > point1.x && point2.y > point1.y);
}

/**
 获取p1和p2之间最短的连接信息

 @param p1 第一个点
 @param p2 第二个点
 @param turns 放转折点的NSDictionary
 @param distance 两点之间的最短距离
 @return p1和p2之间最短的连接信息
 */
-(LinkInfo*)getShortCutFromPoint1:(FKPoint*)p1 toPoint2:(FKPoint*)p2 turns : (NSDictionary*) turns distance:(NSInteger) distance{
    NSMutableArray * infos = [[NSMutableArray alloc]init];
    // 遍历结果NSDictionary
    for (FKPoint* point1 in turns) {
        FKPoint* point2 = turns[point1];
        // 将转折点与选择点封装成LinkInfo对象, 放到可变数组中
        [infos addObject:[[LinkInfo alloc]initWithP1:p1 P2:point1 P3:point2 P4:p2]];
    }
    return [self getShortCut:infos shortDistance:distance];
}

/**
 从infos中获取连接线最短的那个LinkInfo对象

 @param infos 所有LinkInfo对象
 @param shortDistance 两个点的最短距离
 @return 连接线最短的那个LinkInfo对象
 */
-(LinkInfo*)getShortCut:(NSArray *)infos shortDistance:(NSInteger)shortDistance{
    NSInteger temp1 = 0;
    LinkInfo *result = nil;
    for (int i = 0; i < infos.count; i++) {
        LinkInfo *info = infos[i];
        // 计算出几个点的总距离
        NSInteger distance = [self countAll:info.points];
        // 将第一次循环计算的差距用temp1保存
        if (i == 0) {
            temp1 = distance - shortDistance;
            result = info;
        }
        // 如果下一次循环的值比temp1的还小, 则用当前的值作为temp1
        if (distance - shortDistance < temp1) {
            temp1 = distance - shortDistance;
            result = info;
        }
    }
    return result;
}


/**
 计算NSArray中所有点的距离总和

 @param points 需要计算的连接点
 @return 所有点的距离的总和
 */
-(NSInteger)countAll:(NSArray*)points{
    NSInteger result = 0;
    for (int i = 0; i < points.count - 1; i++) {
        // 获取第i个点
        FKPoint *point1 = points[i];
        // 获取第i + 1个点
        FKPoint *point2 = points[i+1];
        // 计算第i个点与第i + 1个点的距离，并添加到总距离中
        result += [self getDistanceFromPoint1:point1 toPoint2:point2];
    }
    return result;
}

/**
 获取两个点之间的最短距离

 @param P1 第一个点
 @param P2 第二个点
 @return 两个点的距离距离总和
 */
-(CGFloat)getDistanceFromPoint1:(FKPoint*)P1 toPoint2:(FKPoint*)P2{
    NSInteger xDistance = abs((int)(P1.x - P2.x));
    NSInteger yDistance = abs((int)(P1.y - P2.y));
    return xDistance + yDistance;
}
@end
