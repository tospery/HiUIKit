//
//  Navigator.swift
//  HiNavigator
//
//  Created by 杨建祥 on 2024/5/16.
//

import UIKit

public enum HiToastStyle: Int {
    case success
    case failure
    case warning
}

public func popOne(viewController: UIViewController, animated: Bool, _ completion: (() -> Void)?) {
    viewController.navigationController?.popViewController(animated: animated, completion)
}

public func popTo(viewController: UIViewController, to: UIViewController, animated: Bool, _ completion: (() -> Void)?) {
    viewController.navigationController?.popToViewController(to, animated: animated)
}

public func popAll(viewController: UIViewController, animated: Bool, _ completion: (() -> Void)?) {
    viewController.navigationController?.popToRootViewController(animated: animated)
}

public func dismiss(viewController: UIViewController, animated: Bool, _ completion: (() -> Void)?) {
    viewController.dismiss(animated: animated, completion: completion)
}
