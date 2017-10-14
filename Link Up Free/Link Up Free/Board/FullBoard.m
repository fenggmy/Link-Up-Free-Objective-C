//
//  FullBoard.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "FullBoard.h"
#import "Piece.h"

@implementation FullBoard
-(NSArray *)creatPiecesWithXSize:(NSInteger)XSize YSize:(NSInteger)YSize{
    // 创建一个NSMutableArray，该集合中存放初始化游戏时所需的Piece对象
    NSMutableArray * notNullPieces = [[NSMutableArray alloc]init];
    // i从1开始，小于xSize - 1，用于控制最上、最下一行不放方块
    for (int i = 1; i < XSize -1; i++) {
        // j从1开始，小于ySize - 1，用于控制最左、最右一列不放方块
        for (int j = 1; j < YSize -1; j++) {
            // 先构造一个Piece对象，只设置它在Piece二维数组中的索引值，
            // 所需要的PieceImage由其父类负责设置
            Piece * piece = [[Piece alloc]initWithIndexX:i IndexY:j];
            [notNullPieces addObject:piece];// 添加到Piece集合中
        }
    }
    return notNullPieces;
}

@end
