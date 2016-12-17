//
//  LrcModel.h
//  AVAudioPlayer音乐播放器Demo
//
//  Created by iJeff on 15/12/30.
//  Copyright (c) 2015年 iJeff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LrcModel : NSObject

//歌词的时间
@property(nonatomic, assign)double time;

//歌词的内容
@property(nonatomic, copy)NSString *lrc;


@end
