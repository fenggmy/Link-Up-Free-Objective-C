//
//  PieceImage.m
//  Link Up Free
//
//  Created by 马异峰 on 2017/10/13.
//  Copyright © 2017年 Yifeng. All rights reserved.
//

#import "PieceImage.h"

@implementation PieceImage

-(id)initWithImage:(UIImage *)image imageId:(NSString *)imageId{
    if (self = [super init]) {
        _image = image;
        _imageId = imageId;
    }
    return self;
}

@end
