//
//  NavigatorProtocol+HiNav.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import URLNavigator_Hi
import SwifterSwift
import HiDomain

var navigateBag = DisposeBag()

public extension NavigatorProtocol {

    // MARK: - Public
    // MARK: jump
    @discardableResult
    func jump(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Any? {
        guard let url = url.urlValue else { return false }
        var parameters: [String: Any] = url.queryParameters ?? [:]
        // context中的参数的优先级高于查询参数
        parameters += context as? [String: Any] ?? [:]
        // 打印路由地址
        print("导航地址->\(url.absoluteString)\n\(parameters)")
        
        let myURL = self.checkScheme(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
        if myURL == nil {
            return false
        }
        
        if self.checkLogin(myURL!, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion) {
            return true
        }
        
        var type: JumpType?
        if url.host == .back {
            type = .back
        } else {
            if let value = self.getType(myURL!, context: context, key: Parameter.jumpType),
               let jump = JumpType.init(rawValue: value) {
                type = jump
            } else {
                type = .forward
            }
        }
        switch type! {
        case .forward:
            return self.forward(myURL!, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
        case .back:
            return self.open(myURL!, context: context)
        }
    }
    
    func rxJump(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        (self as! Navigator).rx.jump(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
    }
    
    // MARK: push
    @discardableResult
    func pushX(
        _ url: URLConvertible,
        context: Any? = nil,
        from: UINavigationControllerType? = nil,
        animated: Bool = true
    ) -> UIViewController? {
        self.jump(url, context: self.contextForPush(context: context), fromNav: from, animated: animated) as? UIViewController
    }
    
    func rxPushX(
        _ url: URLConvertible,
        context: Any? = nil,
        from: UINavigationControllerType? = nil,
        animated: Bool = true
    ) -> Observable<Any> {
        self.rxJump(url, context: self.contextForPush(context: context), fromNav: from, animated: animated)
    }
    
    // MARK: present
    @discardableResult
    func presentX(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        from: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> UIViewController? {
        self.jump(url, context: self.contextForPresent(context: context), wrap: wrap, fromVC: from, animated: animated, completion: completion) as? UIViewController
    }
    
    func rxPresentX(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        from: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        self.rxJump(url, context: self.contextForPresent(context: context), wrap: wrap, fromVC: from, animated: animated, completion: completion)
    }
    
    // MARK: toast
    func toastMessage(_ message: String, _ style: HiToastStyle = .success) {
        guard !message.isEmpty else { return }
        var parameters = [String: String].init()
        parameters[Parameter.message] = message
        parameters[Parameter.style] = style.rawValue.string
        var ctx = self.convert()
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.toast.rawValue
        self.jump(HiNav.shared.urlString(host: .toast, parameters: parameters), context: ctx)
    }
    
    func showToastActivity(active: Bool = true) {
        var parameters = [String: String].init()
        parameters[Parameter.active] = active.string
        var ctx = self.convert()
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.toast.rawValue
        self.jump(HiNav.shared.urlString(host: .toast, parameters: parameters), context: ctx)
    }
    
    func hideToastActivity() {
        self.showToastActivity(active: false)
    }
    
    // MARK: - alert
    @discardableResult
    func alert(_ title: String, _ message: String, _ actions: [AlertActionType]) -> Bool {
        let info = self.infoForAlert(title, message, actions)
        return self.jump(HiNav.shared.urlString(host: .alert, parameters: info.0), context: info.1) as? Bool ?? false
    }

    func rxAlert(_ title: String, _ message: String, _ actions: [AlertActionType]) -> Observable<Any> {
        let info = self.infoForAlert(title, message, actions)
        return self.rxJump(HiNav.shared.urlString(host: .alert, parameters: info.0), context: info.1)
    }
    
    // MARK: sheet
    @discardableResult
    func sheet(_ title: String?, _ message: String?, _ actions: [AlertActionType]) -> Bool {
        let info = self.infoForSheet(title, message, actions)
        return self.jump(HiNav.shared.urlString(host: .sheet, parameters: info.0), context: info.1) as? Bool ?? false
    }

    func rxSheet(_ title: String?, _ message: String?, _ actions: [AlertActionType]) -> Observable<Any> {
        let info = self.infoForSheet(title, message, actions)
        return self.rxJump(HiNav.shared.urlString(host: .sheet, parameters: info.0), context: info.1)
    }
    
    // MARK: popup
    @discardableResult
    func popup(_ path: HiNav.Path, context: Any? = nil) -> Bool {
        self.jump(HiNav.shared.urlString(host: .popup, path: path), context: self.contextForPopup(context: context)) as? Bool ?? false
    }
    
    func rxPopup(_ path: HiNav.Path, context: Any? = nil) -> Observable<Any> {
        self.rxJump(HiNav.shared.urlString(host: .popup, path: path), context: self.contextForPopup(context: context))
    }
    
    // MARK: login
    func login() {
        self.jump(HiNav.shared.urlString(host: .login), context: self.contextForLogin())
    }
    
    func rxLogin() -> Observable<Any> {
        self.rxJump(HiNav.shared.urlString(host: .login), context: self.contextForLogin())
    }

    // MARK: back
    func back(type: BackType? = nil, animated: Bool = true, message: String? = nil) {
        self.jump(HiNav.shared.urlString(host: .back), context: self.contextForBack(type: type, animated: animated, message: message))
    }
    
    func rxBack(type: BackType? = nil, animated: Bool = true, message: String? = nil) -> Observable<Any> {
        self.rxJump(HiNav.shared.urlString(host: .back), context: self.contextForBack(type: type, animated: animated, message: message))
    }
    
    // MARK: - Private
    private func checkScheme(
        _ url: URLConvertible,
        context: Any?,
        wrap: UINavigationController.Type?,
        fromNav: UINavigationControllerType?,
        fromVC: UIViewControllerType?,
        animated: Bool,
        completion: (() -> Void)?
    ) -> URLConvertible? {
        guard var myURL = url.urlValue else { return nil }
        if myURL.scheme?.isEmpty ?? true {
            myURL = "https://\(myURL.absoluteString)".url ?? myURL
        }
        guard let scheme = myURL.scheme else { return nil }
        if scheme != UIApplication.shared.urlScheme && scheme != "http" && scheme != "https" {
            print("第三方url: \(myURL)")
            if UIApplication.shared.canOpenURL(myURL) {
                UIApplication.shared.open(myURL, options: [:], completionHandler: nil)
                return nil
            }
            print("无法打开该url: \(myURL)")
            return nil
        }
        return myURL
    }
    
    private func checkLogin(
        _ url: URLConvertible,
        context: Any?,
        wrap: UINavigationController.Type?,
        fromNav: UINavigationControllerType?,
        fromVC: UIViewControllerType?,
        animated: Bool,
        completion: (() -> Void)?
    ) -> Bool {
        guard let url = url.urlValue else { return false }
        guard let host = url.host, host != .back, !OpenType.allHosts.contains(host) else { return false }
        var needLogin = false
        var isLogined = true
        let router = HiNav.shared
        if let compatible = router as? HiNavCompatible {
            isLogined = compatible.isLogined()
            if compatible.needLogin(host: host, path: url.path) {
                needLogin = true
            }
        } else {
            if host == .user {
                needLogin = true
            }
        }
        if needLogin && !isLogined {
            self.rxLogin()
                .subscribe(onNext: { result in
                    print("自动跳转登录页(数据): \(result)")
                }, onError: { error in
                    print("自动跳转登录页(错误): \(error)")
                }, onCompleted: {
                    print("自动跳转登录页(完成)")
                    var hasLogined = false
                    if let compatible = router as? HiNavCompatible {
                        hasLogined = compatible.isLogined()
                    }
                    if hasLogined {
                        self.jump(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
                    }
                }).disposed(by: navigateBag)
            return true
        }
        return false
    }
    
    private func getType(_ url: URLConvertible, context: Any?, key: String) -> Int? {
        var parameters: [String: Any] = url.queryParameters
        parameters += context as? [String: Any] ?? [:]
        return tryInt(parameters[key])
    }
    
    /// 用户参数优先级高于函数参数/
    private func getAnimated(_ url: URLConvertible, context: Any?, animated: Bool) -> Bool {
        var parameters: [String: Any] = url.queryParameters
        parameters += context as? [String: Any] ?? [:]
        return tryBool(Parameter.animated) ?? animated
    }
    
    private func convert(context: Any? = nil) -> [String: Any] {
        var ctx = [String: Any].init()
        if let context = context as? [String: Any] {
            ctx = context
        } else {
            ctx[Parameter.navContext] = context
        }
        return ctx
    }
    
    private func contextForPush(context: Any?) -> Any {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.push.rawValue
        return ctx
    }
    
    private func contextForPresent(context: Any?) -> Any {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.present.rawValue
        return ctx
    }
    
    private func contextForPopup(context: Any?) -> Any {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.popup.rawValue
        return ctx
    }
    
    private func contextForLogin() -> Any {
        var ctx = self.convert()
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.login.rawValue
        return ctx
    }
    
    private func contextForBack(type: BackType?, animated: Bool, message: String?) -> Any {
        var ctx = self.convert(context: [
            Parameter.backType: type as Any?,
            Parameter.animated: animated,
            Parameter.message: message
        ])
        ctx[Parameter.jumpType] = JumpType.back.rawValue
        return ctx
    }
    
    private func infoForSheet(_ title: String?, _ message: String?, _ actions: [AlertActionType]) -> ([String: String], [String: Any]) {
        var parameters = [String: String].init()
        parameters[Parameter.title] = title
        parameters[Parameter.message] = message
        var context = self.convert(context: [
            Parameter.actions: actions
        ])
        context[Parameter.jumpType] = JumpType.forward.rawValue
        context[Parameter.forwardType] = ForwardType.open.rawValue
        context[Parameter.openType] = OpenType.sheet.rawValue
        return (parameters, context)
    }
    
    private func infoForAlert(_ title: String, _ message: String, _ actions: [AlertActionType]) -> ([String: String], [String: Any]) {
        var parameters = [String: String].init()
        parameters[Parameter.title] = title
        parameters[Parameter.message] = message
        var context = self.convert(context: [
            Parameter.actions: actions
        ])
        context[Parameter.jumpType] = JumpType.forward.rawValue
        context[Parameter.forwardType] = ForwardType.open.rawValue
        context[Parameter.openType] = OpenType.alert.rawValue
        return (parameters, context)
    }
    
    @discardableResult
    private func forward(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Any? {
        var type: ForwardType?
        if OpenType.allHosts.contains(url.urlValue?.host ?? "") {
            type = .open
        } else {
            if let value = self.getType(url, context: context, key: Parameter.forwardType),
               let forward = ForwardType.init(rawValue: value) {
                type = forward
            } else {
                type = .push
            }
        }
        switch type! {
        case .push:
            let animated = self.getAnimated(url, context: context, animated: animated)
            return self.push(url, context: context, from: fromNav, animated: animated)
        case .present:
            let animated = self.getAnimated(url, context: context, animated: animated)
            return self.present(url, context: context, wrap: wrap ?? NavigationController.self, from: fromVC, animated: animated, completion: completion)
        case .open:
            return self.open(url, context: context)
        }
    }

}
