//
//  Piece.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "Piece.h"

@implementation Piece
-(id)initWithIndexX:(NSInteger)indexX IndexY:(NSInteger)indexY{
    self = [super init];
    if (self) {
        _indexX = indexX;
        _indexY = indexY;
    }
    return self;
}

// 获取该Piece的中心
-(FKPoint *)getCenter{
    return [[FKPoint alloc]initWithX:self.image.image.size.width / 2 + _beginX Y:self.image.image.size.height / 2 + _beginY ];
}
// 判断两个Piece上的图片是否相同
-(BOOL)isEqual:(Piece *)other{
    if (self.image == nil) {
        if (other.image != nil) {
            return NO;
        }
    }
    // 只要Piece封装的图片的ID相等，即可认为两个Piece相等
    return self.image.imageId == other.image.imageId;
}

@end
