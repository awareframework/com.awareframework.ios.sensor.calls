# Aware Calls

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.calls.svg?style=flat)](https://travis-ci.org/awareframework/com.awareframework.ios.sensor.calls)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.calls.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.calls)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.calls.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.calls)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.calls.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.calls)

The Calls sensor logs call events performed by or received by the user. It also provides higher level context on the users’ calling availability and actions.

## Requirements
iOS 10 or later

## Installation

1. com.awareframework.ios.sensor.calls is available through [CocoaPods](https://cocoapods.org).  To install it, simply add the following line to your Podfile:
```ruby
pod 'com.awareframework.ios.sensor.calls'
```
2. Import com.awareframework.ios.sensor.calls library into your source code.
```swift
import com_awareframework_ios_sensor_calls
```

## Public functions

### CallsSensor

* `init(config:CallsSensor.Config?)` : Initializes the calls sensor with the optional configuration.
* `start()`: Starts the gyroscope sensor with the optional configuration.
* `stop()`: Stops the service.

## Broadcasts

### Fired Broadcasts

+ `CallsSensor.ACTION_AWARE_CALL_ACCEPTED`: fired when the user accepts an incoming call.
+ `CallsSensor.ACTION_AWARE_CALL_RINGING`: fired when the phone is ringing.
+ `CallsSensor.ACTION_AWARE_CALL_MADE`: fired when the user is making a call.
+ `CallsSensor.ACTION_AWARE_USER_IN_CALL`: fired when the user is currently in a call.
+ `CallsSensor.ACTION_AWARE_USER_NOT_IN_CALL`: fired when the user is not in a call.

### Received Broadcasts

+ `CallsSensor.ACTION_AWARE_CALLS_START`: received broadcast to start the sensor.
+ `CallsSensor.ACTION_AWARE_CALLS_STOP`: received broadcast to stop the sensor.
+ `CallsSensor.ACTION_AWARE_CALLS_SYNC`: received broadcast to send sync attempt to the host.
+ `CallsSensor.ACTION_AWARE_CALLS_SET_LABEL`: received broadcast to set the data label. Label is expected in the `CallsSensor.EXTRA_LABEL` field of the intent extras.

## Data Representations

### Call Data

Contains the calls sensor information.

| Field          | Type   | Description                                                     |
| -------------- | ------ | --------------------------------------------------------------- |
| eventTimestamp | Long   | unixtime miliseconds of the actual event                        |
| type           | String | one of call types (dialing, incoming, connected, and disconnected)|
| attributes     | String | a [call event attibutes](https://developer.apple.com/documentation/callkit/cxcall)|
| duration       | Int    | length of the call session                                      |
| trace          | String | source/target of the call                                       |
| deviceId       | String | AWARE device UUID                                               |
| label          | String | Customizable label. Useful for data calibration or traceability |
| timestamp      | Long   | unixtime milliseconds since 1970                                |
| timezone       | Int    | Timezone of the device                          |
| os             | String | Operating system of the device (ex. android)                    |

## Example Usage
```swift
let callsSensor = CallsSensor.init(CallsSensor.Config().apply{config in
    config.debug = true
    config.sensorObserver = Observer()
    config.dbType = .REALM
})
callsSensor?.start()
callsSensor?.stop()
```
```swift
class Observer:CallsObserver{
    func onCall(data: CallData) {
        // Your code here..
    }

    func onRinging(number: String?) {
        // Your code here..
    }

    func onBusy(number: String?) {
        // Your code here..
    }

    func onFree(number: String?) {
        // Your code here..
    }
}
```

## Author

Yuuki Nishiyama, yuuki.nishiyama@oulu.fi

## Related Links
* [ Apple | CXCall ](https://developer.apple.com/documentation/callkit/cxcall)

## License

Copyright (c) 2018 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
