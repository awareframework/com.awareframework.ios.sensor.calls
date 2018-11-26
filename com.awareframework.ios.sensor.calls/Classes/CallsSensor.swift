//
//  CallsSensor.swift
//  com.aware.ios.sensor.calls
//
//  Created by Yuuki Nishiyama on 2018/10/24.
//

import UIKit
import CallKit
import com_awareframework_ios_sensor_core

extension Notification.Name {
    public static let actionAwareCallsStart    = Notification.Name(CallsSensor.ACTION_AWARE_CALLS_START)
    public static let actionAwareCallsStop    = Notification.Name(CallsSensor.ACTION_AWARE_CALLS_STOP)
    public static let actionAwareCallsSync    = Notification.Name(CallsSensor.ACTION_AWARE_CALLS_SYNC)
    public static let actionAwareCallsSetLabel = Notification.Name(CallsSensor.ACTION_AWARE_CALLS_SET_LABEL)
    
    // TODO: check all of actions
    public static let actionAwareCallAccepted = Notification.Name(CallsSensor.ACTION_AWARE_CALL_ACCEPTED)        // o
    public static let actionAwareCallRinging = Notification.Name(CallsSensor.ACTION_AWARE_CALL_RINGING)          // o
    public static let actionAwareCallMissed = Notification.Name(CallsSensor.ACTION_AWARE_CALL_MISSED)            // ?
    public static let actionAwareCallVoiceMailed = Notification.Name(CallsSensor.ACTION_AWARE_CALL_VOICE_MAILED) // x
    public static let actionAwareCallRejected = Notification.Name(CallsSensor.ACTION_AWARE_CALL_REJECTED)        // x
    public static let actionAwareCallBlocked = Notification.Name(CallsSensor.ACTION_AWARE_CALL_BLOCKED)          // ?
    public static let actionAwareCallMade = Notification.Name(CallsSensor.ACTION_AWARE_CALL_MADE)                // o
    public static let actionAwareCallUserInCall = Notification.Name(CallsSensor.ACTION_AWARE_USER_IN_CALL)       // o
    public static let actionAwareCallUserNoInCall = Notification.Name(CallsSensor.ACTION_AWARE_USER_NOT_IN_CALL) // o
}

public protocol CallsObserver {
    /**
     * Callback when a call event is recorded (received, made, missed)
     *
     * @param data
     */
    func onCall(data: CallData)
    
    /**
     * Callback when the phone is ringing
     *
     * @param number
     */
    func onRinging(number: String?)
    
    /**
     * Callback when the user answered and is busy with a call
     *
     * @param number
     */
    func onBusy(number: String?)
    
    /**
     * Callback when the user hangup an ongoing call and is now free
     *
     * @param number
     */
    func onFree(number: String?)
}

public class CallsSensor: AwareSensor {

    public static var TAG = "AWARE::Calls"
    
    /**
     * Fired event: call accepted by the user
     */
    public static var ACTION_AWARE_CALL_ACCEPTED = "ACTION_AWARE_CALL_ACCEPTED"
    
    /**
     * Fired event: phone is ringing
     */
    public static var ACTION_AWARE_CALL_RINGING = "ACTION_AWARE_CALL_RINGING"
    
    /**
     * Fired event: call unanswered
     */
    public static var ACTION_AWARE_CALL_MISSED = "ACTION_AWARE_CALL_MISSED"
    
    /**
     * Fired event: call got voice mailed.
     * Only available after SDK 21
     */
    public static var ACTION_AWARE_CALL_VOICE_MAILED = "ACTION_AWARE_CALL_VOICE_MAILED"
    
    /**
     * Fired event: call got rejected by the callee
     * Only available after SDK 24
     */
    public static var ACTION_AWARE_CALL_REJECTED = "ACTION_AWARE_CALL_REJECTED"
    
    /**
     * Fired event: call got blocked.
     * Only available after SDK 24
     */
    public static var ACTION_AWARE_CALL_BLOCKED = "ACTION_AWARE_CALL_BLOCKED"
    
    /**
     * Fired event: call attempt by the user
     */
    public static var ACTION_AWARE_CALL_MADE = "ACTION_AWARE_CALL_MADE"
    
    /**
     * Fired event: user IS in a call at the moment
     */
    public static var ACTION_AWARE_USER_IN_CALL = "ACTION_AWARE_USER_IN_CALL"
    
    /**
     * Fired event: user is NOT in a call
     */
    public static var ACTION_AWARE_USER_NOT_IN_CALL = "ACTION_AWARE_USER_NOT_IN_CALL"
    
    public static var ACTION_AWARE_CALLS_START = "com.awareframework.android.sensor.calls.SENSOR_START"
    public static var ACTION_AWARE_CALLS_STOP = "com.awareframework.android.sensor.calls.SENSOR_STOP"
    
    public static var ACTION_AWARE_CALLS_SET_LABEL = "com.awareframework.android.sensor.calls.SET_LABEL"
    public static var EXTRA_LABEL = "label"
    
    public static var ACTION_AWARE_CALLS_SYNC = "com.awareframework.android.sensor.calls.SENSOR_SYNC"
    
    public class CallEventType{
        public static let INCOMING_TYPE  = 1
        public static let OUTGOING_TYPE  = 2
        /// unsupported event types on iOS  ///
        public static let MISSED_TYPE    = 3
        public static let VOICEMAIL_TYPE = 4
        public static let REJECTED_TYPE  = 5
        public static let BLOCKED_TYPE   = 6
        public static let ANSWERED_EXTERNALLY_TYPE = 7
    }
    
    public var CONFIG = Config()
    
    var callObserver: CXCallObserver? = nil
    
    var lastCallEvent:CXCall? = nil
    var lastCallEventTime:Date? = nil
    var lastCallEventType:Int? = nil
    
    public class Config:SensorConfig {
        public var sensorObserver:CallsObserver?
        
        public override init(){
            super.init()
            dbPath = "aware_calls"
        }
        
        public convenience init(_ config:Dictionary<String,Any>){
            self.init()
        }
        
        public func apply(closure:(_ config: CallsSensor.Config) -> Void) -> Self {
            closure(self)
            return self
        }
    }
    
    public override convenience init(){
        self.init(CallsSensor.Config())
    }
    
    public init(_ config:CallsSensor.Config){
        super.init()
        CONFIG = config
        initializeDbEngine(config: config)
    }
    
    public override func start() {
        if callObserver == nil {
            callObserver = CXCallObserver()
            callObserver!.setDelegate(self, queue: nil)
        }
    }
    
    public override func stop() {
        callObserver = nil
    }
    
    public override func sync(force: Bool = false) {
        if let engine = self.dbEngine {
            engine.startSync(CallData.TABLE_NAME, DbSyncConfig().apply{config in
                config.debug = CONFIG.debug
            })
        }
    }
}

/**
 * INCOMING_TYPE = 1
 * OUTGOING_TYPE = 2
 * MISSED_TYPE = 3
 * VOICEMAIL_TYPE = 4
 * REJECTED_TYPE = 5
 * BLOCKED_TYPE = 6
 * ANSWERED_EXTERNALLY_TYPE = 7
 */

extension CallsSensor: CXCallObserverDelegate {
    /**
     * https://stackoverflow.com/questions/36014975/detect-phone-calls-on-ios-with-ctcallcenter-swift
     */
    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        print(call.isOutgoing, call.isOnHold, call.hasEnded, call.hasConnected)
        if call.hasEnded   == true && call.isOutgoing == false || // in-coming end
           call.hasEnded   == true && call.isOutgoing == true {   // out-going end
            if self.CONFIG.debug { print("Disconnected") }
            if let observer = self.CONFIG.sensorObserver{
                observer.onFree(number: call.uuid.uuidString)
            }
            self.notificationCenter.post(name: .actionAwareCallUserNoInCall, object: nil)
            self.saveCallEvent(call)

        }

        if call.isOutgoing == true && call.hasConnected == false && call.hasEnded == false {
            if self.CONFIG.debug { print("Dialing") }
            if let observer = self.CONFIG.sensorObserver{
                observer.onRinging(number: call.uuid.uuidString)
            }
            self.notificationCenter.post(name: .actionAwareCallMade, object: nil)
            lastCallEventType = CallEventType.OUTGOING_TYPE
        }
        
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            if self.CONFIG.debug { print("Incoming") }
            if let observer = self.CONFIG.sensorObserver{
                observer.onRinging(number: call.uuid.uuidString)
            }
            self.notificationCenter.post(name: .actionAwareCallRinging, object: nil)
            lastCallEventType = CallEventType.INCOMING_TYPE
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            if self.CONFIG.debug { print("Connected") }
            if let observer = self.CONFIG.sensorObserver{
                observer.onBusy(number: call.uuid.uuidString)
            }
            self.notificationCenter.post(name: .actionAwareCallAccepted, object: nil)
            self.notificationCenter.post(name: .actionAwareCallUserInCall, object: nil)
            lastCallEvent = call
            lastCallEventTime = Date()
            if call.isOutgoing {
                lastCallEventType = CallEventType.OUTGOING_TYPE
            }else{
                lastCallEventType = CallEventType.INCOMING_TYPE
            }
        }
    }
    
    public func saveCallEvent(_ call:CXCall){
        if let uwLastCallEvent = self.lastCallEvent,
           let uwLastCallEventTime = self.lastCallEventTime,
           let uwLastCallEventType = self.lastCallEventType{
            let now = Date()
            let data = CallData()
            data.trace = uwLastCallEvent.uuid.uuidString
            data.eventTimestamp = Int64( now.timeIntervalSince1970*1000 )
            data.duration = Int64(now.timeIntervalSince1970 - uwLastCallEventTime.timeIntervalSince1970)
            data.type = uwLastCallEventType
            if let engine = self.dbEngine {
                engine.save(data, CallData.TABLE_NAME)
            }
            if let observer = self.CONFIG.sensorObserver {
                observer.onCall(data: data)
            }
            // data.type = eventType
            self.lastCallEvent = nil
            lastCallEventTime = nil
            lastCallEventType = nil
        }
    }
    

}

//func onCall(data: CallData)
//func onRinging(number: String?)
//func onBusy(number: String?)
//func onFree(number: String?)


/**
 * Callback when a call event is recorded (received, made, missed)
 * Callback when the phone is ringing
 * Callback when the user answered and is busy with a call
 * Callback when the user hangup an ongoing call and is now free
 */
