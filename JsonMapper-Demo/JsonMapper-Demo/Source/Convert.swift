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

protocol _JM_Number {
    // bool/int/float/double/string相互转换
    var _jm_number: NSNumber? { get }
}

extension String: JsonMapperProperty, _JM_String, _JM_Number {
    
    var numberString: String {
        switch self.lowercased() {
        case "true", "yes":
            return "1"
        case "false", "no", "nil", "null":
            return "0"
        default:
            return self
        }
    }
    
    var _jm_number: NSNumber? {
        // Decimal可以将"12.2abc" 12.2读取
        return Decimal(string: numberString).flatMap{ Double("\($0)") }.flatMap{ NSNumber(value: $0) }
    }
    
    var _jm_string: String? { return self }
    
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let str = (jsonVal as? _JM_String)?._jm_string {
            return str
        }
        return nil
    }
}

extension NSString: JsonMapperProperty, _JM_String, _JM_Number {
    
    var _jm_number: NSNumber? { return (self as String)._jm_number }
    var _jm_string: String? { return self as String }
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        if let str = String.jm_fromJsonValue(v) {
            ptr.assumingMemoryBound(to: NSMutableString.self).pointee = NSMutableString(string: str)
            return true
        }
        return false
    }
}

//INT类型协议有默认实现
protocol _JM_Integer:JsonMapperProperty, _JM_Number, _JM_String {
    init?(truncating: NSNumber)
}

extension _JM_Integer {
    var _jm_number: NSNumber? { self as? NSNumber }
    
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let n = (jsonVal as? _JM_Number)?._jm_number {
            return Self.init(truncating: n)
        }
        return nil
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
protocol _JM_Float: JsonMapperProperty, _JM_String, _JM_Number {
    static func fromNumber(_ n: NSNumber) -> Self?
}

extension _JM_Float {
    static func _jm_fromUnwrappedJsonValue(_ jsonVal: Any) -> Self? {
        if let n = (jsonVal as? _JM_Number)?._jm_number {
            return Self.fromNumber(n)
        }
        return jsonVal as? Self
    }
}

extension Float: _JM_Float {
    static func fromNumber(_ n: NSNumber) -> Float? {
        return n.floatValue
    }
    
    var _jm_number: NSNumber? {
        NSNumber(value: self)
    }
}

extension Double: _JM_Float {
    static func fromNumber(_ n: NSNumber) -> Double? {
        return n.doubleValue
    }
    
    var _jm_number: NSNumber? {
        NSNumber(value: self)
    }
}

#if canImport(CoreGraphics)
extension CGFloat: _JM_Float {
    var _jm_number: NSNumber? { NSNumber(value: Double(self)) }
    
    static func fromNumber(_ n: NSNumber) -> CGFloat? {
        return CGFloat(n.doubleValue)
    }
}
#endif

extension Decimal: JsonMapperProperty, _JM_String, _JM_Number {
    
    static func _jm_fromUnwrappedJsonValue(_ jsonVal: Any) -> Decimal? {
        if let str = (jsonVal as? _JM_String)?._jm_string?.numberString {
            return Decimal(string: str)
        }
        return jsonVal as? Self
    }
    
    var _jm_number: NSNumber? {
        if let v = Double("\(self)") { return NSNumber(value: v) }
        return nil
    }
    
    func jm_toJsonValue() -> Any? {
        return _jm_string
    }
}

// NSString/NSNumber/NSArray/NSDictionay是类簇，需特殊处理
extension NSNumber: JsonMapperProperty, _JM_Number, _JM_String {
    
    var _jm_number: NSNumber? {
        return Double(stringValue).flatMap{ NSNumber(value: $0) }
    }
    
    var _jm_string: String? { stringValue }
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        if Self.self is NSDecimalNumber.Type {
            if let str = (v as? _JM_String)?._jm_string?.numberString {
                ptr.assumingMemoryBound(to: NSDecimalNumber.self).pointee =  NSDecimalNumber(string: str)
                return true
            }
            return false
        }
        
        if let n = (v as? _JM_Number)?._jm_number {
            ptr.assumingMemoryBound(to: NSNumber.self).pointee = n
            return true
        }
        return false
    }
}

extension URL: JsonMapperProperty, _JM_String {
    var _jm_string: String? { absoluteString }
    func jm_toJsonValue() -> Any? { absoluteString }
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let urlstr = (jsonVal as? _JM_String)?._jm_string {
           return Self.init(string: urlstr)
        }
        return nil
    }
}

extension NSURL: JsonMapperProperty, _JM_String {
    var _jm_string: String? { absoluteString }
    func jm_toJsonValue() -> Any? { absoluteString }
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let urlstr = (jsonVal as? _JM_String)?._jm_string  {
            return Self.init(string: urlstr)
        }
        return nil
    }
}

extension Data: JsonMapperProperty, _JM_String {
    var _jm_string: String? { String(data: self, encoding: .utf8) }

    func jm_toJsonValue() -> Any? {
        return _jm_string
    }
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let urlstr = (jsonVal as? _JM_String)?._jm_string {
            return urlstr.data(using: .utf8)
        }
        return nil
    }
}

extension NSData: JsonMapperProperty, _JM_String {
    var _jm_string: String? { String(data: self as Data, encoding: .utf8) }
    func jm_toJsonValue() -> Any? {
        return _jm_string
    }
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
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
    
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Array<Element>? {
        guard let arr = jsonVal as? [Any], let et = Element.self as? JsonMapperProperty.Type else {
            return nil
        }
        
        var models:[Element] = []
        for dict in arr {
            if let v = et.jm_fromJsonValue(dict) as? Element {
                models.append(v)
            }else{
                JsonMapperLogger.logWarning("In Array this element \(dict) cant convert to \(Element.self)")
            }
        }
        return models
    }
    
    func jm_toJsonValue() -> Any? {
        guard Element.self is JsonMapperProperty.Type else {
            return []
        }
        return self.compactMap({
            ($0 as? JsonMapperProperty)?.jm_toJsonValue()
        })
    }
}

extension NSArray: JsonMapperProperty, _JM_Collection {
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        if let arr = v as? [Any] {
            ptr.assumingMemoryBound(to: NSMutableArray.self).pointee = NSMutableArray(array: arr)
            return true
        }
        return false
    }
    
    func jm_toJsonValue() -> Any? {
        return (self as? Array<Any>)?.jm_toJsonValue()
    }
}

extension NSDictionary: JsonMapperProperty, _JM_Collection {
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        if let dict = v as? [String:Any] {
            ptr.assumingMemoryBound(to: NSMutableDictionary.self).pointee = NSMutableDictionary(dictionary: dict)
            return true
        }
        return false
    }

    func jm_toJsonValue() -> Any? {
        return (self as? [String:Any])?.jm_toJsonValue()
    }
}

extension Dictionary: JsonMapperProperty, _JM_Collection {
    
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self<Key, Value>? {
        
        guard let dict = jsonVal as? [String:Any] else { return nil }
        guard let vt = Value.self as? JsonMapperProperty.Type else { return nil }
        
        var newDict: [String:Value] = [:]
        for ele in dict {
            if let v = vt.jm_fromJsonValue(ele.value) as? Value {
                newDict.updateValue(v, forKey: ele.key)
            }
        }
        return newDict as? Self<Key, Value>
    }
}

protocol _JsonMapperOptionalValue {
    func _jm_unwrappedValue() -> Any?
}

extension Optional: JsonMapperProperty, _JsonMapperOptionalValue {
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Optional<Wrapped>? {
        if let x = Wrapped.self as? JsonMapperProperty.Type {
            if let y = x.jm_fromJsonValue(jsonVal), let v = y as? Wrapped {
                return Optional.some(v)
            }
        }
        return Optional.none
    }
    
    func jm_toJsonValue() -> Any? { return _jm_unwrappedValue() }
    
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
    
    // 经过jsonVal as? Self过滤之后
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let rt = RawValue.self as? JsonMapperProperty.Type {
            if let v = rt.jm_fromJsonValue(jsonVal), let rv = v as? RawValue {
                return Self(rawValue: rv)
            }
        }
        return nil
    }
    
    func jm_toJsonValue() -> Any? {
        if let v = self.rawValue as? JsonMapperProperty {
            return v.jm_toJsonValue()
        }
        return nil
    }
}
