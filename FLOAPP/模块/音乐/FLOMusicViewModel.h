//
//  FLOMusicViewModel.h
//  FLOAPP
//
//  Created by 沈敏 on 2018/5/8.
//  Copyright © 2018年 Flolangka. All rights reserved.
//

#import "FLOTableViewModel.h"

@interface FLOMusicViewModel : FLOTableViewModel

//播放状态：0未播放，1正播放
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) float playProgress;

//播放形式：顺序、随机、单曲
@property (nonatomic, assign) NSInteger playModus;

/*
 排序方法：
 CoreData 加一排序字段，排序时记录改变的最小最大位置，重置中间的数据排序字段值
 
 字段：
 name
 author
 album  专辑
 duration   时长
 url
 fileName   (下载完成的代理中更新，如果vc被提前释放，则在播放时通过url查询downloadfile表的savePath获得，注意：未下载成功时savePath为保存文件夹)
 sortIndex
 
 
 下载： 专门的保存文件夹
 FLODownloadManager 下载
 */



@end
