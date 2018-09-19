/*
 * The MIT License
 *
 * Copyright 2017 Tertium Technology.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import <TxRxLib/TxRxLib.h>
#import <RfidActiveApiReaderLibObjC/RfidActiveApiReaderLibObjC.h>
#import "EventsForwarder.h"

@class Core;

typedef enum CommandType: int {
    noCommand = 0
    ,readerCommand
    ,deviceCommand
} CommandType;

@interface DeviceDetailViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,  AbstractResponseListenerProtocol, AbstractReaderListenerProtocol, AbstractInventoryListenerProtocol>
{
    @public
    ActiveReader *_api;
    EventsForwarder *_eventsForwarder;
    UIFont *_font;

    NSDictionary* sensorTypeStrings;

    NSMutableArray<NSString *> *_sensors;
    NSMutableArray<ActiveDevice*> *_devices;
    NSMutableArray<NSString *> *_deviceNames;

    float _batteryLevel;
    NSInteger _batteryStatus;
    bool _deviceAvailable;

    CommandType _lastCommandType;
    bool _connected;
    bool _inExtendedView;
    int _selectedReaderCommand;
    int _selectedDeviceCommand;
    ActiveDevice* _activeDevice;
    int _activeDeviceIndex;
    AbstractSensor* _activeSensor;
    int _activeSensorIndex;
    int *_sensorTypeCodes;
    NSString *_sensorTypeName;
    bool _inMultiCommand;
    bool _firstTime;
    
    NSString *_deviceName;

    NSMutableAttributedString *_readerCommandsOutputBuffer;
    NSMutableAttributedString *_deviceCommandsOutputBuffer;
}

@property (nonatomic, retain) NSString *deviceName;

@property (weak, nonatomic) IBOutlet UILabel *lblDevice;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UIPickerView *pikSelectReaderCommand;
@property (weak, nonatomic) IBOutlet UIButton *btnStartReaderCommand;
@property (weak, nonatomic) IBOutlet UITextView *txtReaderCommandsOutput;
@property (weak, nonatomic) IBOutlet UIPickerView *pikSelectDevice;
@property (weak, nonatomic) IBOutlet UIPickerView *pikSelectSensor;
@property (weak, nonatomic) IBOutlet UIPickerView *pikSelectDeviceCommand;
@property (weak, nonatomic) IBOutlet UIButton *btnStartDeviceCommand;
@property (weak, nonatomic) IBOutlet UITextView *txtDeviceCommandsOutput;
@property (weak, nonatomic) IBOutlet UILabel *lblBatteryStatus;

- (IBAction)btnConnectPressed:(id)sender;
-(void)appendTextToBuffer: (NSString *) text error: (int) error;
-(void)appendTextToBuffer: (NSString *) text color: (UIColor *) color;


@end
