//
//  BaseCollectionHeader.swift
//  HiUIKit
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit

open class BaseCollectionHeader: BaseCollectionReusableView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
