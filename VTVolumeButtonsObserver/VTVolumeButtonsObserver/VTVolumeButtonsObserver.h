//
//  VTVolumeButtonsObserver.h
//  VTVolumeButtonsObserver
//
//  Created by Vitaly Timofeev on 05/06/15.
//  Copyright (c) 2015 Vitaly Timofeev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VTVolumeButtonsObserverBlock)(void);

@interface VTVolumeButtonsObserver : NSObject

+ (instancetype)observerWithUpButtonBlock:(VTVolumeButtonsObserverBlock)upButtonBlock downButtonBlock:(VTVolumeButtonsObserverBlock)dowbButtonBlock;

@end
