import Foundation

public func log(
    _ message: @autoclosure () -> Any,
    module: String = .general,
    level: Level = .debug,
    file: String = #file,
    line: Int = #line,
    function: String = #function,
    context: Any? = nil
) {
    logger.log(message(), module: module, level: level, file: file, line: line, function: function, context: context)
}

public let logger = Logger()

open class Logger: LoggerType {
    
    private(set) open var providers: [ProviderType] = []
    
    public init() {
        // I'm Logger 👋
    }
    
    open func register(provider: ProviderType) {
        self.providers.append(provider)
    }
    
    open func log(_ message: @autoclosure () -> Any, module: String, level: Level, file: String, line: Int, function: String, context: Any?) {
        for provider in self.providers {
            provider.log(message(), module: module, level: level, file: file, line: line, function: function, context: context)
        }
    }
    
}
