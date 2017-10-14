//
//  BaseBoard.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "BaseBoard.h"
#import "AppDelegate.h"
#import "ImageTools.h"
#import "Piece.h"
#import "Constants.h"


@implementation BaseBoard
// 定义一个方法, 让子类去实现
-(NSArray *)creatPiecesWithXSize:(NSInteger)XSize YSize:(NSInteger)YSize{
    return nil;
}
-(NSArray *)create{
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    // 创建Piece的二维数组
    NSMutableArray * pieces = [[NSMutableArray alloc]init];
    for (int i = 0; i < appDelegate.xSize; i++) {
        NSMutableArray * arr = [[NSMutableArray alloc]init];
        for (int j = 0; j < appDelegate.ySize; j++) {
            [arr addObject:[NSObject new]];
        }
        [pieces addObject:arr];
    }
    // 返回非空的Piece集合, 该集合由子类实现的方法负责创建
    NSArray * notNullPieces = [self creatPiecesWithXSize:appDelegate.xSize YSize:appDelegate.ySize];
    // 根据非空Piece对象的集合的大小来取图片
    NSArray * playImages = getPlayImages(notNullPieces.count);
    // 所有图片的宽、高都是相同的，随便取出一个方块的宽、高即可
    int imageWidth = ((PieceImage *)playImages[0]).image.size.width;
    int imageHeight = ((PieceImage *)playImages[0]).image.size.height;
    
    for (int i = 0; i < notNullPieces.count; i++) {
        // 依次获取每个Piece对象
        Piece * piece = notNullPieces[i];
        piece.image = playImages[i];
        // 计算每个方块左上角的X、Y坐标
        piece.beginX = piece.indexX * imageWidth + beginImageX;
        piece.beginY = piece.indexY * imageHeight + beginImageY;
        // 将该方块对象放入方块数组的相应位置处
        [pieces[piece.indexX] setObject:piece atIndex:piece.indexY];
    }
    return pieces;
}
@end
