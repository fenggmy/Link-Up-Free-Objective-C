//
//  FKPoint.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
// 定义一个代表屏幕上点的FKPoint，它包含x、y两个属性
@interface FKPoint : NSObject <NSCopying>

@property(nonatomic,assign) NSInteger x;
@property(nonatomic,assign) NSInteger y;

-(id)initWithX:(NSInteger)x Y:(NSInteger)y;

@end
