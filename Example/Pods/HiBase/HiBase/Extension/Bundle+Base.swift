//
//  Bundle+Base.swift
//  Pods
//
//  Created by 杨建祥 on 2024/12/17.
//

import Foundation

public extension Bundle {

    var name: String { self.displayName ?? self.bundleName }
    var displayName: String? { object(forInfoDictionaryKey: "CFBundleDisplayName") as? String }
    var bundleName: String { infoDictionary?[kCFBundleNameKey as String] as! String }
    var bundleIdentifier: String { infoDictionary?[kCFBundleIdentifierKey as String] as! String }
    var version: String { object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "" }
    var buildNumber: String { object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "" }
    
    var appHosts: [String: String] { infoDictionary?["appHosts"] as? [String: String] ?? [:] }
    var baseApiUrl: String {
        var base = tryString(appHosts["api"]) ?? ""
        if base.isEmpty {
            base = "https://api.\(self.urlScheme() ?? "app").com"
        }
        return base
    }
    
    var baseWebUrl: String {
        var base = tryString(appHosts["web"]) ?? ""
        if base.isEmpty {
            base = "https://\(self.urlScheme() ?? "app").com"
        }
        return base
    }
    
    var baseUnivLink: String {
        var base = tryString(appHosts["univ"]) ?? ""
        if base.isEmpty {
            base = "https://\(self.urlScheme() ?? "app").com"
        }
        return base
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

    func urlScheme(name: String = "app") -> String? {
        var scheme: String? = nil
        if let types = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? Array<Dictionary<String, Any>> {
            for info in types {
                if let urlName = info["CFBundleURLName"] as? String,
                   urlName == name {
                    if let urlSchemes = info["CFBundleURLSchemes"] as? [String] {
                        scheme = urlSchemes.first
                    }
                }
            }
        }
        return scheme
    }
    
}
