//
//  VisaInstrument.h
//  NITool
//
//  Created by WeidongCao on 2020/5/20.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface VisaInstrument : NSObject
-(NSArray *)scanInstruments;
//addr: ASRL[0-9]*::?*INSTR baud: 9600 timeout: 3000 -> 3s
-(BOOL)openWithAddress:(NSString *)addr baudrate:(int )baud timeout:(int )to;
-(void)closeInstrument;
-(void)releaseResources;
//cmd: @"*IDN?"
-(void)sendCommand:(NSString *)cmd error:(NSError **)err;
-(NSString *)query:(NSString *)cmd error:(NSError **)err;

@end

NS_ASSUME_NONNULL_END
