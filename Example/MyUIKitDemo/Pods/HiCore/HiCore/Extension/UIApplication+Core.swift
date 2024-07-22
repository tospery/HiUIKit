//
//  UIApplication+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit
import SwifterSwift

public extension UIApplication {
    
    private static var _inAppStore: Bool?
    var inAppStore: Bool {
        if UIApplication._inAppStore == nil {
            UIApplication._inAppStore = self.inferredEnvironment == .appStore
        }
        return UIApplication._inAppStore!
    }
    
    var team: String {
        let query = [
            kSecClass as NSString: kSecClassGenericPassword as NSString,
            kSecAttrAccount as NSString: "bundleSeedID" as NSString,
            kSecAttrService as NSString: "" as NSString,
            kSecReturnAttributes as NSString: kCFBooleanTrue as NSNumber
        ] as NSDictionary
        
        var result: CFTypeRef?
        var status = Int(SecItemCopyMatching(query, &result))
        if status == Int(errSecItemNotFound) {
            status = Int(SecItemAdd(query, &result))
        }
        if status == Int(errSecSuccess),
            let attributes = result as? NSDictionary,
            let accessGroup = attributes[kSecAttrAccessGroup as NSString] as? NSString,
            let bundleSeedID = (accessGroup.components(separatedBy: ".") as NSArray).objectEnumerator().nextObject() as? String {
            return bundleSeedID
        }
        
        return ""
    }
    
    var name: String {
        self.displayName ?? self.bundleName
    }
    
    var displayName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
    
    
    var bundleName: String {
        Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
    }
    
    var bundleIdentifier: String {
        Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as! String
    }
    
    var appIcon: UIImage? {
        guard let info = (Bundle.main.infoDictionary as NSDictionary?) else { return nil }
        guard let name = (info.value(forKeyPath: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles") as? Array<String>)?.last else { return nil }
        return UIImage(named: name)
    }
    
    var window: UIWindow {
        var window: UIWindow?
        if #available(iOS 13, *) {
            window = UIApplication.shared.windows.filter { $0.isKeyWindow }.last
        } else {
            window = UIApplication.shared.keyWindow
        }
        return window!
    }
    
    @objc var pageStart: Int { 0 }
    
    @objc var pageSize: Int { 20 }
    
}
