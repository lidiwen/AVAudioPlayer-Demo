//
//  MainViewController.m
//  AVAudioPlayer音乐播放器Demo
//
//  Created by iJeff on 15/12/30.
//  Copyright (c) 2015年 iJeff. All rights reserved.
//

#import "MainViewController.h"

//导入音频播放的框架
#import <AVFoundation/AVFoundation.h>

#import "LrcModel.h" //model

@interface MainViewController ()
<UITableViewDataSource, UITableViewDelegate>
{
    //当前时间
    __weak IBOutlet UILabel *currentTimeLab;
    
    //总时长
    __weak IBOutlet UILabel *totalTimeLab;
    
    //播放器拖动条
    __weak IBOutlet UISlider *playerSlider;
    
    //tableView
    __weak IBOutlet UITableView *myTableView;
    
    //tableView数据源数组
    NSMutableArray *dataSources;
    
    
    //音频播放器
    AVAudioPlayer *player;
    
    //保存当前正在播放的歌词在数组dataSources中的下标
    int row;
}
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //实例化
    dataSources = [NSMutableArray array];
    
    
    //初始化播放器
    [self initPlayer];
    
    //开启一个定时器
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer) userInfo:nil repeats:YES];
    
    //获取歌词
    [self getLrc];
}

//初始化播放器
-(void)initPlayer
{
    //音乐的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"情非得已" ofType:@"mp3"];
    NSLog(@"%@",path);
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSError *error = nil;
    //初始化音乐播放器
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"error:%@", error);
    }
    
    
    
    //准备播放
    [player prepareToPlay];
    
    //播放
//    [player play];
//    [player pause]; //暂停
//    [player stop]; //停止
    
    player.numberOfLoops = -1; //负数表示无限循环
    
    double duration = player.duration; //音乐总时长
    
    //设置总时长
    totalTimeLab.text = [NSString stringWithFormat:@"%02d:%02d", (int)duration/60, (int)duration%60];
    
    
    //设置滑块
    [playerSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:0];
}

//获取当前播放器的时间
-(void)timer
{
    //获取当前播放器的时间
    double currentTime = player.currentTime;
    
    //设置当前播放时间
    currentTimeLab.text = [NSString stringWithFormat:@"%02d:%02d", (int)currentTime/60, (int)currentTime%60];
    
    //设置播放拖动条的值
    playerSlider.value = currentTime/player.duration;
    
    //同步歌词
    [self syncLrc];
}

//获取歌词
-(void)getLrc
{
    //歌词的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"情非得已" ofType:@"lrc"];
    
    //歌词的内容
    NSString *lrcString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"lrcString: \n%@", lrcString);
    
    //每行歌词的数组
    NSArray *oneLrcArr = [lrcString componentsSeparatedByString:@"["];
    
    //遍历oneLrcArr
    for (int i=3; i<oneLrcArr.count; i++) {
        
        //每一行歌词
        //"01:29.27]难以忘记初次见你"
        NSString *oneLrc = oneLrcArr[i];
        
        //一行歌词的时间和歌词内容
        NSArray *lrcArr = [oneLrc componentsSeparatedByString:@"]"];
        
        double time = 0; //时间
        NSString *lrc = @""; //歌词内容
        if (lrcArr.count >= 2) {
            
            //01:29.27
            NSString *timeStr = lrcArr[0]; //时间
            
            //难以忘记初次见你
            lrc = lrcArr[1]; //歌词内容
            
            //分割时间
            NSArray *timeArr = [timeStr componentsSeparatedByString:@":"];
            if (timeArr.count >= 2) {
                //计算得到时间(单位:秒)
                time = [timeArr[0] doubleValue]*60 + [timeArr[1] doubleValue];
            }
            
        }
        
        NSLog(@"time: %lf, lrc: %@", time, lrc);
        
        //创建model
        LrcModel *model = [[LrcModel alloc] init];
        model.time = time; //时间
        model.lrc = lrc; //歌词内容
        
        //添加model
        [dataSources addObject:model];
    }
    
    //刷新myTableView
    [myTableView reloadData];

}

//同步歌词
-(void)syncLrc
{
    
    BOOL isLast = YES;
    //遍历所有歌词
    for (int i=1; i<dataSources.count; i++) {
        
        LrcModel *model = dataSources[i];
        double time = model.time; //歌词时间(单位:秒)
        
        if (player.currentTime < time) {
            
            //row现在就已经是当前播放的歌词下标了
            row = i-1;
            
            isLast = NO; //不是最后一行歌词
            
            break;
        }
    }
    
    //如果是最后一行歌词
    if (isLast) {
        row = (int)dataSources.count - 1;
    }
    
    
    //刷新myTableView
    [myTableView reloadData];
    
    //自动滚动到row这一行
    [myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}




#pragma mark - tableView 代理方法
//cell的数量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSources.count;
}

//cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    //获取cell的数据model
    LrcModel *model = dataSources[indexPath.row];
    
    cell.textLabel.text = model.lrc; //显示歌词
    cell.textLabel.textAlignment = NSTextAlignmentCenter; //居中
    
    //如果是正在播放的歌词
    if (row == indexPath.row) {
        NSLog(@"正在播放的歌词");
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    return cell;
}



//播放器播放进度改变
- (IBAction)playerValueChanged:(UISlider *)sender {
    
    //设置播放进度
    player.currentTime = sender.value * player.duration;
}

//音量改变
- (IBAction)volumeValueChanged:(UISlider *)sender {
    
    //设置音量
    player.volume = sender.value;
}

//播放 or 暂停
- (IBAction)playOrPause:(UIButton *)sender {
    
    //如果正在播放的情况下, 则暂停
    if (player.isPlaying) {
        [player pause];
        [sender setTitle:@"播放" forState:0];
    }
    //否则播放
    else {
        [player play];
        [sender setTitle:@"暂停" forState:0];
    }
}








@end



