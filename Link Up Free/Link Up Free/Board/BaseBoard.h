//
//  BaseBoard.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface BaseBoard : NSObject

-(NSArray*) creatPiecesWithXSize:(NSInteger)XSize YSize:(NSInteger)YSize;
-(NSArray*) create;

@end
