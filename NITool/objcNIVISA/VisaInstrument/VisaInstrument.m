//
//  VisaInstrument.m
//  NITool
//
//  Created by WeidongCao on 2020/5/20.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "VisaInstrument.h"
#import "nivisaObjC.h"
@interface VisaInstrument()

@property int instrFileDescription;
@property BOOL resourceIsOpened;
@end

@implementation VisaInstrument
-(instancetype)init{
    if (self = [super init]) {
        self.instrFileDescription = -1;
        self.resourceIsOpened = NO;
        int status = openVISArm();
        if (status == VI_SUCCESS) {
            self.resourceIsOpened = YES;
        }
    }
    return self;
}
-(NSArray *)scanInstruments{
    if (self.resourceIsOpened == NO) {
        int status = openVISArm();
        if (status != VI_SUCCESS) {
            return @[];
        }else{
            self.resourceIsOpened = YES;
        }
    }
    return findAllDevices();
}
//addr: ASRL[0-9]*::?*INSTR baud: 9600 timeout: 3000 -> 3s
-(BOOL)openWithAddress:(NSString *)addr baudrate:(int )baud timeout:(int )to{
    if (self.resourceIsOpened == NO) {
        int status = openVISArm();
        if (status != VI_SUCCESS) {
            return NO;
        }else{
            self.resourceIsOpened = YES;
        }
    }
    self.instrFileDescription = openDevice(addr, baud, to);
    if (self.instrFileDescription == -1) {
        return NO;
    }
    return YES;
}
-(void)closeInstrument{
    int status = closeDevice(self.instrFileDescription);
}
-(void)releaseResources{
    int status = closeVISArm();
}
//cmd: @"*IDN?"
-(void)sendCommand:(NSString *)cmd error:(NSError **)err{
    *err = NULL;
    int status = writeDevice(self.instrFileDescription, cmd);
    if (status != VI_SUCCESS) {
        *err = [[NSError alloc] initWithDomain:@"com.visainstrument.sendcommand" code:0x40 userInfo:@{NSLocalizedDescriptionKey:@"send command error"}];
    }
}
-(NSString *)query:(NSString *)cmd error:(NSError **)err{
    *err = NULL;
    int status = writeDevice(self.instrFileDescription, cmd);
    if (status != VI_SUCCESS) {
        *err = [[NSError alloc] initWithDomain:@"com.visainstrument.sendcommand" code:0x40 userInfo:@{NSLocalizedDescriptionKey:@"send command error"}];
        return @"";
    }
    
    return readDevice(self.instrFileDescription);
}
@end
