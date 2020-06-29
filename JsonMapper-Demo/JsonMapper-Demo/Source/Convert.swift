//
//  Mappers.swift
//  JsonMapper
//
//  Created by ZYSu on 2020/6/25.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

protocol _JM_String {
    var _jm_string: String? { get }
}

extension _JM_String {
    var _jm_string: String? { "\(self)" }
}
/// 所有的基础类型(string/int/float/nsnumber/decimal)均可以互相转化，NSNumber是转换的桥梁
protocol _JM_BasicType: JsonMapperProperty, _JM_String {
    func _jm_toNumber() -> NSNumber?
    static func _jm_fromNumber(_ n: NSNumber) -> Self?
}

extension _JM_BasicType {
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let n = (jsonVal as? _JM_BasicType)?._jm_toNumber() {
            return Self._jm_fromNumber(n)
        }
        return nil
    }
}

private let numberFormatter: NumberFormatter = {
    let fm = NumberFormatter()
    fm.numberStyle = .decimal
    return fm
}()


extension String: _JM_BasicType, _JM_String {
    
    var _jm_string: String? { return self }
    
    func _jm_toNumber() -> NSNumber? {
        switch self.lowercased() {
        case "true", "yes", "1":
            return NSNumber(value: true)
        case "false", "no", "nil", "null", "0":
            return NSNumber(value: false)
        default:
            if let d = Decimal(string: self) { return NSDecimalNumber(decimal: d) }
            return nil
        }
    }
    
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let n = (jsonVal as? _JM_String)?._jm_string{
            return n
        }
        return nil
    }
    
    static func _jm_fromNumber(_ n: NSNumber) -> String? {
        return n.stringValue
    }
}
//protocol _JM_ObjcType: _JM_BasicType {
//    static func _jm_fromJsonValue(_ jsonVal: Any) -> _JM_ObjcType?
//}

extension NSString: _JM_BasicType, _JM_String {
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        if let str = String._jm_fromJsonValue(v) {
            ptr.assumingMemoryBound(to: NSMutableString.self).pointee = NSMutableString(string: str)
            return true
        }
        return false
    }
    
    var _jm_string: String? { return self as String }
    func _jm_toNumber() -> NSNumber? {
        return (self as String)._jm_toNumber()
    }
    static func _jm_fromNumber(_ n: NSNumber) -> Self? {
        if let str = String._jm_fromNumber(n) {
            return Self.init(string: str)
        }
        return nil
    }
}

//INT类型协议有默认实现
protocol _JM_Integer: _JM_BasicType {
    init?(truncating: NSNumber)
}

extension _JM_Integer {
    static func _jm_fromNumber(_ n: NSNumber) -> Self? {
        return Self.init(truncating: n)
    }
    func _jm_toNumber() -> NSNumber? {
        return self as? NSNumber
    }
}

extension Bool: _JM_Integer {}
extension UInt: _JM_Integer {}
extension Int: _JM_Integer {}
extension Int8: _JM_Integer {}
extension UInt8: _JM_Integer {}
extension Int16: _JM_Integer {}
extension UInt16: _JM_Integer {}
extension Int32: _JM_Integer {}
extension UInt32: _JM_Integer {}
extension Int64: _JM_Integer {}
extension UInt64: _JM_Integer {}

// Float类型
protocol _JM_Float: _JM_BasicType {}
extension _JM_Float {
    // 特殊处理  NSDecimalNumber as Float之后精度有问题, 所以不能进行as处理 一定要经过转换
    static func __jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let n = (jsonVal as? _JM_BasicType)?._jm_toNumber() {
            return Self._jm_fromNumber(n)
        }
        return jsonVal as? Self
    }
}

extension Float: _JM_Float {
    static func _jm_fromNumber(_ n: NSNumber) -> Float? {
        return Float(n.stringValue)
    }
    func _jm_toNumber() -> NSNumber? { return NSNumber(value: self) }
}

extension Double: _JM_Float {
    static func _jm_fromNumber(_ n: NSNumber) -> Double? {
        return Double(n.stringValue)
    }
    func _jm_toNumber() -> NSNumber? { return NSNumber(value: self) }
}

#if canImport(CoreGraphics)
extension CGFloat: _JM_Float {
    func _jm_toNumber() -> NSNumber? { NSNumber(value: Double(self)) }
    static func _jm_fromNumber(_ n: NSNumber) -> CGFloat? {
        if let v = Double(n.stringValue) { return CGFloat(v) }
        return nil
    }
}
#endif

// NSString/NSNumber/NSArray/NSDictionay是类簇，需特殊处理
protocol _JM_Objc_Type: JsonMapperProperty {}

extension NSNumber: _JM_Float {
    func _jm_toNumber() -> NSNumber? {
        return self
    }
    var _jm_string: String? { self.stringValue }

    static func _jm_fromNumber(_ n: NSNumber) -> Self? {
        if let nn = n as? Self { return nn }
        if Self.self is NSDecimalNumber.Type {
            return NSDecimalNumber.init(decimal: n.decimalValue) as? Self
        }
        return numberFormatter.number(from: n.stringValue) as? Self
    }
}

extension Decimal: _JM_Float {
    static func _jm_fromNumber(_ n: NSNumber) -> Self? {
        return n.decimalValue
    }
    
    func _jm_toNumber() -> NSNumber? {
        return NSDecimalNumber(decimal: self)
    }
}

extension URL: JsonMapperProperty, _JM_String {
    var _jm_string: String? { absoluteString}
    func _jm_toJsonValue() -> Any? { absoluteString }
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let urlstr = (jsonVal as? _JM_String)?._jm_string {
           return Self.init(string: urlstr)
        }
        return nil
    }
}

extension NSURL: JsonMapperProperty, _JM_String {
    var _jm_string: String? { absoluteString}
    func _jm_toJsonValue() -> Any? { absoluteString }
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let urlstr = (jsonVal as? _JM_String)?._jm_string  {
            return Self.init(string: urlstr)
        }
        return nil
    }
}

extension Data: JsonMapperProperty, _JM_String {
    var _jm_string: String? { String(data: self, encoding: .utf8) }

    func _jm_toJsonValue() -> Any? {
        return _jm_string
    }
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let urlstr = (jsonVal as? _JM_String)?._jm_string {
            return urlstr.data(using: .utf8)
        }
        return nil
    }
}

extension NSData: JsonMapperProperty, _JM_String {
    var _jm_string: String? {String(data: self as Data, encoding: .utf8) }
    func _jm_toJsonValue() -> Any? {
        return _jm_string
    }
    
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let data = jsonVal as? Data {
            return Self.init(data: data)
        }else if let urlstr = (jsonVal as? _JM_String)?._jm_string, let data = urlstr.data(using: .utf8) {
            return Self.init(data: data)
        }
        return nil
    }
}

protocol _JM_Collection: _JM_String {}
extension _JM_Collection {
    var _jm_string: String? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension Array: JsonMapperProperty, _JM_Collection {
    
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Array<Element>? {
        guard let arr = jsonVal as? [Any] else {
            return nil
        }
        guard let et = Element.self as? JsonMapperProperty.Type else {
            return nil
        }
        var models:[Element] = []
        for dict in arr {
            if let v = et._jm_fromJsonValue(dict) as? Element {
                models.append(v)
            }
        }
        return models
    }
    
    func _jm_toJsonValue() -> Any? {
        guard Element.self is JsonMapperProperty.Type else {
            return self
        }
        return self.compactMap({
            ($0 as? JsonMapperProperty)?._jm_toJsonValue()
        })
    }
}

extension NSArray: JsonMapperProperty, _JM_Collection {
    
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let a = jsonVal as? [Any] {
            return Self.init(array: a)
        }
        return jsonVal as? Self
    }
    
    func _jm_toJsonValue() -> Any? {
        return (self as? Array<Any>)?._jm_toJsonValue()
    }
}

extension NSDictionary: JsonMapperProperty, _JM_Collection {
 
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        return jsonVal as? Self
    }
    
    func _jm_toJsonValue() -> Any? {
        return (self as? [String:Any])?._jm_toJsonValue()
    }
}

extension Dictionary: JsonMapperProperty, _JM_Collection {
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self<Key, Value>? {
        return jsonVal as? Self<Key, Value>
    }
}

protocol _JsonMapperOptionalValue {
    func _jm_unwrappedValue() -> Any?
}

extension Optional: JsonMapperProperty, _JsonMapperOptionalValue {
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Optional<Wrapped>? {
        if let x = Wrapped.self as? JsonMapperProperty.Type {
            if let y = x._jm_fromJsonValue(jsonVal), let v = y as? Wrapped {
                return Optional.some(v)
            }
        }
        return Optional.none
    }
    
    func _jm_toJsonValue() -> Any? { return _jm_unwrappedValue() }
    
    func _jm_unwrappedValue() -> Any? {
        if let v = self {
            if let vv = v as? _JsonMapperOptionalValue{
                return vv._jm_unwrappedValue()
            }
            return v
        }
        return nil
    }
}

extension RawRepresentable where Self: JsonMapperProperty {
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if let rt = RawValue.self as? JsonMapperProperty.Type {
            if let v = rt._jm_fromJsonValue(jsonVal), let rv = v as? RawValue, let e = Self(rawValue: rv) {
                return e
            }
        }
        return nil
    }
    
    func _jm_toJsonValue() -> Any? {
        if let v = self.rawValue as? JsonMapperProperty {
            return v._jm_toJsonValue()
        }
        return nil
    }
}

// JsonMappingAttr也是一种特殊的Property
extension JsonMapperConfig: JsonMapperProperty{
    
    static func _jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        return nil
    }
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        let attr = ptr.assumingMemoryBound(to: JsonMapperConfig<T>.self)
        // 执行mapper
        if let m = attr.pointee.mapper {
            attr.pointee.value = m(v)
            return true
        }
        // 对value字段赋值
        if let pt = T.self as? JsonMapperProperty.Type {
            if let rv = pt._jm_fromJsonValue(v) as? T {
                attr.pointee.value = rv
                return true
            }
        }
        return false
    }
    
    func _jm_toJsonValue() -> Any? {
        if let v = self.value as? JsonMapperProperty {
            return v._jm_toJsonValue()
        }
        return nil
    }
}

