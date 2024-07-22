//
//  Function.swift
//  HiCore
//
//  Created by 杨建祥 on 2024/5/20.
//

import UIKit
import DeviceKit

// MARK: - Metric
/// 以390为标准，按设备宽度进行比例布局。
public func metric(_ width: CGFloat) -> CGFloat {
    Foundation.ceil((width == CGFloat.leastNormalMagnitude ? 0 : width) * UIScreen.main.scale) / UIScreen.main.scale
}

// MARK: - Preferred
/// 区分全面屏和非全面屏
public func preferredValue(notched: CGFloat, other: CGFloat) -> CGFloat {
    isNotchedScreen ? notched : other
}

/// 将所有屏幕按照宽松/紧凑分类，其中 iPad、iPhone XS Max/XR/Plus 均为宽松屏幕，但开启了放大模式的设备均会视为紧凑屏幕
public func preferredValue(regular: CGFloat, compact: CGFloat) -> CGFloat {
    isRegularScreen ? regular : compact
}

/// 小中大屏幕分类
public func preferredValue(small: CGFloat, middle: CGFloat, large: CGFloat) -> CGFloat {
    if isSmallScreen {
        return small
    } else if isLargeScreen {
        return large
    } else {
        return middle
    }
}

public func compareVersion(_ version1: String, _ version2: String, amount: Int = 3) -> ComparisonResult {
    version1.compare(version2, options: .numeric)
}

public func compareAny(_ left: Any?, _ right: Any?) -> Bool {
    if left == nil && right == nil {
        return true
    }
    if left == nil && right != nil {
        return false
    }
    if left != nil && right == nil {
        return false
    }
    if type(of: left) != type(of: right) {
        return false
    }
    if Mirror(reflecting: left).displayStyle != Mirror(reflecting: right).displayStyle {
        return false
    }
    if let leftBool = left as? Bool,
       let rightBool = right as? Bool {
        return leftBool == rightBool
    }
    if let leftInt = left as? Int,
       let rightInt = right as? Int {
        return leftInt == rightInt
    }
    if let leftDouble = left as? Double,
       let rightDouble = right as? Double {
        return leftDouble == rightDouble
    }
    if let leftString = left as? String,
       let rightString = right as? String {
        return leftString == rightString
    }
    
    if let leftArray = left as? [Any],
        let rightArray = right as? [Any] {
        if leftArray.count != rightArray.count {
            return false
        }
        for (leftElement, rightElement) in zip(leftArray, rightArray) {
            let result = compareAny(leftElement, rightElement)
            if result == true {
                continue
            }
            return false
        }
        return true
    }
    if let leftDict = left as? [String: Any],
        let rightDict = right as? [String: Any] {
        if leftDict.count != rightDict.count {
            return false
        }
        for (leftElement, rightElement) in zip(leftDict, rightDict) {
            let result = compareAny(leftElement, rightElement)
            if result == true {
                continue
            }
            return false
        }
        return true
    }
    if let leftEquatable = toAnyEquatable(left),
       let rightEquatable = toAnyEquatable(right) {
        return leftEquatable.isEqual(to: rightEquatable)
    }
    if let leftHashable = left as? (any Hashable),
       let rightHashable = right as? any Hashable {
        return leftHashable.hashValue == rightHashable.hashValue
    }
    if let leftConvertible = left as? CustomStringConvertible,
       let rightConvertible = right as? CustomStringConvertible {
        return leftConvertible.description == rightConvertible.description
    }
    if let leftNSObject = left as? NSObject,
       let rightNSObject = right as? NSObject {
        return leftNSObject.isEqual(rightNSObject)
    }
    let leftString = String.init(describing: left!)
    let rightString = String.init(describing: right!)
    return leftString == rightString
}

private protocol AnyEquatable {
    func isEqual(to other: AnyEquatable?) -> Bool
}

private func toAnyEquatable(_ value: Any) -> AnyEquatable? {
    if let equatableValue = value as? any Equatable {
        return AnyEquatableBox(equatableValue)
    }
    return nil
}

private struct AnyEquatableBox: AnyEquatable {
    private let base: Any
    private let _isEqual: (AnyEquatable?) -> Bool

    init<T: Equatable>(_ base: T) {
        self.base = base
        self._isEqual = { other in
            guard let otherValue = other as? AnyEquatableBox, let otherBase = otherValue.base as? T else { return false }
            return base == otherBase
        }
    }

    func isEqual(to other: AnyEquatable?) -> Bool {
        return _isEqual(other)
    }
}

//public func compareModels(_ left: [[any Hashable]]?, _ right: [[any Hashable]]?) -> Bool {
//    if left == nil && right == nil {
//        return true
//    }
//    if left == nil && right != nil {
//        return false
//    }
//    if left != nil && right == nil {
//        return false
//    }
//    if left!.count != right!.count {
//        return false
//    }
//    for (index1, array1) in left!.enumerated() {
//        let array2 = right![index1]
//        if array1.count != array2.count {
//            return false
//        }
//        for (index2, model2) in array2.enumerated() {
//            let model1 = array1[index2]
//            // if model1 != model2 {
//            if model1.hashValue != model2.hashValue {
//                return false
//            } else {
//                let leftString = String.init(describing: model1)
//                let rightString = String.init(describing: model2)
//                if leftString != rightString {
//                    return false
//                }
//            }
//        }
//    }
//    return true
//}

public func compareImage(_ left: ImageSource?, _ right: ImageSource?) -> Bool {
    if let lImage = left as? UIImage,
       let rImage = right as? UIImage {
        return lImage == rImage
    }
    if let lURL = left as? URL,
       let rURL = right as? URL {
        return lURL == rURL
    }
    return false
}

public func strongify<Context1: AnyObject>(weak context1: Context1?, closure: @escaping(Context1) -> Void) -> () -> Void {
    return { [weak context1] in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1)
    }
}

public func strongify<Context1: AnyObject, Argument1>(weak context1: Context1?, closure: @escaping(Context1, Argument1) -> Void) -> (Argument1) -> Void {
    return { [weak context1] argument1 in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1, argument1)
    }
}

public func strongify<Context1: AnyObject, Argument1, Argument2>(weak context1: Context1?, closure: @escaping(Context1, Argument1, Argument2) -> Void) -> (Argument1, Argument2) -> Void {
    return { [weak context1] argument1, argument2 in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1, argument1, argument2)
    }
}

public func strongify<Context1: AnyObject, Argument1, Argument2, Argument3>(weak context1: Context1?, closure: @escaping(Context1, Argument1, Argument2, Argument3) -> Void) -> (Argument1, Argument2, Argument3) -> Void {
    return { [weak context1] argument1, argument2, argument3 in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1, argument1, argument2, argument3)
    }
}

public func strongify<Context1: AnyObject, Argument1, Argument2, Argument3, Argument4>(weak context1: Context1?, closure: @escaping(Context1, Argument1, Argument2, Argument3, Argument4) -> Void) -> (Argument1, Argument2, Argument3, Argument4) -> Void {
    return { [weak context1] argument1, argument2, argument3, argument4 in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1, argument1, argument2, argument3, argument4)
    }
}

public func strongify<Context1: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5>(weak context1: Context1?, closure: @escaping(Context1, Argument1, Argument2, Argument3, Argument4, Argument5) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5) -> Void {
    return { [weak context1] argument1, argument2, argument3, argument4, argument5 in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1, argument1, argument2, argument3, argument4, argument5)
    }
}

public func strongify<Context1: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>(weak context1: Context1?, closure: @escaping(Context1, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void {
    return { [weak context1] argument1, argument2, argument3, argument4, argument5, argument6 in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1, argument1, argument2, argument3, argument4, argument5, argument6)
    }
}

public func strongify<Context1: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>(weak context1: Context1?, closure: @escaping(Context1, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void {
    return { [weak context1] argument1, argument2, argument3, argument4, argument5, argument6, argument7 in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1, argument1, argument2, argument3, argument4, argument5, argument6, argument7)
    }
}

public func strongify<Context1: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>(weak context1: Context1?, closure: @escaping(Context1, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void {
    return { [weak context1] argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8 in
        guard let strongContext1 = context1 else { return }
        closure(strongContext1, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2) -> Void) -> () -> Void {
    return { [weak context1, weak context2] in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Argument1>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2, Argument1) -> Void) -> (Argument1) -> Void {
    return { [weak context1, weak context2] argument1 in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2, argument1)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Argument1, Argument2>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2, Argument1, Argument2) -> Void) -> (Argument1, Argument2) -> Void {
    return { [weak context1, weak context2] argument1, argument2 in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2, argument1, argument2)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Argument1, Argument2, Argument3>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2, Argument1, Argument2, Argument3) -> Void) -> (Argument1, Argument2, Argument3) -> Void {
    return { [weak context1, weak context2] argument1, argument2, argument3 in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2, argument1, argument2, argument3)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Argument1, Argument2, Argument3, Argument4>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2, Argument1, Argument2, Argument3, Argument4) -> Void) -> (Argument1, Argument2, Argument3, Argument4) -> Void {
    return { [weak context1, weak context2] argument1, argument2, argument3, argument4 in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2, argument1, argument2, argument3, argument4)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2, Argument1, Argument2, Argument3, Argument4, Argument5) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5) -> Void {
    return { [weak context1, weak context2] argument1, argument2, argument3, argument4, argument5 in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2, argument1, argument2, argument3, argument4, argument5)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void {
    return { [weak context1, weak context2] argument1, argument2, argument3, argument4, argument5, argument6 in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2, argument1, argument2, argument3, argument4, argument5, argument6)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void {
    return { [weak context1, weak context2] argument1, argument2, argument3, argument4, argument5, argument6, argument7 in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2, argument1, argument2, argument3, argument4, argument5, argument6, argument7)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>(weak context1: Context1?, _ context2: Context2?, closure: @escaping(Context1, Context2, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void {
    return { [weak context1, weak context2] argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8 in
        guard let strongContext1 = context1, let strongContext2 = context2 else { return }
        closure(strongContext1, strongContext2, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3) -> Void) -> () -> Void {
    return { [weak context1, weak context2, weak context3] in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Argument1>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3, Argument1) -> Void) -> (Argument1) -> Void {
    return { [weak context1, weak context2, weak context3] argument1 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3, argument1)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Argument1, Argument2>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3, Argument1, Argument2) -> Void) -> (Argument1, Argument2) -> Void {
    return { [weak context1, weak context2, weak context3] argument1, argument2 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3, argument1, argument2)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Argument1, Argument2, Argument3>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3, Argument1, Argument2, Argument3) -> Void) -> (Argument1, Argument2, Argument3) -> Void {
    return { [weak context1, weak context2, weak context3] argument1, argument2, argument3 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3, argument1, argument2, argument3)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Argument1, Argument2, Argument3, Argument4>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3, Argument1, Argument2, Argument3, Argument4) -> Void) -> (Argument1, Argument2, Argument3, Argument4) -> Void {
    return { [weak context1, weak context2, weak context3] argument1, argument2, argument3, argument4 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3, argument1, argument2, argument3, argument4)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3, Argument1, Argument2, Argument3, Argument4, Argument5) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5) -> Void {
    return { [weak context1, weak context2, weak context3] argument1, argument2, argument3, argument4, argument5 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3, argument1, argument2, argument3, argument4, argument5)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void {
    return { [weak context1, weak context2, weak context3] argument1, argument2, argument3, argument4, argument5, argument6 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3, argument1, argument2, argument3, argument4, argument5, argument6)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void {
    return { [weak context1, weak context2, weak context3] argument1, argument2, argument3, argument4, argument5, argument6, argument7 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3, argument1, argument2, argument3, argument4, argument5, argument6, argument7)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, closure: @escaping(Context1, Context2, Context3, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void {
    return { [weak context1, weak context2, weak context3] argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3 else { return }
        closure(strongContext1, strongContext2, strongContext3, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4) -> Void) -> () -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Argument1>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4, Argument1) -> Void) -> (Argument1) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] argument1 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, argument1)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Argument1, Argument2>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4, Argument1, Argument2) -> Void) -> (Argument1, Argument2) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] argument1, argument2 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, argument1, argument2)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Argument1, Argument2, Argument3>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4, Argument1, Argument2, Argument3) -> Void) -> (Argument1, Argument2, Argument3) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] argument1, argument2, argument3 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, argument1, argument2, argument3)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Argument1, Argument2, Argument3, Argument4>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4, Argument1, Argument2, Argument3, Argument4) -> Void) -> (Argument1, Argument2, Argument3, Argument4) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] argument1, argument2, argument3, argument4 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, argument1, argument2, argument3, argument4)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4, Argument1, Argument2, Argument3, Argument4, Argument5) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] argument1, argument2, argument3, argument4, argument5 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, argument1, argument2, argument3, argument4, argument5)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] argument1, argument2, argument3, argument4, argument5, argument6 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, argument1, argument2, argument3, argument4, argument5, argument6)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] argument1, argument2, argument3, argument4, argument5, argument6, argument7 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, argument1, argument2, argument3, argument4, argument5, argument6, argument7)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, closure: @escaping(Context1, Context2, Context3, Context4, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4] argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5) -> Void) -> () -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Argument1>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Argument1) -> Void) -> (Argument1) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] argument1 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, argument1)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Argument1, Argument2>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Argument1, Argument2) -> Void) -> (Argument1, Argument2) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] argument1, argument2 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, argument1, argument2)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Argument1, Argument2, Argument3>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Argument1, Argument2, Argument3) -> Void) -> (Argument1, Argument2, Argument3) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] argument1, argument2, argument3 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, argument1, argument2, argument3)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Argument1, Argument2, Argument3, Argument4>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Argument1, Argument2, Argument3, Argument4) -> Void) -> (Argument1, Argument2, Argument3, Argument4) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] argument1, argument2, argument3, argument4 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, argument1, argument2, argument3, argument4)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Argument1, Argument2, Argument3, Argument4, Argument5) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] argument1, argument2, argument3, argument4, argument5 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, argument1, argument2, argument3, argument4, argument5)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] argument1, argument2, argument3, argument4, argument5, argument6 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, argument1, argument2, argument3, argument4, argument5, argument6)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] argument1, argument2, argument3, argument4, argument5, argument6, argument7 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, argument1, argument2, argument3, argument4, argument5, argument6, argument7)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5] argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6) -> Void) -> () -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Argument1>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Argument1) -> Void) -> (Argument1) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] argument1 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, argument1)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Argument1, Argument2>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Argument1, Argument2) -> Void) -> (Argument1, Argument2) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] argument1, argument2 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, argument1, argument2)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Argument1, Argument2, Argument3>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Argument1, Argument2, Argument3) -> Void) -> (Argument1, Argument2, Argument3) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] argument1, argument2, argument3 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, argument1, argument2, argument3)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Argument1, Argument2, Argument3, Argument4>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Argument1, Argument2, Argument3, Argument4) -> Void) -> (Argument1, Argument2, Argument3, Argument4) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] argument1, argument2, argument3, argument4 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, argument1, argument2, argument3, argument4)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Argument1, Argument2, Argument3, Argument4, Argument5) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] argument1, argument2, argument3, argument4, argument5 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, argument1, argument2, argument3, argument4, argument5)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] argument1, argument2, argument3, argument4, argument5, argument6 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, argument1, argument2, argument3, argument4, argument5, argument6)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] argument1, argument2, argument3, argument4, argument5, argument6, argument7 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, argument1, argument2, argument3, argument4, argument5, argument6, argument7)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6] argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7) -> Void) -> () -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Argument1>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Argument1) -> Void) -> (Argument1) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] argument1 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, argument1)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Argument1, Argument2>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Argument1, Argument2) -> Void) -> (Argument1, Argument2) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] argument1, argument2 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, argument1, argument2)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Argument1, Argument2, Argument3>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Argument1, Argument2, Argument3) -> Void) -> (Argument1, Argument2, Argument3) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] argument1, argument2, argument3 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, argument1, argument2, argument3)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Argument1, Argument2, Argument3, Argument4>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Argument1, Argument2, Argument3, Argument4) -> Void) -> (Argument1, Argument2, Argument3, Argument4) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] argument1, argument2, argument3, argument4 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, argument1, argument2, argument3, argument4)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Argument1, Argument2, Argument3, Argument4, Argument5) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] argument1, argument2, argument3, argument4, argument5 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, argument1, argument2, argument3, argument4, argument5)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] argument1, argument2, argument3, argument4, argument5, argument6 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, argument1, argument2, argument3, argument4, argument5, argument6)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] argument1, argument2, argument3, argument4, argument5, argument6, argument7 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, argument1, argument2, argument3, argument4, argument5, argument6, argument7)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7] argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8) -> Void) -> () -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject, Argument1>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8, Argument1) -> Void) -> (Argument1) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] argument1 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8, argument1)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject, Argument1, Argument2>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8, Argument1, Argument2) -> Void) -> (Argument1, Argument2) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] argument1, argument2 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8, argument1, argument2)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject, Argument1, Argument2, Argument3>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8, Argument1, Argument2, Argument3) -> Void) -> (Argument1, Argument2, Argument3) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] argument1, argument2, argument3 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8, argument1, argument2, argument3)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject, Argument1, Argument2, Argument3, Argument4>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8, Argument1, Argument2, Argument3, Argument4) -> Void) -> (Argument1, Argument2, Argument3, Argument4) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] argument1, argument2, argument3, argument4 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8, argument1, argument2, argument3, argument4)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8, Argument1, Argument2, Argument3, Argument4, Argument5) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] argument1, argument2, argument3, argument4, argument5 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8, argument1, argument2, argument3, argument4, argument5)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] argument1, argument2, argument3, argument4, argument5, argument6 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8, argument1, argument2, argument3, argument4, argument5, argument6)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] argument1, argument2, argument3, argument4, argument5, argument6, argument7 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8, argument1, argument2, argument3, argument4, argument5, argument6, argument7)
    }
}

public func strongify<Context1: AnyObject, Context2: AnyObject, Context3: AnyObject, Context4: AnyObject, Context5: AnyObject, Context6: AnyObject, Context7: AnyObject, Context8: AnyObject, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>(weak context1: Context1?, _ context2: Context2?, _ context3: Context3?, _ context4: Context4?, _ context5: Context5?, _ context6: Context6?, _ context7: Context7?, _ context8: Context8?, closure: @escaping(Context1, Context2, Context3, Context4, Context5, Context6, Context7, Context8, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void) -> (Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8) -> Void {
    return { [weak context1, weak context2, weak context3, weak context4, weak context5, weak context6, weak context7, weak context8] argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8 in
        guard let strongContext1 = context1, let strongContext2 = context2, let strongContext3 = context3, let strongContext4 = context4, let strongContext5 = context5, let strongContext6 = context6, let strongContext7 = context7, let strongContext8 = context8 else { return }
        closure(strongContext1, strongContext2, strongContext3, strongContext4, strongContext5, strongContext6, strongContext7, strongContext8, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8)
    }
}
