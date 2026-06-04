import Foundation
import com_awareframework_ios_core
import GRDB

public struct CallsData: BaseDbModelSQLite {
    public var id: Int64?
    public var timestamp: Int64 = 0
    public var deviceId: String = AwareUtils.getCommonDeviceId()
    public var label: String = ""
    public var timezone: Int = AwareUtils.getTimeZone()
    public var os: String = "iOS"
    public var jsonVersion: Int = 1
    public static let databaseTableName = "callsData"

    public var eventTimestamp: Int64 = 0
    public var type: Int = 0
    public var duration: Int64 = 0
    public var trace: String = ""

    public init() {}
    public init(_ dict: Dictionary<String, Any>) {
        timestamp      = dict["timestamp"] as? Int64 ?? 0
        label          = dict["label"] as? String ?? ""
        deviceId       = dict["deviceId"] as? String ?? AwareUtils.getCommonDeviceId()
        eventTimestamp = dict["eventTimestamp"] as? Int64 ?? 0
        type           = dict["type"] as? Int ?? 0
        duration       = dict["duration"] as? Int64 ?? 0
        trace          = dict["trace"] as? String ?? ""
    }
    public static func createTable(queue: DatabaseQueue) throws {
        try queue.write { db in try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("deviceId",.text).notNull(); t.column("timestamp",.integer).notNull()
            t.column("label",.text).notNull(); t.column("eventTimestamp",.integer).notNull()
            t.column("timezone",.integer).notNull(); t.column("os",.text).notNull()
            t.column("jsonVersion",.integer).notNull()
            t.column("type",.integer).notNull(); t.column("duration",.integer).notNull()
            t.column("trace",.text).notNull()
        }}
    }
    public func toDictionary() -> Dictionary<String, Any> {
        ["id": id ?? -1, "timestamp": timestamp, "deviceId": deviceId, "label": label,
         "eventTimestamp": eventTimestamp, "type": type, "duration": duration, "trace": trace]
    }
}
