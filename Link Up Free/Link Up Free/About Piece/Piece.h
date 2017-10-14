//
//  Piece.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PieceImage.h"
#import "FKPoint.h"

@interface Piece : NSObject

@property(nonatomic,strong) PieceImage * image;
@property(nonatomic,assign) NSInteger beginX;// 该方块左上角的x坐标
@property(nonatomic,assign) NSInteger beginY;// 该方块左上角的y坐标

// 该对象在Piece二维数组中第一、二维的索引值
@property(nonatomic,assign) NSInteger indexX;
@property(nonatomic,assign) NSInteger indexY;

-(id)initWithIndexX:(NSInteger)indexX IndexY:(NSInteger)indexY;
-(FKPoint*) getCenter;// 获取该Piece的中心
-(BOOL)isEqual:(Piece *)other;// 判断两个Piece上的图片是否相同

@end
