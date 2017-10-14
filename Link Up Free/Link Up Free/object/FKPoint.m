//
//  FKPoint.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "FKPoint.h"

@implementation FKPoint
-(id)initWithX:(NSInteger)x Y:(NSInteger)y{
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    // 复制一个对象
    FKPoint * newPoint = [[[self class] allocWithZone:zone] init];
    // 将被复制对象的实变量的值赋给新对象的实例变量
    newPoint->_x = _x;
    newPoint->_y = _y;
    return newPoint;
}
-(BOOL)isEqual:(FKPoint*)other{
    return _x == other.x && _y == other.y;
}

-(NSUInteger)hash{
    return _x * 31 + _y;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"{x = %ld,y = %ld}", _x, _y];
}

@end
