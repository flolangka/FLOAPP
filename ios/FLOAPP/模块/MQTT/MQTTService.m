//
//  MQTTService.m
//  FLOAPP
//
//  Created by 沈敏 on 2017/1/7.
//  Copyright © 2017年 Flolangka. All rights reserved.
//

#import "MQTTService.h"
#import <MQTTClient.h>

@interface MQTTService () <MQTTSessionDelegate>

{
    MQTTSession *session;
}

@end

static MQTTService *myService;

@implementation MQTTService

+ (instancetype)shareService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myService = [[MQTTService alloc] init];
        
        myService -> session = [[MQTTSession alloc] init];
        myService -> session.delegate = myService;
        
        // 设置服务器
        MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
        transport.host = @"";
        transport.port = 8888;
        myService -> session.transport = transport;
        
        // 设置连接标识
        NSDictionary *dic = @{@"diviceid": [[UIDevice currentDevice] identifierForVendor].UUIDString,
                              @"time": @"",
                              @"clienttype": @"2",
                              @"vercode": @"34",
                              @"usercode": @"ReeocBp+ttzTQyU0rhzbgWxGq8kn2WMG12GOc/4S4ztsB8O70SQ8r/i+kp9lQ/oq"};
        myService -> session.clientId = [dic flo_JSONString];
        
//        [[NSNotificationCenter defaultCenter] addObserver:myService selector:@selector(DeviceGetNetworkChangeedNotification:) name:DEVICE_NETWORK_CHANGE_NOTIFICATION object:[UIApplication sharedApplication]];
    });
    return myService;
}

- (void)connectToServer {
    if (session.status == MQTTSessionStatusConnected || session.status == MQTTSessionStatusConnecting) {
        [self close];
    } else {
        [session connectAndWaitTimeout:30];
    }
}

- (void)close {
    [session close];
}

#pragma mark - 代理
- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    // this is one of the delegate callbacks
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error {
    
    NSString *str;
    switch (eventCode) {
        case MQTTSessionEventConnected:
            str = @"Connection Connected";
            break;
        case MQTTSessionEventProtocolError:
            str = @"Protocol Error";
            break;
        case MQTTSessionEventConnectionError:
            str = @"Connection Error";
            break;
        case MQTTSessionEventConnectionClosed:
            str = @"Connection Closed";
            break;
        case MQTTSessionEventConnectionRefused:
            str = @"Connection Refused";
            break;
        case MQTTSessionEventConnectionClosedByBroker:
            str = @"Connection Closed By Broker";
            break;
        default:
            break;
    }
    
    if (str && _eventAction) {
        _eventAction(eventCode, str);
    }
}

@end
