import XCTest
import RealmSwift
import CallKit
import com_awareframework_ios_sensor_calls

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSync(){
        //        let sensor = CallsSensor.init(CallsSensor.Config().apply{ config in
        //            config.debug = true
        //            config.dbType = .REALM
        //        })
        //        sensor.start();
        //        sensor.enable();
        //        sensor.sync(force: true)
        
        //        let syncManager = DbSyncManager.Builder()
        //            .setBatteryOnly(false)
        //            .setWifiOnly(false)
        //            .setSyncInterval(1)
        //            .build()
        //
        //        syncManager.start()
    }
    
    func testObserver(){
        
//        class Observer:CallsObserver{
//            weak var callExpectation: XCTestExpectation?
//            func onCall(data: CallsData) {
//
//            }
//
//            func onRinging(number: String?) {
//
//            }
//
//            func onBusy(number: String?) {
//
//            }
//
//            func onFree(number: String?) {
//
//            }
//        }
//
//        let callExpect = expectation(description: "call observer")
//        let observer = Observer()
//        observer.callExpectation = callExpect
//        let sensor = CallsSensor.init(CallsSensor.Config().apply{ config in
//            config.sensorObserver = observer
//        })
//        sensor.start()
//
//        wait(for: [callExpect], timeout: 3)
//        sensor.stop()
        
    }
    
    func testControllers(){
        
        let sensor = CallsSensor.init()
        sensor.CONFIG.debug = true
        
        /// test set label action ///
        let expectSetLabel = expectation(description: "set label")
        let newLabel = "hello"
        let labelObserver = NotificationCenter.default.addObserver(forName: .actionAwareCallsSetLabel, object: nil, queue: .main) { (notification) in
            let dict = notification.userInfo;
            if let d = dict as? Dictionary<String,String>{
                XCTAssertEqual(d[CallsSensor.EXTRA_LABEL], newLabel)
            }else{
                XCTFail()
            }
            expectSetLabel.fulfill()
        }
        sensor.set(label:newLabel)
        wait(for: [expectSetLabel], timeout: 5)
        NotificationCenter.default.removeObserver(labelObserver)
        
        /// test sync action ////
        let expectSync = expectation(description: "sync")
        let syncObserver = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareCallsSync , object: nil, queue: .main) { (notification) in
            expectSync.fulfill()
            print("sync")
        }
        sensor.sync()
        wait(for: [expectSync], timeout: 5)
        NotificationCenter.default.removeObserver(syncObserver)
        
        
        //// test start action ////
        let expectStart = expectation(description: "start")
        let observer = NotificationCenter.default.addObserver(forName: .actionAwareCallsStart,
                                                              object: nil,
                                                              queue: .main) { (notification) in
                                                                expectStart.fulfill()
                                                                print("start")
        }
        sensor.start()
        wait(for: [expectStart], timeout: 5)
        NotificationCenter.default.removeObserver(observer)
        
        
        /// test stop action ////
        let expectStop = expectation(description: "stop")
        let stopObserver = NotificationCenter.default.addObserver(forName: .actionAwareCallsStop, object: nil, queue: .main) { (notification) in
            expectStop.fulfill()
            print("stop")
        }
        sensor.stop()
        wait(for: [expectStop], timeout: 5)
        NotificationCenter.default.removeObserver(stopObserver)
        
    }
    
    func testCallsData(){
        let data = CallsData()
        let dict = data.toDictionary()
        
        XCTAssertEqual(dict["eventTimestamp"] as! Int64, 0)
        XCTAssertEqual(dict["type"] as! Int, -1)
        XCTAssertEqual(dict["duration"] as! Int64, 0)
        XCTAssertEqual(dict["trace"] as? String, nil)
        
//        @objc dynamic public var eventTimestamp: Int64 = 0
//        @objc dynamic public var type: Int = -1
//        @objc dynamic public var duration: Int64 = 0
//        @objc dynamic public var trace:String? = nil
//        XCTAssertEqual(dict["moving"] as! Bool, false)
    }
    
}
