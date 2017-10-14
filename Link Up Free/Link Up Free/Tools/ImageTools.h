//
//  ImageTools.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#ifndef ImageTools_h
#define ImageTools_h
#import <UIKit/UIKit.h>
/*
 获取连连看所有图片的ID（约定所有图片ID以p_开头）
 返回images目录下所有以p_开头的图片的文件名
 */

NSArray* imageValues();


/**
 随机从sourceValues的集合中获取size个图片ID, 返回结果为图片ID的集合

 @param sourceValues 从中获取的集合
 @param size 需要获取的个数
 @return size个图片ID的集合
 */
NSMutableArray * getRandomValues(NSArray * sourceValues, NSInteger size);

/**
 随机获取size个图片资源ID(以p_为前缀的资源名称), 其中size为游戏数量

 @param size 需要获取的图片ID的数量
 @return size个图片ID的集合
 */
NSArray * getPlayValues(NSInteger size);


/**
 随机获取size个图片资源包装成的PieceImage对象

 @param size 需要获取的图片的数量
 @return size个图片包装成的PieceImage对象的集合
 */
NSArray * getPlayImages(NSInteger size);

#endif /* ImageTools_h */

