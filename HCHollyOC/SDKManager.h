//
//  SDKManager.h
//  HCHollyOC
//
//  Created by linlc on 2023/12/5.
//  Copyright © 2023 loganv. All rights reserved.
//

#ifndef SDKManager_h
#define SDKManager_h

@interface SDKManager

+(SDKManager*)shareManager;
-(void)enterVideoRoomWithA6Params:(NSDictionary*)param;

@end

#endif /* SDKManager_h */
