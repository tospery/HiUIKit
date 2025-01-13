import Foundation

final public class ConsoleProvider: ProviderType {
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:ss"
        return formatter
    }()
    
    public init() { }
    
    public func log(_ message: @autoclosure () -> Any, module: String, level: Level, file: String, line: Int, function: String, context: Any?) {
        let datetime = formatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        print("\(datetime) \(level.description) \(fileName).\(function):\(line) - 【\(module)】\(message())")
    }

}
