//
//  PieceImage.h
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PieceImage : NSObject

@property(nonatomic,strong) UIImage * image;
@property(nonatomic,copy) NSString * imageId;

-(id)initWithImage:(UIImage *)image imageId:(NSString*) imageId;

@end
