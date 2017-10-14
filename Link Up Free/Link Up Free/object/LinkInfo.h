//
//  LinkInfo.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKPoint.h"

@interface LinkInfo : NSObject
// 定义一个NSMutableArray用于保存连接点

@property(nonatomic,strong) NSMutableArray * points;
- (id)initWithP1 : (FKPoint *)P1 P2 : (FKPoint *)P2;
- (id)initWithP1 : (FKPoint *)P1 P2 : (FKPoint *)P2 P3 : (FKPoint *)P3;
- (id)initWithP1 : (FKPoint *)P1 P2 : (FKPoint *)P2 P3 : (FKPoint *)P3 P4 : (FKPoint *)P4;

@end
