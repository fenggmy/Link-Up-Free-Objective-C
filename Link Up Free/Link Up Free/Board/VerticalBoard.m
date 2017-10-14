//
//  VerticalBoard.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//


#import "VerticalBoard.h"
#import "Piece.h"

@implementation VerticalBoard
-(NSArray *)creatPiecesWithXSize:(NSInteger)XSize YSize:(NSInteger)YSize{
    // 创建一个NSMutableArray集合, 该集合中存放初始化游戏时所需的Piece对象
    NSMutableArray * notNullPieces  = [[NSMutableArray alloc]init];
    for (int i = 0; i < XSize; i++) {
        for (int j = 0; j < YSize; j++) {
            // 加入判断，符合一定条件才构造Piece对象，并加到集合中
            // 如果j能被2整除，即单数行不会创建方块
            if (i % 2 == 0) {
                // 先构造一个Piece对象，只设置它在Piece二维数组中的索引值，
                // 所需要的PieceImage由其父类负责设置
                Piece * piece = [[Piece alloc]initWithIndexX:i IndexY:j];
                [notNullPieces addObject:piece];
            }
        }
    }
    return notNullPieces;
}

@end
