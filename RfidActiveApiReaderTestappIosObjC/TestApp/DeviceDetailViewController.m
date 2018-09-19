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

#import "DeviceDetailViewController.h"

@implementation DeviceDetailViewController

static NSMutableArray* _deviceCommandsMap = nil;
static NSMutableArray* _readerCommandsMap = nil;

static NSString* const operations[] = {
                        @"Select Operation",
                        @"Test Availability",
                        @"Get Clock",
                        @"Set Clock",
                        @"Read all sensors",
                        @"Enable memory erase",
                        @"Erase memory",
                        @"Seek logged data",
                        @"Get logged data (from last seek, 3 record forward)",
                        @"Enable sensor log (60s)",
                        @"Disable sensor log",
                        @"Get current log configuration",
                        @"Get measure from measuring sensor",
                        @"Read measuring sensor",
                        @"Calibrate measuring sensor",
                        @"Get calibration configuration",
                        @"Setup optical sensor (fg_level 0, fg_tol 1000, bg_level 10000)",
                        @"Read optic foreground level for seal sensor",
                        @"Read optic background level for seal sensor",
                        @"Read seal sensor status",
                        @"Get localization from localization sensor",
                        @"Read localization sensor"
                    };

static NSString* const readerCommandNames[] = {
						@"Select command",
						@"Test Availability",
						@"Do inventory",
						@"Initialize Sensors",
						@"Get firmware version",
						@"Get radio configuration",
						@"Get radio power",
						@"Set radio configuration",
						@"Set radio power",
						@"Get inventory parameters",
						@"Get inventory filter",
						@"Set inventory parameters",
						@"Set inventory filter",
						@"Unset inventory filter",
				};

static NSString* const deviceCommandNames[] = {
						@"Select command",
						@"Get firmware version",
						@"Get device radio power",
						@"Get device wakeup period",
						@"Get clock",
						@"Set clock",
						@"Read all sensors",
						@"Enable memory erase",
						@"Erase memory",
						@"Seek logged data",
						@"Get logged data (from last seek, 3 record forward)",
						@"Enable sensor log (60s)",
						@"Disable sensor log",
						@"Get current log configuration",
						@"Get measure from measuring sensor",
						@"Read measuring sensor",
						@"Calibrate measuring sensor",
						@"Get calibration configuration",
						@"Setup optical sensor (fg_level 0, fg_tol 1000, bg_level 10000)",
						@"Read optic foreground level for seal sensor",
						@"Read optic background level for seal sensor",
						@"Read seal sensor status",
						@"Get localization from localization sensor",
						@"Read localization sensor"
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    sensorTypeStrings = @{
                          @ABSTRACT_SENSOR_BATTERY_CHARGE_SENSOR: @"Battery charge sensor",
                           @ABSTRACT_SENSOR_DISPLACEMENT_TRANSDUCER_SENSOR_1: @"Displacement transducer sensor type 1",
                           @ABSTRACT_SENSOR_INTERNAL_TEMPERATURE_SENSOR_1: @"Internal temperature sensor type 1",
                           @ABSTRACT_SENSOR_EXTERNAL_TEMPERATURE_SENSOR_1: @"External temperature sensor type 1",
                           @ABSTRACT_SENSOR_OXYGEN_5_PERCENT_SENSOR: @"Oxygen sensor type (5%)",
                           @ABSTRACT_SENSOR_OXYGEN_25_PERCENT_SENSOR: @"Oxygen sensor type (25%)",
                           @ABSTRACT_SENSOR_OBSOLETE_TEMPERATUTE_SENSOR: @"Obsolete temperature sensor type",
                           @ABSTRACT_SENSOR_OPTIC_EMITTER_ON_SENSOR: @"Optic sensor type",
                           @ABSTRACT_SENSOR_OPTIC_EMITTER_OFF_OR_MAGNETIC_SENSOR: @"Optic / Magnetic sensor type",
                           @ABSTRACT_SENSOR_ELECTRONIC_SEAL_SENSOR: @"Electronic seal sensor type",
                           @ABSTRACT_SENSOR_TEMPERATURE_SENSOR: @"Temperature sensor type",
                           @ABSTRACT_SENSOR_RELATIVE_HUMIDITY_SENSOR: @"Relative humidity sensor type",
                           @ABSTRACT_SENSOR_ATMOSPHERIC_PRESSURE_SENSOR: @"Atmospheric pressure sensor type",
                           @ABSTRACT_SENSOR_PRESSURE_SENSOR: @"Pressure sensor type",
                           @ABSTRACT_SENSOR_CURRENT_SENSOR: @"Current sensor type",
                           @ABSTRACT_SENSOR_LEM_CURRENT_SENSOR: @"LEM current sensor type",
                           @ABSTRACT_SENSOR_DISPLACEMENT_TRANSDUCER_SENSOR_2: @"Displacement transducer sensor type 2",
                           @ABSTRACT_SENSOR_INTERNAL_TEMPERATURE_SENSOR_2: @"Internal temperature sensor type 2",
                           @ABSTRACT_SENSOR_EXTERNAL_TEMPERATURE_SENSOR_2: @"External temperature sensor type 2",
                           @ABSTRACT_SENSOR_LOCALIZATION_LATITUDE_SENSOR_0: @"Localization latitude sensor type",
                           @ABSTRACT_SENSOR_LOCALIZATION_LATITUDE_SENSOR_1: @"Localization latitude sensor type",
                           @ABSTRACT_SENSOR_LOCALIZATION_LONGITUDE_SENSOR_0: @"Localization longitude sensor type",
                           @ABSTRACT_SENSOR_LOCALIZATION_LONGITUDE_SENSOR_1: @"Localization longitude sensor type",
                           @ABSTRACT_SENSOR_INCLINOMETER_AXIS_X_SENSOR: @"Inclinometer axis Y sensor type",
                           @ABSTRACT_SENSOR_INCLINOMETER_AXIS_Y_SENSOR: @"Inclinometer axis X sensor type",
                           @ABSTRACT_SENSOR_PIEZOMETRIC_PRESSURE_SENSOR: @"Piezometric pressure sensor type",
                           @ABSTRACT_SENSOR_LOAD_CELL_SENSOR: @"Load cell sensor type",
    };
    
    // Do any additional setup after loading the view.
    _api = [ActiveReader getInstance];
	_eventsForwarder = [EventsForwarder getInstance];
    _eventsForwarder.inventoryListenerDelegate = self;
    _eventsForwarder.responseListenerDelegate = self;
    _eventsForwarder.readerListenerDelegate = self;

    //
    _font = [UIFont fontWithName: @"Terminal" size: 10.0];
    
    //
    _readerCommandsOutputBuffer = [NSMutableAttributedString new];
    _deviceCommandsOutputBuffer = [NSMutableAttributedString new];
    _txtReaderCommandsOutput.layer.borderColor = [[UIColor blueColor] CGColor];
    _txtReaderCommandsOutput.layer.borderWidth = 3.0;
    _txtDeviceCommandsOutput.layer.borderColor = [[UIColor blueColor] CGColor];
    _txtDeviceCommandsOutput.layer.borderWidth = 3.0;
    
    [self reset];
    [_lblDevice setText: _deviceName];
    
    //
    _inExtendedView = false;
    _connected = false;
    _inMultiCommand = false;
    _activeSensor = nil;
    _sensors = [NSMutableArray new];
    _devices = [NSMutableArray new];
    _deviceNames = [NSMutableArray new];
    
    //
    _lastCommandType = readerCommand;
    [self updateBatteryLabel];
}

-(void)dealloc
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnConnectPressed:(id)sender
{
    if (_deviceName != nil) {
        if (_connected == false) {
            [self reset];
            [_api connect: _deviceName];
            [self appendTextToBuffer: @"Connecting...." color: [UIColor whiteColor]];
        } else {
            [_api disconnect];
        }
    }
    
    [self.view endEditing:YES];
}

- (IBAction)btnStartReaderCommandPressed:(id)sender
{
    [self callReaderCommand: _selectedReaderCommand];
}

- (IBAction)btnStartDeviceCommandPressed:(id)sender
{
    [self callDeviceCommand: _selectedDeviceCommand];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// UIPickerViewDelegate, UIPickerViewDataSource protocol implementation
-(UIView*) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    
    if (!pickerLabel) {
        pickerLabel = [UILabel new];
        pickerLabel.font = _font;
        pickerLabel.textAlignment = NSTextAlignmentLeft;
    }
    
	if (pickerView == _pikSelectDevice) {
		pickerLabel.text = _deviceNames[row];
	} else if (pickerView == _pikSelectSensor) {
		pickerLabel.text = _sensors[row];
	} else if (pickerView == _pikSelectDeviceCommand) {
		pickerLabel.text = deviceCommandNames[row];
	} else if (pickerView == _pikSelectReaderCommand) {
		pickerLabel.text = readerCommandNames[row];
	}
    
    pickerLabel.textColor = [UIColor blackColor];
    return pickerLabel;
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView
{
    return 1;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (pickerView == _pikSelectDevice) {
		return _deviceNames[row];
	} else if (pickerView == _pikSelectSensor) {
		return _sensors[row];
	} else if (pickerView == _pikSelectReaderCommand) {
		return readerCommandNames[row];
	} else if (pickerView == _pikSelectDeviceCommand) {
		return deviceCommandNames[row];
	} else {
		return @"";
	}
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (pickerView == _pikSelectDevice) {
		return _deviceNames.count;
	} else if (pickerView == _pikSelectSensor) {
		return _sensors.count;
	} else if (pickerView == _pikSelectReaderCommand) {
		return sizeof(readerCommandNames) / sizeof(NSString *);
	} else if (pickerView == _pikSelectDeviceCommand) {
		return sizeof(deviceCommandNames) / sizeof(NSString *);
	} else {
		return 0;
	}
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == _pikSelectDevice) {
		if (_devices.count != 0) {
			_activeDevice = _devices[row];
			_activeDeviceIndex = (int)row;
			_activeSensor = nil;
			_activeSensorIndex = 0;
		}
	} else if (pickerView == _pikSelectReaderCommand) {
		_selectedReaderCommand = (int)row;
	} else if (pickerView == _pikSelectDeviceCommand) {
		_selectedDeviceCommand = (int)row;
	} else if (pickerView == _pikSelectSensor) {
		if (_sensors.count != 0) {
			_sensorTypeName = sensorTypeStrings[[NSNumber numberWithInteger: _sensorTypeCodes[row]]];
			_activeSensor = [_activeDevice getSensorByIndex: (int)row];
			_activeSensorIndex = (int)row;
		}
	}
}

//
-(void)enableReaderStartButton: (bool) enabled
{
    _btnStartDeviceCommand.enabled = enabled;
    if (!enabled) {
        [_btnStartDeviceCommand setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [_btnStartDeviceCommand setTitleColor: [UIColor blackColor] forState: UIControlStateSelected];
    } else {
        [_btnStartDeviceCommand setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [_btnStartDeviceCommand setTitleColor: [UIColor grayColor] forState: UIControlStateSelected];
    }
}

//
-(void)enableDeviceStartButton: (bool) enabled
{
    _btnStartDeviceCommand.enabled = enabled;
    if (!enabled) {
        [_btnStartDeviceCommand setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [_btnStartDeviceCommand setTitleColor: [UIColor blackColor] forState: UIControlStateSelected];
    } else {
        [_btnStartDeviceCommand setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [_btnStartDeviceCommand setTitleColor: [UIColor grayColor] forState: UIControlStateSelected];
    }
}

//
-(void) scrollDown: (UITextView *) textView
{
    NSRange range = NSMakeRange(textView.text.length - 1, 0);
    [textView scrollRangeToVisible: range];
}

-(void)appendReaderCommandBuffer: (NSString *) text color: (UIColor *) color
{
    [_readerCommandsOutputBuffer appendAttributedString: [[NSAttributedString alloc] initWithString: text attributes: @{ NSForegroundColorAttributeName: color }]];
    _txtReaderCommandsOutput.attributedText = [_readerCommandsOutputBuffer copy];
    [self scrollDown: _txtReaderCommandsOutput];
}

-(void)appendDeviceCommandBuffer: (NSString *) text color: (UIColor *) color
{
    [_deviceCommandsOutputBuffer appendAttributedString: [[NSAttributedString alloc] initWithString: text attributes: @{ NSForegroundColorAttributeName: color }]];
    _txtDeviceCommandsOutput.attributedText = [_deviceCommandsOutputBuffer copy];
    [self scrollDown: _txtDeviceCommandsOutput];
}

-(void)appendTextToBuffer: (NSString *) text error: (int) error
{
    NSString *fmtText;
    
    fmtText = [NSString stringWithFormat: @"%@\r\n", text];
    if (_lastCommandType == readerCommand) {
        [self appendReaderCommandBuffer: fmtText color: (error == 0 ? [UIColor whiteColor]: [UIColor redColor])];
    } else if (_lastCommandType == deviceCommand) {
        [self appendDeviceCommandBuffer: fmtText color: (error == 0 ? [UIColor whiteColor]: [UIColor redColor])];
    }
}

-(void)appendTextToBuffer: (NSString *) text color: (UIColor *) color
{
    NSString *fmtText;
    
    fmtText = [NSString stringWithFormat: @"%@\r\n", text];
    if (_lastCommandType == readerCommand) {
        [self appendReaderCommandBuffer: fmtText color: color];
    } else if (_lastCommandType == deviceCommand) {
        [self appendDeviceCommandBuffer: fmtText color: color];
    }
}

-(void)appendTextToBuffer: (NSString *) text color: (UIColor *) color command: (int) command
{
    [self appendTextToBuffer: text color: color];
}

-(void) clearInventory
{
    _firstTime = false;
    [_devices removeAllObjects];
    [_deviceNames removeAllObjects];
    [_sensors removeAllObjects];
    _activeDevice = nil;
    _activeDeviceIndex = 0;
    _activeSensor = nil;
    _activeSensorIndex = 0;
    [_pikSelectDevice reloadAllComponents];
    [_pikSelectSensor reloadAllComponents];
}

-(void)reset
{
    [_api disconnect];
    [self enableReaderStartButton: false];
    [self enableDeviceStartButton: false];
    _lastCommandType = readerCommand;
    _batteryLevel = 0;
    _batteryStatus = 0;
    _deviceAvailable = false;
    [_sensors removeAllObjects];
}

-(void)callReaderCommand: (int) method
{
    if (_btnStartReaderCommand.enabled == false) {
        return;
    }
    
    if (_readerCommandsMap == nil) {
        _readerCommandsMap = [NSMutableArray new];
        
        [_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {
            [vc enableReaderStartButton: true];
        }];
        
        // Test Availability
        [_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {
            [vc->_api testAvailability];
            [vc appendTextToBuffer: @"Test availability" color: [UIColor yellowColor]];
        }];
		
		// Do inventory
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			vc->_firstTime = true;
			[vc clearInventory];
			[vc->_api doInventory: true];
			[vc appendTextToBuffer: @"Do inventory" color: [UIColor yellowColor]];
			[vc enableReaderStartButton: true];
		}];
		
		// Initialize sensors
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			[vc->_activeDevice setTimeout: 2500];
			[vc->_activeDevice initializeSensors];
			[vc appendTextToBuffer: @"Initialize sensors" color: [UIColor yellowColor]];
		}];
		
		// Get firmware version
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			[vc->_api getFirmwareVersion];
			[vc appendTextToBuffer: @"Get firmware version" color: [UIColor yellowColor]];
		}];

		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Get radio configuration
			[vc->_api getRadioConfiguration];
			[vc appendTextToBuffer: @"Get radio configuration" color: [UIColor yellowColor]];
		}];

		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Get radio power
			[vc->_api getRadioPower];
			[vc appendTextToBuffer: @"Get radio power" color: [UIColor yellowColor]];
		}];

		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Set radio configuration
			[vc->_api setRadioConfiguration: 1234 PANid: 6501 radioChannel: 15];
			[vc appendTextToBuffer: @"Set radio configuration" color: [UIColor yellowColor]];
		}];
		
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Set radio power
			[vc->_api setRadioPower: 5];
			[vc appendTextToBuffer: @"Set radio power" color: [UIColor yellowColor]];
		}];
		
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Get inventory parameters
			[vc->_api getInventoryParameters];
			[vc appendTextToBuffer: @"Get inventory parameters" color: [UIColor yellowColor]];
		}];
		
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Get inventory filter
			[vc->_api getInventoryFilter];
			[vc appendTextToBuffer: @"Get inventory filter" color: [UIColor yellowColor]];
		}];
		
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Set inventory parameters
			[vc->_api setInventoryParameters: 10 timeout: 5000];
			[vc appendTextToBuffer: @"Set inventory parameters (10, 5000)" color: [UIColor yellowColor]];
		}];
		
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Set inventory filter
			NSArray<NSNumber *> *sensors = @[ @0x000 ];
			[vc->_api setInventoryFilter: false sensors: sensors];
			[vc appendTextToBuffer: @"Set inventory filter (permanent: false, sensors[] = 0x0000)" color: [UIColor yellowColor]];
		}];
		
		[_readerCommandsMap addObject: ^(DeviceDetailViewController*vc) {		
			// Unset inventory filter
			[vc->_api unsetInventoryFilter: false];
			[vc appendTextToBuffer: @"Unset inventory filter (permanent: false)" color: [UIColor yellowColor]];
		}];
    }
    
    _lastCommandType = readerCommand;
    [self enableReaderStartButton: false];
    void (^command)(DeviceDetailViewController*vc) = [_readerCommandsMap objectAtIndex: method];
    command(self);
}

-(void)callDeviceCommand: (int) method
{
    if (_btnStartDeviceCommand.enabled == false) {
        return;
    }
    
	if (_activeDevice == nil) {
		[self appendTextToBuffer: @"Please do inventory and select a device first!" color: [UIColor redColor]];
		return;
	}
	
    if (_deviceCommandsMap == nil) {
        _deviceCommandsMap = [NSMutableArray new];
        
		// Dummy command
        [_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
            [vc enableDeviceStartButton: true];
        }];
		
		// Get firmware version
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			[vc->_activeDevice getFirmwareVersion];
			[vc appendTextToBuffer: @"Get firmware version" color: [UIColor yellowColor]];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Get device radio power
			[vc appendTextToBuffer: @"Get device radio power" color: [UIColor yellowColor]];
            [vc appendTextToBuffer: [NSString stringWithFormat: @"Radio power %d", [vc->_activeDevice getRadioPower]] color: [UIColor whiteColor]];
			[vc enableDeviceStartButton: true];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Get device wakeup period
			[vc appendTextToBuffer: @"Get device wakeup period" color: [UIColor yellowColor]];
			[vc appendTextToBuffer: [NSString stringWithFormat: @"Wakeup period %d", [vc->_activeDevice getWakeupPeriod]] color: [UIColor whiteColor]];
			[vc enableDeviceStartButton: true];
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Get Clock
			vc->_inMultiCommand = false;
			[vc->_activeDevice getClock];
			[vc appendTextToBuffer: @"Get Clock" color: [UIColor yellowColor]];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Set Clock
			vc->_inMultiCommand = true;
			[vc->_activeDevice getClock];
			[vc appendTextToBuffer: @"Set Clock" color: [UIColor yellowColor]];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Read all sensors
			[vc->_activeDevice readAllSensors];
			[vc appendTextToBuffer: @"Read all sensors" color: [UIColor yellowColor]];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Enable memory erase
			[vc->_activeDevice enableMemoryErase];
			[vc appendTextToBuffer: @"Enable memory erase" color: [UIColor yellowColor]];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Erase memory
			[vc->_activeDevice eraseMemory];
			[vc appendTextToBuffer: @"Erase memory" color: [UIColor yellowColor]];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Seek logged data
			[vc->_activeDevice seekLoggedData: 1];
			[vc appendTextToBuffer: @"Seek logged data" color: [UIColor yellowColor]];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Get logged data
			[vc->_activeDevice getLoggedData: 3 backward: false];
			[vc appendTextToBuffer: @"Get logged data" color: [UIColor yellowColor]];
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Enable sensor log
			if (vc->_activeSensor == nil) {
				[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
			
			[vc appendTextToBuffer: @"Enable log sensor" color: [UIColor yellowColor]];
            [vc appendTextToBuffer: [NSString stringWithFormat: @"Enabling log for sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
			[vc->_activeSensor logSensor: true acquisitionPeriod: 60];
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Disable log sensor
			if (vc->_activeSensor == nil) {
				[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
			
			[vc appendTextToBuffer: @"Disable log sensor" color: [UIColor yellowColor]];
            [vc appendTextToBuffer: [NSString stringWithFormat: @"Disabling log for sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
			[vc->_activeSensor logSensor: false acquisitionPeriod: 1];
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Get current Log Configuration
			if (vc->_activeSensor == nil) {
				[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
		
			[vc appendTextToBuffer: @"Get current Log Configuration" color: [UIColor yellowColor]];
			[vc appendTextToBuffer: [NSString stringWithFormat: @"Retreiving log configuration for sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
			[vc->_activeSensor getLogConfiguration];
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			//
			[vc enableDeviceStartButton: true];

			// Get measure from measuring sensor
			if (vc->_activeSensor == nil) {
				[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
				return;
			}
			
			[vc appendTextToBuffer: @"Get measure from measuring sensor" color: [UIColor yellowColor]];
			if ([vc->_activeSensor isKindOfClass: [MeasuringSensor class]]) {
				MeasuringSensor	*sensor = (MeasuringSensor	*) vc->_activeSensor;
				if ([sensor getMeasureValidity]) {
                    [vc appendTextToBuffer: [NSString stringWithFormat: @"measure value: %f@%d", [sensor getMeasureValue], [sensor getMeasureTimestamp]] color: [UIColor whiteColor]];
				} else {
					[vc appendTextToBuffer: @"Sensor measure invalid" color: [UIColor redColor]];
				}
			} else {
				[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not measuring sensor)" color: [UIColor redColor]];
				return;
			}
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Read measuring sensor
			if (vc->_activeSensor == nil) {
				[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
			
			[vc appendTextToBuffer: @"Read measuring sensor" color: [UIColor yellowColor]];
			if ([vc->_activeSensor isKindOfClass: [MeasuringSensor class]]) {
				MeasuringSensor	*sensor = (MeasuringSensor	*) vc->_activeSensor;
				[vc appendTextToBuffer: [NSString stringWithFormat: @"Reading measuring sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
				[sensor readSensor];
			} else {
				[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not measuring sensor)" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Calibrate measuring sensor (offset 0, gain 1, scale 25)
			if (vc->_activeSensor == nil) {
				[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
			
			[vc appendTextToBuffer: @"Calibrate measuring sensor (offset 0, gain 1, scale 25)" color: [UIColor yellowColor]];
			if ([vc->_activeSensor isKindOfClass: [MeasuringSensor class]]) {
				MeasuringSensor	*sensor = (MeasuringSensor	*) vc->_activeSensor;
				[vc appendTextToBuffer: [NSString stringWithFormat: @"Calibrating measuring sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
				[sensor calibrateSensor: 0 valueGain: 1 fullScale: 25];
			} else {
				[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not measuring sensor)" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
		}];
		
		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
			// Get Calibration Configuration from Measuring Sensor
			if (vc->_activeSensor == nil) {
				[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
			
			[vc appendTextToBuffer: @"Get Calibration Configuration from Measuring Sensor" color: [UIColor yellowColor]];
			if ([vc->_activeSensor isKindOfClass: [MeasuringSensor class]]) {
				MeasuringSensor	*sensor = (MeasuringSensor	*) vc->_activeSensor;
				[vc appendTextToBuffer: [NSString stringWithFormat: @"Getting calibrationg configuration for measuring sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
				[sensor getCalibrationConfiguration];
			} else {
				[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not measuring sensor)" color: [UIColor redColor]];
				[vc enableDeviceStartButton: true];
				return;
			}
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
				// Setup optical seal sensor (fg_level 0, fg_tolerance 1000...)
				if (vc->_activeSensor == nil) {
					[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
				
				[vc appendTextToBuffer: @"Setup optical seal sensor (fg_level 0, fg_tolerance 1000...)" color: [UIColor yellowColor]];
				if ([vc->_activeSensor isKindOfClass: [SealSensor class]]) {
					SealSensor *sensor = (SealSensor *) vc->_activeSensor;
                    [vc appendTextToBuffer: [NSString stringWithFormat: @"Setting up optical seal sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
					[sensor setupOpticSeal: 0 foregroundTolerance: 1000 backgroundLevel: 10000];
				} else {
					[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not seal sensor)" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
				// Read optic foreground level for Seal Sensors
				if (vc->_activeSensor == nil) {
					[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
				
				[vc appendTextToBuffer: @"Read optic foreground level for Seal Sensors" color: [UIColor yellowColor]];
				if ([vc->_activeSensor isKindOfClass: [SealSensor class]]) {
					SealSensor *sensor = (SealSensor *) vc->_activeSensor;
                    [vc appendTextToBuffer: [NSString stringWithFormat: @"Reading optic foreground level for seal sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
					[sensor readOpticSealForeground];
				} else {
					[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not seal sensor)" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
				// Read optic background level for Seal Sensors
				if (vc->_activeSensor == nil) {
					[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
				
				[vc appendTextToBuffer: @"Read optic background level for Seal Sensors" color: [UIColor yellowColor]];
				if ([vc->_activeSensor isKindOfClass: [SealSensor class]]) {
					SealSensor *sensor = (SealSensor *) vc->_activeSensor;
                    [vc appendTextToBuffer: [NSString stringWithFormat: @"Reading optic background level for seal sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
					[sensor readOpticSealBackground];
				} else {
					[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not seal sensor)" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
				// Read seal sensor status
				if (vc->_activeSensor == nil) {
					[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
				
				[vc appendTextToBuffer: @"Read seal sensor status" color: [UIColor yellowColor]];
				if ([vc->_activeSensor isKindOfClass: [SealSensor class]]) {
					SealSensor *sensor = (SealSensor *) vc->_activeSensor;
                    [vc appendTextToBuffer: [NSString stringWithFormat: @"Reading status for seal sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
					[sensor readSeal];
				} else {
					[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not seal sensor)" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
				//
				[vc enableDeviceStartButton: true];

				// Get localization from localization sensor
				if (vc->_activeSensor == nil) {
					[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
					return;
				}
				
				[vc appendTextToBuffer: @"Get localization from localization sensor" color: [UIColor yellowColor]];
				if ([vc->_activeSensor isKindOfClass: [LocalizationSensor class]]) {
					LocalizationSensor *sensor = (LocalizationSensor *) vc->_activeSensor;
                    [vc appendTextToBuffer: [NSString stringWithFormat: @"Reading localization from localization sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
					if ([sensor getLocalizationValidity]) {
                        [vc appendTextToBuffer: [NSString stringWithFormat: @"Localization data for localization sensor: %f %f@%ul", [sensor getLatitudeValue], [sensor getLongitudeValue], [sensor getLocalizationTimestamp]] color: [UIColor whiteColor]];
					} else {
						[vc appendTextToBuffer: [NSString stringWithFormat: @"Localization error for localization sensor: %@", vc->_sensorTypeName] color: [UIColor redColor]];
					}
				} else {
					[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not localization sensor)" color: [UIColor redColor]];
					return;
				}
		}];

		[_deviceCommandsMap addObject: ^(DeviceDetailViewController*vc) {
				// Read localization sensor
				if (vc->_activeSensor == nil) {
					[vc appendTextToBuffer: @"Select a sensor first!" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
				
				[vc appendTextToBuffer: @"Read localization sensor" color: [UIColor yellowColor]];
				if ([vc->_activeSensor isKindOfClass: [LocalizationSensor class]]) {
					LocalizationSensor *sensor = (LocalizationSensor *) vc->_activeSensor;
                    [vc appendTextToBuffer: [NSString stringWithFormat: @"Reading localization sensor: %@", vc->_sensorTypeName] color: [UIColor whiteColor]];
					[sensor readLocalization];
				} else {
					[vc appendTextToBuffer: @"Invalid command for this kind of sensor (not localization sensor)" color: [UIColor redColor]];
					[vc enableDeviceStartButton: true];
					return;
				}
		}];
	}
}

-(void)updateBatteryLabel
{
    NSString *fmtText;
    
    fmtText = [NSString stringWithFormat: @"Available: %@", (_deviceAvailable ? @"yes": @"No")];
    _lblBatteryStatus.text = fmtText;
}

// AbstractInventoryListener protocol implementation
- (void)inventoryEvent:(ActiveDevice *)device
{
    [_devices addObject: device];
	[_deviceNames addObject: [device toString]];
	[_pikSelectDevice reloadAllComponents];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self->_firstTime) {
            [self appendReaderCommandBuffer: [NSString stringWithFormat: @"Found %lu devices\r\n", (unsigned long)self->_devices.count] color: [UIColor whiteColor]];
			[self->_devices[0] setTimeout: 2500];
			[self->_devices[0] initializeSensors];
			[self appendTextToBuffer: @"InitializeSensors" color: [UIColor yellowColor]];
			[self enableDeviceStartButton: true];
			self->_firstTime = false;
            self->_activeDevice = self->_devices[0];
			self->_activeDeviceIndex = 0;
		}
	});
}

// AbstractSensorListenerProtocol implementation
-(void)availabilityEvent: (bool) available
{
    _deviceAvailable = available;
    [self updateBatteryLabel];
    [self appendTextToBuffer: [NSString stringWithFormat: @"availabilityEvent %@", (available ? @"yes": @"no")] color: [UIColor whiteColor] command: ABSTRACT_READER_LISTENER_TEST_AVAILABILITY_COMMAND];
}

-(void)connectionFailureEvent: (int) error
{
    UIAlertView *alertView;
    _connected = false;
    
    alertView = [[UIAlertView alloc] initWithTitle: @"Connection failed!" message: @"error" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)connectionSuccessEvent
{
	[self appendTextToBuffer: @"Successfull connection" color: [UIColor whiteColor]];
	[self enableReaderStartButton: true];
	_connected = true;
	[_btnConnect setTitle: @"DISCONNECT" forState: UIControlStateNormal];
	
	// Initial command
	[_api setInventoryParameters: 0 timeout: 5000];
	[self appendTextToBuffer: @"setInventoryParameters(0, 5000)" color: [UIColor yellowColor]];
	
	//
	[_pikSelectDevice reloadAllComponents];
	[_pikSelectSensor reloadAllComponents];
}

-(void)disconnectionSuccessEvent
{
	[self appendTextToBuffer: @"Successfull disconnection" color: [UIColor whiteColor]];
	[self enableReaderStartButton: false];
	_connected = false;
	[_btnConnect setTitle: @"CONNECT" forState: UIControlStateNormal];
	[_devices removeAllObjects];
	[_deviceNames removeAllObjects];
	[_sensors removeAllObjects];
	[_pikSelectDevice reloadAllComponents];
	_activeSensor = nil;
}

-(void)firmwareVersionEvent: (int) major minor: (int) minor
{
    NSString *firmwareVersion;
    
    firmwareVersion = [NSString stringWithFormat: @"Firmware = %d.%d", major, minor];
    [self appendTextToBuffer: firmwareVersion color: [UIColor whiteColor]];
	[self enableDeviceStartButton: true];
}

- (void)getClockEvent:(int)deviceAddress sensorTime:(int)sensorTime systemTime:(int)systemTime 
{
    if (!_inMultiCommand) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Sensor time: %ds, System time: %ds", sensorTime, systemTime] color: [UIColor whiteColor]];
        [self enableDeviceStartButton: true];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_activeDevice setClock: systemTime+2 update_time: sensorTime+2];
        });
    }
}

- (void)getLoggedLocalizationDataEvent:(int) deviceAddress gpsError: (int)gpsError latitude:(float)latitude longitude:(float)longitude timestamp:(int)timestamp
{
    if (gpsError == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Localization logged latitude/longitude: %f/%f@%d", latitude, longitude, timestamp] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Localization logged error: %d", gpsError] color: [UIColor redColor]];
    }
    [self enableDeviceStartButton: true];
}

- (void)getLoggedMeasureDataEvent:(int) deviceAddress sensorType: (int)sensorType sensorValue:(float)sensorValue timestamp:(int)timestamp
{
	NSString *sensorName = sensorTypeStrings[[NSNumber numberWithInteger: sensorType]];
	[self appendTextToBuffer: [NSString stringWithFormat: @"Sensor %@ logged value %f@%ul", sensorName, sensorValue, timestamp] color: [UIColor whiteColor]];
	[self enableDeviceStartButton: true];
}

- (void)getLoggedSealDataEvent:(int) deviceAddress closed: (bool)closed status:(int)status timestamp:(int)timestamp
{
    [self appendTextToBuffer: [NSString stringWithFormat: @"Seal logged closed status: %d and counter: %d@%d", closed, status, timestamp] color: [UIColor whiteColor]];
    [self enableDeviceStartButton: true];
}

-(void)resultEvent: (int) command error: (int) error
{
    NSString *result, *errStr;
    errStr = (error == 0 ? @"NO error": [NSString stringWithFormat: @"Error %d", error]);
    result = [NSString stringWithFormat: @"Result command = %d %@", command, errStr];
    [self appendTextToBuffer: result error: error];
    if (_inMultiCommand) {
        if (command == 7) {
            _inMultiCommand = false;
            [self enableDeviceStartButton: true];
        }
    } else {
        if (_lastCommandType == readerCommand) {
			[self enableReaderStartButton: true];
		} else if (_lastCommandType == deviceCommand) {
			[self enableDeviceStartButton: true];
		}
	}
	
	if (_lastCommandType == readerCommand && command == ABSTRACT_READER_LISTENER_INITIALIZE_SENSORS_COMMAND && error == 0) {
		ActiveDevice* device;
		
		//
		[self appendTextToBuffer: [NSString stringWithFormat: @"%d sensors found", [device getSensorsNumber]] color: [UIColor whiteColor]];
		_sensorTypeCodes = [device getSensorsTypes];
		[_sensors removeAllObjects];
		for (int i = 0; i < [device getSensorsNumber]; i++) {
			NSString *sensorType = sensorTypeStrings[[NSNumber numberWithInteger: _sensorTypeCodes[i]]];
			[self appendTextToBuffer: [NSString stringWithFormat: @"Found %@", sensorType] color: [UIColor whiteColor]];
            [_sensors addObject: sensorType];
		}
		
		if ([device getSensorsNumber] > 0) {
			_activeSensor = [device getSensorByIndex: 0];
			_sensorTypeName = sensorTypeStrings[[NSNumber numberWithInteger: _sensorTypeCodes[0]]];
		}
		
		[_pikSelectSensor reloadAllComponents];
	}
}

- (void)getDeviceFirmwareVersionEvent:(int)major minor:(int)minor
{
    [self appendTextToBuffer: [NSString stringWithFormat: @"Device firmware version %d.%d", major, minor] color: [UIColor whiteColor]];
}

- (void)getInventoryFilterEvent:(int)number sensors:(NSArray<NSNumber*> *)sensors
{
    if (sensors != nil) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Inventory filter number: %d sensors: %lu", number, (unsigned long)sensors.count] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Inventory filter number: %d sensors: <nil>", number] color: [UIColor whiteColor]];
    }
}

- (void)getInventoryParametersEvent:(int)mode maxNumber:(int)maxNumber timeout:(int)timeout
{
    [self appendTextToBuffer: [NSString stringWithFormat: @"Inventory parameters mode: %d maxNumber: %d timeout: %d", mode, maxNumber, timeout] color: [UIColor whiteColor]];
}

- (void)getRadioConfigurationEvent:(int)readerAddress panID:(int)panID radioChannel:(int)radioChannel
{
    [self appendTextToBuffer: [NSString stringWithFormat: @"Radio configuration, readerAddress: %d panID: %d radioChannel: %d", readerAddress, panID, radioChannel] color: [UIColor whiteColor]];
}

- (void)getReaderFirmwareVersionEvent:(int)major minor:(int)minor
{
    [self appendTextToBuffer: [NSString stringWithFormat: @"Reader firmware version %d.%d", major, minor] color: [UIColor whiteColor]];
}

- (void)getReaderRadioPowerEvent:(int)radioPower
{
    [self appendTextToBuffer: [NSString stringWithFormat: @"Reader radio power: %d", radioPower] color: [UIColor whiteColor]];
}


// AbstractResponseListenerProtocol
- (void)calibrateSensorEvent:(int) deviceAddress sensorType: (int)sensorType error:(int)error
{
	NSString *sensorTypeName = sensorTypeStrings[[NSNumber numberWithInteger: sensorType]];
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
		[self appendTextToBuffer: [NSString stringWithFormat: @"Calibrate sensor %@ success", sensorTypeName] color: [UIColor whiteColor]];
	} else {
		[self appendTextToBuffer: [NSString stringWithFormat: @"Calibrate sensor %@ error: %d", sensorTypeName, error] color: [UIColor redColor]];
	}
	
	[self enableDeviceStartButton: true];
}

- (void)getCalibrationConfigurationEvent:(int) deviceAddress sensorType: (int)sensorType error:(int)error uncalibratedRawValue:(int)uncalibratedRawValue valueOffset:(int)valueOffset valueGain:(float)valueGain fullScale:(int)fullScale
{
	NSString *sensorTypeName = sensorTypeStrings[[NSNumber numberWithInteger: sensorType]];
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Calibration configuration sensor %@ uncalibratedRawValue: %d valueOffset: %d valueGain: %f fullScale: %d", sensorTypeName, uncalibratedRawValue, valueOffset, valueGain, fullScale] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Calibration configuration sensor %@ error: %d", sensorTypeName, error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)getLogConfigurationEvent:(int) deviceAddress sensorType: (int)sensorType error:(int)error logEnable:(bool)logEnable logPeriod:(int)logPeriod
{
	NSString *sensorTypeName = sensorTypeStrings[[NSNumber numberWithInteger: sensorType]];
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Log configuration sensor %@ enabled: %@ with period: %d", sensorTypeName, (logEnable == true ? @"true": @"false"), logPeriod] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Log configuration sensor %@ error: %d", sensorTypeName, error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)logSensorEvent:(int)deviceAddress sensorType: (int)sensorType error:(int)error
{
	NSString *sensorTypeName = sensorTypeStrings[[NSNumber numberWithInteger: sensorType]];
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Log sensor %@ success", sensorTypeName] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Log sensor %@ error: %d", sensorTypeName, error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)readLocalizationEvent:(int)deviceAddress error: (int)error latitude:(float)latitude longitude:(float)longitude timestamp:(int)timestamp
{
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Read localization latitude/longitude: %f/%f@%d", latitude, longitude, timestamp] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Read localization error: %d", error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)readMagneticSealStatusEvent:(int)deviceAddress error: (int)error status:(int)status
{
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Magnetic seal status: %d", status] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Magnetic seal status error: %d", error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)readOpticSealBackgroundEvent:(int)deviceAddress error: (int)error backgroundLevel:(int)backgroundLevel
{
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Optical seal background level: %d", backgroundLevel] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Optical seal read background level error: %d", error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)readOpticSealForegroundEvent:(int) deviceAddress error: (int)error foregroundLevel:(int)foregroundLevel
{
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Optical seal foreground level: %d", foregroundLevel] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Optical seal read foreground level error: %d", error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)readSealEvent:(int) deviceAddress error: (int)error closed:(bool)closed status:(int)status
{
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        if (closed == true) {
            [self appendTextToBuffer: [NSString stringWithFormat: @"status closed@%d", status] color: [UIColor whiteColor]];
        } else {
            [self appendTextToBuffer: [NSString stringWithFormat: @"status open@%d", status] color: [UIColor whiteColor]];
        }
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"status read error: %d", error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)readSensorEvent:(int) deviceAddress sensorType: (int)sensorType error:(int)error sensorValue:(float)sensorValue timestamp:(int)timestamp
{
	NSString *sensorTypeName = sensorTypeStrings[[NSNumber numberWithInteger: sensorType]];
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Read sensor %@ value: %f@%d", sensorTypeName, sensorValue, timestamp] color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Read sensor %@ error: %d", sensorTypeName, error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

- (void)setupSealEvent:(int) deviceAddress error: (int)error
{
    if (error == ABSTRACT_READER_LISTENER_NO_ERROR) {
        [self appendTextToBuffer: @"Setup seal successfull" color: [UIColor whiteColor]];
    } else {
        [self appendTextToBuffer: [NSString stringWithFormat: @"Setup seal sensor error: %d", error] color: [UIColor redColor]];
    }
    
	[self enableDeviceStartButton: true];
}

//
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC
{
    [_api disconnect];
    
	_eventsForwarder.inventoryListenerDelegate = nil;
    _eventsForwarder.readerListenerDelegate = nil;
    _eventsForwarder.responseListenerDelegate = nil;
}

-(IBAction)unwindToDeviceDetailViewController:(UIStoryboardSegue *) unwindSegue
{
	_eventsForwarder.inventoryListenerDelegate = self;
    _eventsForwarder.readerListenerDelegate = self;
    _eventsForwarder.responseListenerDelegate = self;
    
    _inExtendedView = false;
    if (_connected) {
        [self enableDeviceStartButton: true];
    }
}

@end
