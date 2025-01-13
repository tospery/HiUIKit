import Foundation
import HiBase
import RxSwift
import URLNavigator_Hi

public protocol HiNavCompatibleEx2 {
    func customHome(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol, _ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> Bool
    func customLogin(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol, _ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> Bool
    
    func webToNative(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol, _ webURL: URLConvertible, _ nativeURL: URLConvertible, _ context: Any?) -> Any?
    func webViewController(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol, _ paramters: [String: Any]) -> UIViewController?
    
    func web(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol)
    func page(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol)
    func open(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol)
}

public extension HiNav {
    
    public func initialize(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol) {
        self.buildinMatch(provider, navigator)
        self.buildinWeb(provider, navigator)
        self.buildinBack(provider, navigator)
        self.buildinHome(provider, navigator)
        self.buildinLogin(provider, navigator)
        if let compatible = self as? HiNavCompatibleEx2 {
            compatible.web(provider, navigator)
            compatible.page(provider, navigator)
            compatible.open(provider, navigator)
        }
    }
    
    func buildinMatch(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol) {
        (navigator as? Navigator)?.matcher.valueConverters["type"] = { [weak self] pathComponents, index in
            guard let `self` = self else { return nil }
            if let compatible = self as? HiNavCompatible {
                let host = pathComponents[0]
                if compatible.isLegalHost(host: host) {
                    let path = pathComponents[index]
                    if compatible.allowedPaths(host: host).contains(path) {
                        return path
                    }
                }
            }
            return nil
        }
    }
    
    func buildinWeb(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol) {
        let webFactory: ViewControllerFactory = { [weak self] (url, values, context) in
            guard let `self` = self else { return nil }
            guard let myURL = url.urlValue else { return nil }
            let string = myURL.absoluteString
            var paramters = self.parameters(myURL, values, context) ?? [:]
            paramters[Parameter.url] = string
            if let title = myURL.queryValue(for: Parameter.title) {
                paramters[Parameter.title] = title
            }
            let force = tryBool(paramters[Parameter.navForceWeb]) ?? false
            if !force {
                // (1) 原生支持
                let base = "\(Bundle.main.baseWebUrl)/"
                if string.hasPrefix(base) {
                    let native = string.replacingOccurrences(of: base, with: "\(Bundle.main.urlScheme() ?? "")://")
                    let result = navigator.jump(native, context: context)
                    if result is Bool {
                        return nil
                    }
                    if result is UIViewController {
                        return nil
                    }
                    if let compatible = self as? HiNavCompatibleEx2 {
                        let result = compatible.webToNative(provider, navigator, myURL, native, context)
                        if let rt = result as? Bool, rt {
                            return nil
                        }
                        if result is UIViewController {
                            return nil
                        }
                    }
                }
            }
            // (2) 网页跳转
            if let compatible = self as? HiNavCompatibleEx2 {
                return compatible.webViewController(provider, navigator, paramters)
            }
            return nil
        }
//        navigator.register("http://<path:_>", webFactory)
//        navigator.register("https://<path:_>", webFactory)
        navigator.register("http://[path:_]", webFactory)
        navigator.register("https://[path:_]", webFactory)
    }
    
    func buildinBack(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .back)) { url, values, context in
            guard let top = UIViewController.topMost else { return false }
            let parameters = self.parameters(url, values, context)
            if let message = tryString(parameters?[Parameter.message]), message.isNotEmpty {
                navigator.toastMessage(message)
            }
            let result = parameters?[Parameter.result]
            let observer = parameters?[Parameter.navObserver] as? AnyObserver<Any>
            let completion: (() -> Void) = {
                if result != nil {
                    observer?.onNext(result!)
                }
                observer?.onCompleted()
            }
            let back = tryEnum(value: parameters?[Parameter.backType], type: BackType.self) ?? .auto
            let animated = tryBool(parameters?[Parameter.animated]) ?? true
            switch back {
            case .auto:
                if top.navigationController?.viewControllers.count ?? 0 > 1 {
                    popOne(viewController: top, animated: animated, completion)
                } else {
                    dismiss(viewController: top, animated: animated, completion)
                }
            case .popOne:
                popOne(viewController: top, animated: animated, completion)
            case .popAll:
                popAll(viewController: top, animated: animated, completion)
            case .dismiss:
                dismiss(viewController: top, animated: animated, completion)
            }
            return true
        }
    }
    
    func buildinHome(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .home)) { url, values, context in
            if let compatible = self as? HiNavCompatibleEx2 {
                return compatible.customHome(provider, navigator, url, values, context)
            }
            return false
        }
    }
    
    func buildinLogin(_ provider: HiBase.ProviderProtocol, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .login)) { url, values, context in
            if let compatible = self as? HiNavCompatibleEx2 {
                return compatible.customLogin(provider, navigator, url, values, context)
            }
            return false
        }
    }
    
    public func parameters(_ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> [String: Any]? {
        // 1. 基础参数
        var parameters: [String: Any] = url.queryParameters
        for (key, value) in values {
            parameters[key] = value
        }
        if let context = context {
            if let ctx = context as? [String: Any] {
                for (key, value) in ctx {
                    parameters[key] = value
                }
            } else {
                parameters[Parameter.navContext] = context
            }
        }
        // 2. Host
        guard let host = url.urlValue?.host else { return nil }
        parameters[Parameter.navHost] = host
        // 3. Path
        let path = url.urlValue?.path.removingPrefix("/").removingSuffix("/")
        parameters[Parameter.navPath] = path?.isEmpty ?? true ? nil : path
        // 4. 标题
        parameters[Parameter.title] = tryString(parameters[Parameter.title])
//        var title: String? = nil
//        if let compatible = self as? HiNavCompatible {
//            title = compatible.title(host: host, path: path)
//        }
//        parameters[Parameter.title] = parameters.string(for: Parameter.title) ?? title
        // 5. 刷新/加载
//        var shouldRefresh = false
//        var shouldLoadMore = false
//        if let compatible = self as? HiNavCompatible {
//            shouldRefresh = compatible.shouldRefresh(host: host, path: path)
//            shouldLoadMore = compatible.shouldLoadMore(host: host, path: path)
//        }
//        parameters[Parameter.shouldRefresh] = parameters.bool(for: Parameter.shouldRefresh) ?? shouldRefresh
//        parameters[Parameter.shouldLoadMore] = parameters.bool(for: Parameter.shouldLoadMore) ?? shouldLoadMore
        parameters[Parameter.navUrl] = url.urlStringValue
        
        return parameters
    }
    
    /// 注册的pattern
    /// 对于详情页，如app://user/detail采用<id>匹配模式
    /// 此时，需要注册两个patter，分别为app://user/42980和app://user
    /// 前者用于跳转到指定用户的详情页，后者用户跳转到当前登录用户的详情页
    public func urlPattern(host: HiNavHost, path: HiNavPath? = nil, placeholder: String? = nil) -> String {
        var url = "\(Bundle.main.urlScheme() ?? "")://\(host)"
        if let path = path {
            url += "/\(path)"
        }
        if let placeholder = placeholder {
            url += "/\(placeholder)"
        }
        return url
    }
    
    public func urlString(host: HiNavHost, path: HiNavPath? = nil, parameters: [String: String]? = nil) -> String {
        var url = "\(Bundle.main.urlScheme() ?? "")://\(host)".url!
        if let path = path {
            url.appendPathComponent(path)
        }
        if let parameters = parameters {
            url.appendQueryParameters(parameters)
        }
        return url.absoluteString
    }

}

