//
//  GameView.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/14.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "GameView.h"
#import "LinkInfo.h"
#import <AVFoundation/AVFoundation.h>

@implementation GameView{
    // 选中标识的图片对象
    UIImage * _selectedImage;
    // 定义两个音效文件
    AVAudioPlayer * _guPlayer;
    AVAudioPlayer * _disPlayer;
    // 定义连接线的颜色
    UIColor * _bubbleColor;
}

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.isPlaying = NO;
        // 初始化选中框的图片
        _selectedImage = [UIImage imageNamed:@"images/selected"];
        // 使用图片平铺作为定义连接线的颜色
        _bubbleColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"images/bubble"]];
        // 获取两个音效文件的的URL
        NSURL *disUrl = [[NSBundle mainBundle] URLForResource:@"dis" withExtension:@"wav" subdirectory:@"sounds"];
        NSURL *guUrl = [[NSBundle mainBundle] URLForResource:@"gu" withExtension:@"mp3" subdirectory:@"sounds"];
        // 创建方块消失的AVAudioPlayer对象
        _disPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:disUrl error:nil];
        _disPlayer.numberOfLoops = 0;
        // 创建方块选中的AVAudioPlayer对象
        _guPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:guUrl error:nil];
        _guPlayer.numberOfLoops = 0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (self.gameService == nil) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [_bubbleColor CGColor]);
    CGContextSetLineWidth(ctx, 10);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    NSArray* pieces = self.gameService.pieces;
    if (pieces != nil) {
        // 遍历pieces二维数组
        for (int i = 0; i < pieces.count; i++) {
            for (int j = 0; j < [pieces[i] count]; j++) {
                // 如果二维数组中该元素为Piece对象（即有方块），绘制该方块
                
                if ([pieces[i][j] class] == Piece.class) {
                    // 得到这个Piece对象
                    Piece * piece = pieces[i][j];
                    // 将该Piece对象中包含的图片绘制在指定位置
                    [piece.image.image drawAtPoint:CGPointMake(piece.beginX, piece.beginY)];
                }
            }
        }
    }
    // 如果当前对象中的linkInfo属性不为nil,表明有连接信息
    if (self.linkInfo != nil) {
        [self drawLine:self.linkInfo context:ctx];
        // 处理完后清空linkInfo属性
        self.linkInfo = nil;
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.3];
    }
    // 画选中标识的图片
    if (self.selectedPiece != nil) {
        [_selectedImage drawAtPoint:CGPointMake(self.selectedPiece.beginX, self.selectedPiece.beginY)];
    }
}

// 开始游戏方法
-(void)startGame{
    [self.gameService start];
    self.isPlaying = YES;
    [self setNeedsDisplay];
}

// 根据LinkInfo绘制连接线的方法
-(void) drawLine:(LinkInfo*)linkInfo context:(CGContextRef)ctx{
    // 获取LinkInfo中封装的所有连接点
    NSArray *points = linkInfo.points;
    FKPoint *firstPoint = points[0];
    CGContextMoveToPoint(ctx, firstPoint.x, firstPoint.y);
    for (int i = 0; i < points.count; i++) {
        // 获取当前连接点与下一个连接点
        FKPoint * currentPoint = points[i];
        CGContextAddLineToPoint(ctx, currentPoint.x, currentPoint.y);
    }
    CGContextStrokePath(ctx);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_isPlaying) {
        return;
    }
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];// 获取用户触碰的点
    // 根据用户触碰的坐标得到对应的Piece对象
    Piece * currentPiece = [self.gameService findPieceAtTouchX:touchPoint.x TouchY:touchPoint.y];
    // 如果没有选中任何Piece对象(即鼠标点击的地方没有图片), 不再往下执行
    if ([currentPiece class] != Piece.class) {
        return;
    }
    // 表示之前没有选中任何一个Piec
    if (self.selectedPiece == nil) {
        // 将当前方块设为已选中的方块, 通知GameView重新绘制, 并不再往下执行
        self.selectedPiece = currentPiece;
        // 播放选中方块的音效
        [_guPlayer play];
        [self setNeedsDisplay];
        return;
    }else{
        // 表示之前已经选择了一个,在这里就要对currentPiece和prePiece进行判断并进行连接
        LinkInfo * linkInfo = [self.gameService linkWithBeginPiece:self.selectedPiece endPiece:currentPiece];
        // 两个Piece不可连, linkInfo为nil
        if (linkInfo == nil) {
            // 如果连接不成功, 将当前方块设为选中方块
            self.selectedPiece = currentPiece;
            [_guPlayer play];
            [self setNeedsDisplay];
        }else{
            // 播放方块连接成功的音效
            [_disPlayer play];
            // 处理成功连接
            [self handleSuccessLink:linkInfo prePiece:self.selectedPiece currentPiece:currentPiece];
        }
    }
}

/**
 成功连接后处理 pieces 系统中还剩的全部方块

 @param linkInfo 连接信息
 @param prePiece 前一个选中方块
 @param currentPiece 当前选择方块
 */
-(void)handleSuccessLink:(LinkInfo*)linkInfo prePiece:(Piece*)prePiece currentPiece:(Piece*)currentPiece{
    // 它们可以相连, 让UIGameView处理LinkInfo
    _linkInfo = linkInfo;
    // 将gameView中的选中方块设为nil
    self.selectedPiece = nil;
    // 将两个Piece对象从数组中删除
    [self.gameService.pieces[prePiece.indexX]setObject:[NSObject new] atIndex:prePiece.indexY];
    [self.gameService.pieces[currentPiece.indexX]setObject:[NSObject new] atIndex:currentPiece.indexY];
    [self setNeedsDisplay];
    [self.delegate checkWin:self];
    
}

@end
