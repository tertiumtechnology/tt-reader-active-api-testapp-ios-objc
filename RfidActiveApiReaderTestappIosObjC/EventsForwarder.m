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

#import "EventsForwarder.h"

@implementation EventsForwarder

static EventsForwarder *_sharedInstance;

-(id)init
{
    self = [super init];
    if (self) {
        _api = [ActiveReader getInstance];
        _api.responseListenerDelegate = self;
        _api.readerListenerDelegate = self;
    }
    
    return self;
}

+(EventsForwarder *_Nonnull) getInstance
{
    if (_sharedInstance == nil) {
        _sharedInstance = [EventsForwarder new];
    }
    
    return _sharedInstance;
}

// AbstractResponseListenerProtocol protocol
-(void)calibrateSensorEvent: (int) deviceAddress sensorType: (int) sensorType error: (int) error
{
    [_responseListenerDelegate calibrateSensorEvent: (int) deviceAddress sensorType: (int)sensorType error: error];
}

-(void)getCalibrationConfigurationEvent: (int) deviceAddress sensorType: (int) sensorType error: (int) error uncalibratedRawValue: (int) uncalibratedRawValue valueOffset: (int) valueOffset valueGain: (float) valueGain fullScale: (int) fullScale
{
    [_responseListenerDelegate getCalibrationConfigurationEvent: (int) deviceAddress sensorType: sensorType error: error uncalibratedRawValue: uncalibratedRawValue valueOffset: valueOffset valueGain: valueGain fullScale: fullScale];
}

-(void)getLogConfigurationEvent: (int) deviceAddress sensorType: (int) sensorType error: (int) error logEnable: (bool) logEnable logPeriod: (int) logPeriod
{
    [_responseListenerDelegate getLogConfigurationEvent: deviceAddress sensorType: (int) sensorType error: error logEnable: logEnable logPeriod: logPeriod];
}

-(void)logSensorEvent: (int) deviceAddress sensorType: (int) sensorType error: (int) error
{
    [_responseListenerDelegate logSensorEvent: (int) deviceAddress sensorType: (int) sensorType error: error];
}

-(void)readLocalizationEvent: (int) deviceAddress error: (int) error latitude: (float) latitude longitude: (float) longitude timestamp: (int) timestamp
{
    [_responseListenerDelegate readLocalizationEvent: deviceAddress error: error latitude: latitude longitude: longitude timestamp: timestamp];
}

-(void)readMagneticSealStatusEvent: (int) deviceAddress error: (int) error status: (int) status
{
    [_responseListenerDelegate readMagneticSealStatusEvent: deviceAddress error: error status: status];
}

-(void)readOpticSealBackgroundEvent: (int) deviceAddress error: (int) error backgroundLevel: (int) backgroundLevel
{
    [_responseListenerDelegate readOpticSealBackgroundEvent: deviceAddress error: error backgroundLevel: backgroundLevel];
}

-(void)readOpticSealForegroundEvent: (int) deviceAddress error: (int) error foregroundLevel: (int) foregroundLevel
{
    [_responseListenerDelegate readOpticSealForegroundEvent: deviceAddress error: error foregroundLevel: foregroundLevel];
}

-(void)readSealEvent: (int) deviceAddress error: (int) error closed: (bool) closed status: (int) status
{
    [_responseListenerDelegate readSealEvent: deviceAddress error: error closed: closed status: status];
}

-(void)readSensorEvent: (int) deviceAddress sensorType: (int) sensorType error: (int) error sensorValue: (float) sensorValue timestamp: (int) timestamp
{
    [_responseListenerDelegate readSensorEvent: deviceAddress sensorType: sensorType error: error sensorValue: sensorValue timestamp: timestamp];
}

-(void) setupSealEvent: (int) deviceAddress error: (int) error
{
    [_responseListenerDelegate setupSealEvent: deviceAddress error: error];
}

// AbstractReaderListenerProtocol
-(void)availabilityEvent: (bool) available
{
    [_readerListenerDelegate availabilityEvent: available];
}

-(void)connectionFailureEvent: (int) error
{
    [_readerListenerDelegate connectionFailureEvent: error];
}

-(void)connectionSuccessEvent
{
    [_readerListenerDelegate connectionSuccessEvent];
}

-(void)disconnectionSuccessEvent
{
    [_readerListenerDelegate disconnectionSuccessEvent];
}

-(void)getReaderFirmwareVersionEvent: (int) major minor: (int) minor
{
    [_readerListenerDelegate getReaderFirmwareVersionEvent: major minor: minor];
}

-(void)getDeviceFirmwareVersionEvent: (int) major minor: (int) minor
{
    [_readerListenerDelegate getDeviceFirmwareVersionEvent: major minor: minor];
}

-(void)getClockEvent: (int) deviceAddress sensorTime: (int) sensorTime systemTime: (int) systemTime
{
    [_readerListenerDelegate getClockEvent: deviceAddress sensorTime: sensorTime systemTime: systemTime];
}

-(void) getLoggedLocalizationDataEvent: (int) deviceAddress gpsError: (int) gpsError latitude: (float) latitude longitude: (float) longitude timestamp: (int) timestamp
{
    [_readerListenerDelegate getLoggedLocalizationDataEvent: deviceAddress gpsError: gpsError latitude: latitude longitude: longitude timestamp: timestamp];
}

-(void)getLoggedMeasureDataEvent: (int) deviceAddress sensorType: (int) sensorType sensorValue: (float) sensorValue timestamp: (int) timestamp
{
    [_readerListenerDelegate getLoggedMeasureDataEvent: deviceAddress sensorType: sensorType sensorValue: sensorValue timestamp: timestamp];
}

-(void)getLoggedSealDataEvent: (int) deviceAddress  closed: (bool) closed status: (int) status timestamp: (int) timestamp
{
    [_readerListenerDelegate getLoggedSealDataEvent: deviceAddress closed: closed status: status timestamp: timestamp];
}

-(void)resultEvent: (int) command error: (int) error
{
    [_readerListenerDelegate resultEvent: command error: error];
}

- (void)getInventoryFilterEvent:(int)number sensors:(NSArray<NSNumber *> *)sensors
{
    [_readerListenerDelegate getInventoryFilterEvent: number sensors: sensors];
}

- (void)getInventoryParametersEvent:(int)mode maxNumber:(int)maxNumber timeout:(int)timeout
{
    [_readerListenerDelegate getInventoryParametersEvent: mode maxNumber: maxNumber timeout: timeout];
}

-(void) getRadioConfigurationEvent: (int) readerAddress panID: (int) panID radioChannel: (int) radioChannel
{
    [_readerListenerDelegate getRadioConfigurationEvent: readerAddress panID: panID radioChannel: radioChannel];
}

- (void)getReaderRadioPowerEvent:(int)radioPower
{
    [_readerListenerDelegate getReaderRadioPowerEvent: radioPower];
}

@end
