//
//  UIApplication+Navigator.swift
//  HiNavigator
//
//  Created by 杨建祥 on 2024/5/16.
//

import UIKit

public extension UIApplication {
    
    var urlScheme: String { self.urlScheme(name: "app") ?? "" }
    
    var linkDomains: [String] { Bundle.main.infoDictionary?["linkDomains"] as? [String] ?? [] }
    
    @objc var baseApiUrl: String {
        var domain = self.linkDomains.first ?? ""
        if domain.isEmpty {
            domain = "\(self.urlScheme).com"
        }
        return "https://\(domain)"
    }
    
    @objc var baseWebUrl: String {
        var domain = self.linkDomains.first ?? ""
        if domain.isEmpty {
            domain = "\(self.urlScheme).com"
        }
        return "https://\(domain)"
    }
    
    func urlScheme(name: String) -> String? {
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
