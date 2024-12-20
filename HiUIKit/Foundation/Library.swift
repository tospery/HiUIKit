//
//  Library.swift
//  HiUIKit
//
//  Created by liaoya on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import HiCore
import HiNet

public protocol LibraryCompatible {
    func mySetup()
}

final public class Library {
    
    public var disposeBag = DisposeBag()
    public static var shared = Library()
    
    public init() {
    }
    
    public func setup() {
        if let compatible = self as? LibraryCompatible {
            compatible.mySetup()
        } else {
            self.basic()
        }
    }
    
    public func basic() {
//        logType.addDestination(ConsoleDestination.init())
//        logType.addDestination(FileDestination.init())
        ReachSubjecter.shared.start()
    }
    
}
