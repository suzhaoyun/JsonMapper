//
//  Metadatas.hpp
//  JMMetadata
//
//  Created by ZYSu on 2020/7/2.
//  Copyright © 2020 ZYSu. All rights reserved.
//

#import <UIKit/UIKit.h>

struct jm_ivar {
    char *name;
    int offset;
    void *type;
};

/// 获取metadata的属性列表 支持struct/class
/// @param metadata swift中的metadata
/// @param ivar_count 属性的个数
UIKIT_EXTERN struct jm_ivar * _Nullable jm_copyIvarList(void *metadata, int *ivar_count);
