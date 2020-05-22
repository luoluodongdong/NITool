//
//  PanelViewController.m
//  NITool
//
//  Created by WeidongCao on 2020/5/19.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "PanelViewController.h"
#import "VisaInstrument.h"

@interface PanelViewController ()

@property VisaInstrument *instrument;
@property dispatch_queue_t printLogQueue;
@end

@implementation PanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [baudArrayBtn removeAllItems];
    [baudArrayBtn addItemsWithTitles:@[@"9600",@"115200",@"230400"]];
    [addressArrayBtn removeAllItems];
    self.printLogQueue = dispatch_queue_create("com.nivisatool.pringlogqueue", DISPATCH_QUEUE_SERIAL);
    
}
-(void)viewWillAppear{
    
}
-(void)viewDidAppear{
    self.instrument = [[VisaInstrument alloc] init];
    NSArray *array = [self.instrument scanInstruments];
    [addressArrayBtn addItemsWithTitles:array];
}
-(IBAction)scanBtnAction:(id)sender{
    [addressArrayBtn removeAllItems];
    NSArray *array = [self.instrument scanInstruments];
    [addressArrayBtn addItemsWithTitles:array];
}
-(IBAction)openBtnAction:(id)sender{
    if ([openBtn.title isEqualToString:@"Open"]) {
        if ([[addressArrayBtn itemTitles] count] == 0) {
            return;
        }
        NSString *address = [[addressArrayBtn selectedItem] title];
        int baudrate = [[[baudArrayBtn selectedItem] title] intValue];
        int timeout = [timeoutField intValue];
        [NSThread detachNewThreadWithBlock:^{
            BOOL status = [self.instrument openWithAddress:address baudrate:baudrate timeout:timeout];
            if (status) {
                dispatch_async(self.printLogQueue, ^{
                    [self performSelectorOnMainThread:@selector(updateLog:) withObject:@"opened successfully!" waitUntilDone:YES];
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->scanBtn setEnabled:NO];
                    [self->addressArrayBtn setEnabled:NO];
                    [self->baudArrayBtn setEnabled:NO];
                    [self->timeoutField setEnabled:NO];
                    [self->openBtn setTitle:@"Close"];
                });
            }else{
                dispatch_async(self.printLogQueue, ^{
                    [self performSelectorOnMainThread:@selector(updateLog:) withObject:@"open fail!" waitUntilDone:YES];
                });
            }
        }];
    }else{
        [self.instrument closeInstrument];
        [scanBtn setEnabled:YES];
        [addressArrayBtn setEnabled:YES];
        [baudArrayBtn setEnabled:YES];
        [timeoutField setEnabled:YES];
        [openBtn setTitle:@"Open"];
    }
}
-(void)dealloc{
    [self.instrument releaseResources];
}
-(IBAction)sendBtnAction:(id)sender{
    NSString *cmd = [inputTextView.textStorage string];
    if ([cmd length] == 0) {
        return;
    }
    NSString *log = [NSString stringWithFormat:@"[TX]%@",cmd];
    dispatch_async(self.printLogQueue, ^{
        [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
    });
    [sendBtn setEnabled:NO];
    [NSThread detachNewThreadWithBlock:^{
        NSError *err = nil;
        NSString *response = [self.instrument query:cmd error:&err];
        if (err == nil) {
            NSString *log = [NSString stringWithFormat:@"[RX]%@",response];
            dispatch_async(self.printLogQueue, ^{
                [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
            });
        }else{
            dispatch_async(self.printLogQueue, ^{
                [self performSelectorOnMainThread:@selector(updateLog:) withObject:[err localizedDescription] waitUntilDone:YES];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->sendBtn setEnabled:YES];
        });
    }];
    
}
-(IBAction)clearBtnAction:(id)sender{
    logTextView.string = @"";
}
-(void)updateLog:(NSString *)log{
    NSUInteger textLen = self->logTextView.textStorage.length;
        if (textLen > 500000) {
            [self->logTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
        }
    NSMutableString *logStr = [NSMutableString string];
    NSString *dateText = @"";
    //time
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yy/MM/dd HH:mm:ss.SSS "];
    dateText=[dateFormat stringFromDate:[NSDate date]];
    [logStr appendFormat:@"%@%@\r\n",dateText,log];
        // 设置字体颜色NSForegroundColorAttributeName，取值为 UIColor对象，默认值为黑色
        NSMutableAttributedString *textColor = [[NSMutableAttributedString alloc] initWithString:logStr];
    //        [textColor addAttribute:NSForegroundColorAttributeName
    //                          value:[NSColor greenColor]
    //                          range:[@"NSAttributedString设置字体颜色" rangeOfString:@"NSAttributedString"]];
        [textColor addAttribute:NSForegroundColorAttributeName
                          value:[NSColor systemGreenColor]
                          range:NSMakeRange(0, logStr.length)];
        
        //NSAttributedString *attrStr=[[NSAttributedString alloc] initWithString:self.logString];
        textLen = textLen + logStr.length;
        [self->logTextView.textStorage appendAttributedString:textColor];
        [self->logTextView scrollRangeToVisible:NSMakeRange(textLen,0)];
}
@end
