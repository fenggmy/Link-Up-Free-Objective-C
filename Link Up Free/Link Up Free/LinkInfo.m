//
//  LinkInfo.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "LinkInfo.h"

@implementation LinkInfo
// 提供第一个初始化方法, 表示两个Point可以直接相连, 没有转折点
-(id)initWithP1:(FKPoint *)P1 P2:(FKPoint *)P2{
    self = [super init];
    if (self) {
        _points = [[NSMutableArray alloc]init];
        [_points addObject:P1];
        [_points addObject:P2];
    }
    return self;
}

// 提供第二个初始化方法, 表示三个Point可以相连, p2是p1与p3之间的转折点
-(id)initWithP1:(FKPoint *)P1 P2:(FKPoint *)P2 P3:(FKPoint *)P3{
    self = [super init];
    if (self) {
        _points = [[NSMutableArray alloc]init];
        [_points addObject:P1];
        [_points addObject:P2];
        [_points addObject:P3];
    }
    return self;
}

// 提供第三个初始化方法，表示4个Point可以相连，p2、p3是p1与p4的转折点
-(id)initWithP1:(FKPoint *)P1 P2:(FKPoint *)P2 P3:(FKPoint *)P3 P4:(FKPoint *)P4{
    self = [super init];
    if (self) {
        _points = [[NSMutableArray alloc]init];
        [_points addObject:P1];
        [_points addObject:P2];
        [_points addObject:P3];
        [_points addObject:P4];
    }
    return self;
}

@end
