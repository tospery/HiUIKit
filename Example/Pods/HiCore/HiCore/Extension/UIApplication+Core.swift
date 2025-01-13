//
//  UIApplication+Core.swift
//  HiCore
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit
import HiBase
import SwifterSwift

public extension UIApplication {
    
    private static var _inAppStore: Bool?
    var inAppStore: Bool {
        if UIApplication._inAppStore == nil {
            UIApplication._inAppStore = self.inferredEnvironment == .appStore
        }
        return UIApplication._inAppStore!
    }
    
    var name: String { Bundle.main.name }
    var displayName: String? { Bundle.main.displayName }
    var bundleName: String { Bundle.main.bundleName }
    var bundleIdentifier: String { Bundle.main.bundleIdentifier }
    var version: String { Bundle.main.version }
    var buildNumber: String { Bundle.main.buildNumber }
    
    var team: String { Bundle.main.team }
    var urlScheme: String { Bundle.main.urlScheme() ?? "" }
    
    var baseApiUrl: String { Bundle.main.baseApiUrl }
    var baseWebUrl: String { Bundle.main.baseWebUrl }
    var baseUnivLink: String { Bundle.main.baseUnivLink }
    
    var appIcon: UIImage? {
        guard let info = (Bundle.main.infoDictionary as NSDictionary?) else { return nil }
        guard let name = (info.value(forKeyPath: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles") as? Array<String>)?.last else { return nil }
        return UIImage(named: name)
    }
    
    var window: UIWindow {
        if let window1 = self.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first {
            return window1
        }
        if let window2 = self.windows.filter({ $0.isKeyWindow }).first {
            return window2
        }
        return .init()
    }
    
    @objc var pageStart: Int { 0 }
    
    @objc var pageSize: Int { 20 }
    
}
