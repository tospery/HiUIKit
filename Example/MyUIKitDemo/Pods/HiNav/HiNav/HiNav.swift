//
//  Router.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import URLNavigator_Hi
import HiDomain

/// 导航的分类
public enum JumpType: Int {
    /// 前进
    case forward
    /// 后退
    case back
}

/// 前进的分类 -> hiios://[host]?forwardType=0
public enum ForwardType: Int {
    /// 推进
    case push
    /// 展示
    case present
    /// 打开
    case open
}

/// 后退的分类 -> hiios://back?backType=0
public enum BackType: Int {
    /// 自动
    case auto
    /// 弹出（一个）
    case popOne
    /// 弹出（所有）
    case popAll
    /// 退场
    case dismiss
}

/// 打开的分类 -> hiios://[popup|sheet|alert|toast]/[path]
public enum OpenType: Int {
    /// 消息框（自动关闭）
    case toast
    /// 提示框（可选择的）
    case alert
    /// 表单框（可操作的）
    case sheet
    /// 弹窗
    case popup
    /// 登录（因为登录页通常需要自定义，故以打开方式处理）
    case login
    /// 首页
    case home
    
    static let allHosts = [
        HiNav.Host.toast,
        HiNav.Host.alert,
        HiNav.Host.sheet,
        HiNav.Host.popup,
        HiNav.Host.login,
        HiNav.Host.home
    ]
}

public enum HiNavError: Error {
    case navigation
}

public protocol HiNavCompatible {
    
    func isLogined() -> Bool
    
    func isLegalHost(host: HiNav.Host) -> Bool
    func allowedPaths(host: HiNav.Host) -> [HiNav.Path]
    
    func needLogin(host: HiNav.Host, path: HiNav.Path?) -> Bool
//    func customLogin(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol, _ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> Bool
    
    func customHome(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol, _ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> Bool
    func customLogin(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol, _ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> Bool
    
    func webToNative(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol, _ webURL: URLConvertible, _ nativeURL: URLConvertible, _ context: Any?) -> Any?
    func webViewController(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol, _ paramters: [String: Any]) -> UIViewController?
    
    func web(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol)
    func page(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol)
    func open(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol)
    
}

//public struct BackResult {
//    
//    public var type: BackType
//    public var data: Any?
//    
//    public init(
//        type: BackType,
//        data: Any? = nil
//    ) {
//        self.type = type
//        self.data = data
//    }
//}

final public class HiNav {

    public typealias Host = String
    public typealias Path = String
    
    public static var shared = HiNav()
    
    init() {
    }
    
    public func initialize(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol) {
        self.buildinMatch(provider, navigator)
        self.buildinWeb(provider, navigator)
        self.buildinBack(provider, navigator)
        self.buildinHome(provider, navigator)
        self.buildinLogin(provider, navigator)
        if let compatible = self as? HiNavCompatible {
            compatible.web(provider, navigator)
            compatible.page(provider, navigator)
            compatible.open(provider, navigator)
        }
    }
    
    func buildinMatch(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol) {
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
    
    func buildinWeb(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol) {
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
                let base = UIApplication.shared.baseWebUrl + "/"
                if string.hasPrefix(base) {
                    let native = string.replacingOccurrences(of: base, with: UIApplication.shared.urlScheme + "://")
                    let result = navigator.jump(native, context: context)
                    if result is Bool {
                        return nil
                    }
                    if let vc = result as? UIViewController {
                        return nil
                    }
                    if let compatible = self as? HiNavCompatible {
                        let result = compatible.webToNative(provider, navigator, myURL, native, context)
                        if let rt = result as? Bool, rt {
                            return nil
                        }
                        if let vc = result as? UIViewController {
                            return nil
                        }
                    }
                }
            }
            // (2) 网页跳转
            if let compatible = self as? HiNavCompatible {
                return compatible.webViewController(provider, navigator, paramters)
            }
            return nil
        }
//        navigator.register("http://<path:_>", webFactory)
//        navigator.register("https://<path:_>", webFactory)
        navigator.register("http://[path:_]", webFactory)
        navigator.register("https://[path:_]", webFactory)
    }
    
    func buildinBack(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol) {
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
    
    func buildinHome(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .home)) { url, values, context in
            if let compatible = self as? HiNavCompatible {
                return compatible.customHome(provider, navigator, url, values, context)
            }
            return false
        }
    }
    
    func buildinLogin(_ provider: HiDomain.ProviderProtocol, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .login)) { url, values, context in
            if let compatible = self as? HiNavCompatible {
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
    public func urlPattern(host: HiNav.Host, path: Path? = nil, placeholder: String? = nil) -> String {
        var url = "\(UIApplication.shared.urlScheme)://\(host)"
        if let path = path {
            url += "/\(path)"
        }
        if let placeholder = placeholder {
            url += "/\(placeholder)"
        }
        return url
    }
    
    public func urlString(host: HiNav.Host, path: Path? = nil, parameters: [String: String]? = nil) -> String {
        var url = "\(UIApplication.shared.urlScheme)://\(host)".url!
        if let path = path {
            url.appendPathComponent(path)
        }
        if let parameters = parameters {
            url.appendQueryParameters(parameters)
        }
        return url.absoluteString
    }

}

extension HiNav.Host {
    /// 返回上一级（包括退回或者关闭）
    public static var back: HiNav.Host { "back" }
    /// 弹窗分为两类（自动关闭的toast和手动关闭的）
    public static var toast: HiNav.Host { "toast" }
    public static var alert: HiNav.Host { "alert" }
    public static var sheet: HiNav.Host { "sheet" }
    public static var popup: HiNav.Host { "popup" }
    
    public static var dashboard: HiNav.Host { "dashboard" }
    public static var personal: HiNav.Host { "personal" }
    
    public static var home: HiNav.Host { "home" }
    public static var login: HiNav.Host { "login" }
    public static var user: HiNav.Host { "user" }
    public static var custom: HiNav.Host { "custom" }
    public static var profile: HiNav.Host { "profile" }
    public static var settings: HiNav.Host { "settings" }
    public static var about: HiNav.Host { "about" }
    public static var search: HiNav.Host { "search" }
}

extension HiNav.Path {
    public static var page: HiNav.Path { "page" }
    public static var list: HiNav.Path { "list" }
    public static var detail: HiNav.Path { "detail" }
    public static var history: HiNav.Path { "history" }
}

