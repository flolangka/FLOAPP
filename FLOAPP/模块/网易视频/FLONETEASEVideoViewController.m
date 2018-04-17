//
//  FLONETEASEVideoViewController.m
//  FLOAPP
//
//  Created by 360doc on 2018/4/12.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLONETEASEVideoViewController.h"
#import "FLONETEASEVideoViewModel.h"
#import "FLONETEASEVideoItemViewModel.h"
#import "FLONETEASEVideoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface FLONETEASEVideoViewController ()

@property (nonatomic, strong, readwrite) FLONETEASEVideoViewModel *viewModel;

@property (nonatomic, assign) NSInteger playIndex;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation FLONETEASEVideoViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addHeaderRefresh];
    [self addFooterRefresh];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FLONETEASEVideoTableViewCell" bundle:nil] forCellReuseIdentifier:@"FLONETEASEVideoTableViewCell"];
    
    //请求数据
    self.viewModel.loading = YES;
    [self headerRefreshAction];
    
    //切换视频
    self.playIndex = -1;
    @weakify(self);
    [RACObserve(self, playIndex) subscribeNext:^(NSNumber *playIndex) {
        @strongify(self);
        
        [self playerLayerRemoveFromSuperlayer];
        
        if (playIndex.integerValue >= 0 && playIndex.integerValue < self.viewModel.dataArr.count) {
            FLONETEASEVideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:playIndex.integerValue]];
            [cell playWithPlayerLayer:self.playerLayer];
        }
        //DLog(@"播放位置------- %@", playIndex);
    }];
    
    //播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //初始化、从全屏返回
    [self playerLayerRemoveFromSuperlayer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.presentedViewController) {
        //返回上一页
        [self playerLayerRemoveFromSuperlayer];
        [self.playerLayer setPlayer:nil];
        self.playerLayer = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        AVPlayer *player = [AVPlayer playerWithPlayerItem:nil];
        //静音播放
        player.muted = YES;
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        _playerLayer.backgroundColor = COLOR_RGB3SAME(0).CGColor;
    }
    return _playerLayer;
}

- (void)playerLayerRemoveFromSuperlayer {
    [self.playerLayer.player.currentItem cancelPendingSeeks];
    [self.playerLayer.player.currentItem.asset cancelLoading];
    [self.playerLayer removeFromSuperlayer];
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)noti {
    if (noti && noti.object == self.playerLayer.player.currentItem) {
        if (self.playIndex < self.viewModel.dataArr.count-1) {
            //可以播放下一条视频
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.playIndex+1] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        } else {
            //播放结束
            [self playerLayerRemoveFromSuperlayer];
        }
    }
}

#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = @"FLONETEASEVideoTableViewCell";
    FLONETEASEVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    return cell;
}

- (void)configCell:(FLONETEASEVideoTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(FLONETEASEVideoItemViewModel *)object {
    [cell bindViewModel:object];
}

- (float)heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(FLONETEASEVideoItemViewModel *)object {
    return object.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_playIndex == indexPath.section && self.playerLayer.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        //点击正在播放的视频，进入全屏继续播放
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = self.playerLayer.player;
        
        [self presentViewController:playerVC animated:YES completion:nil];
    } else {
        //切换视频
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.playIndex = indexPath.section;
    }
}

#pragma mark - scrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && !self.requesting && _playIndex >= 0) {
        float scrollHeight = scrollView.contentOffset.y;
        float scrollViewHeight = CGRectGetHeight(scrollView.frame);
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            //向上滑动了一段距离
            if (scrollHeight > 0) {
                
                //正在播放第一个
                if (_playIndex == 0) {
                    if (scrollHeight > MYAPPConfig.navigationBarHeight) {
                        FLOAsyncMainQueueBlock(^{
                            self.playIndex += 1;
                        });
                    } else {
                        //未达到一定高度，不切换视频
                    }
                } else {
                    
                    //当前播放cell的Y
                    float cellY = 8;
                    NSInteger index = _playIndex;
                    NSArray *arr = self.viewModel.dataArr;
                    for (int i = 0; i < index; i++) {
                        if (i < arr.count) {
                            FLONETEASEVideoItemViewModel *vm = [[arr objectAtIndex:i] firstObject];
                            cellY += vm.cellHeight + 9;
                        }
                    }
                    
                    if (cellY < scrollHeight) {
                        //当前播放cell向上滑出界面
                        FLOAsyncMainQueueBlock(^{
                            self.playIndex += 1;
                        });
                    } else {
                        
                        float cellBottomY = cellY;
                        {
                            FLONETEASEVideoItemViewModel *vm = [[arr objectAtIndex:index] firstObject];
                            cellBottomY += vm.cellHeight;
                        }
                        
                        //前一个cell的Y
                        float previousCellY = cellY;
                        {
                            FLONETEASEVideoItemViewModel *vm = [[arr objectAtIndex:index-1] firstObject];
                            previousCellY -= vm.cellHeight + 9;
                        }
                        
                        if (scrollHeight + scrollViewHeight < cellBottomY && scrollHeight < previousCellY) {
                            //当前播放cell向下滑出界面，并且上一个cell完全显示
                            FLOAsyncMainQueueBlock(^{
                                self.playIndex -= 1;
                            });
                        }
                    }
                }
            }
        });
    }
}

#pragma mark - refresh
- (void)headerRefreshAction {
    [super headerRefreshAction];
    
    self.requesting = YES;
    @weakify(self);
    [self.viewModel requestNewDataCompletion:^(BOOL newData) {
        @strongify(self);
        
        if (newData) {
            [self.tableView reloadData];
            
            //开始播放第一个视频
            self.playIndex = 0;
        }
        self.requesting = NO;
        self.viewModel.loading = NO;
        [self endHeaderRefresh];
    }];
}

- (void)footerRefreshAction {
    [super footerRefreshAction];
    
    self.requesting = YES;
    @weakify(self);
    [self.viewModel requestMoreDataEndRequest:^{
        @strongify(self);
        
        //接口返回结果就结束上拉状态，否则在刷新页面时会抖动
        [self endFooterRefresh];
    } completion:^(NSIndexSet *indexSet) {
        @strongify(self);
        
        if (indexSet && indexSet.count > 0) {
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.requesting = NO;
        });
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
