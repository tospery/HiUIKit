//
//  Double+Hi.swift
//  HiUIKit
//
//  Created by 杨建祥 on 2024/3/26.
//

import Foundation
import HiCore

public extension String {
    
    var localizedString: String {
        if profileService.value?.localization == .chinese {
            return chineseLocalizedString
        }
        return englishLocalizedString
    }
    
}
