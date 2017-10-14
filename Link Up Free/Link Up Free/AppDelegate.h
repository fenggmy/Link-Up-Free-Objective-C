//
//  AppDelegate.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Piece二维数组第一维的长度
@property (nonatomic , assign) NSInteger xSize;

// Piece二维数组第二维的长度
@property (nonatomic , assign) NSInteger ySize;

@end

