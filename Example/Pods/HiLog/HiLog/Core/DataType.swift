import Foundation

public enum Level: Int, CustomStringConvertible {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    
    public var description: String {
        switch self {
        case .verbose: return "Verbose"
        case .debug: return "Debug"
        case .info: return "Info"
        case .warning: return "Warning"
        case .error: return "Error"
        }
    }
}

public typealias Module = String
extension Module {
    public static var general: Module { "general" }
    public static var core: Module { "core" }
    public static var library: Module { "library" }
    public static var network: Module { "network" }
    public static var database: Module { "database" }
    public static var statistic: Module { "statistic" }
    public static var hiUIKit: Module { "HiUIKit" }
    public static var hiSwiftUI: Module { "HiSwiftUI" }
}

public protocol ProviderType {
    func log(_ message: @autoclosure () -> Any, module: String, level: Level, file: String, line: Int, function: String, context: Any?)
}

public protocol LoggerType {
    func register(provider: ProviderType)
    func log(_ message: @autoclosure () -> Any, module: String, level: Level, file: String, line: Int, function: String, context: Any?)
}
