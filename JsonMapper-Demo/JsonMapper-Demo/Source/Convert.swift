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

extension String: JsonProperty, _JM_String, _JM_Number {
    
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
        return Double(numberString).flatMap{ NSNumber(value: $0) }
    }
    
    var _jm_string: String? { return self }
    
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let str = (jsonVal as? _JM_String)?._jm_string {
            return str
        }
        return nil
    }
}

extension NSString: JsonProperty, _JM_String, _JM_Number {
    
    var _jm_number: NSNumber? { return (self as String)._jm_number }
    var _jm_string: String? { return self as String }
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let str = String.jm_fromJsonValue(jsonVal) {
            return NSMutableString(string: str) as? Self
        }
        return nil
    }
}

//Int类型协议有默认实现
protocol _JM_Integer:JsonProperty, _JM_Number, _JM_String {
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
protocol _JM_Float: JsonProperty, _JM_String, _JM_Number {
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
    static func fromNumber(_ n: NSNumber) -> Self? {
        return n.floatValue
    }
    
    var _jm_number: NSNumber? {
        NSNumber(value: self)
    }
}

extension Double: _JM_Float {
    static func fromNumber(_ n: NSNumber) -> Self? {
        return n.doubleValue
    }
    
    var _jm_number: NSNumber? {
        NSNumber(value: self)
    }
}

#if canImport(CoreGraphics)
extension CGFloat: _JM_Float {
    var _jm_number: NSNumber? { NSNumber(value: Double(self)) }
    
    static func fromNumber(_ n: NSNumber) -> Self? {
        return CGFloat(n.doubleValue)
    }
}
#endif

extension Decimal: JsonProperty, _JM_String, _JM_Number {
    
    static func _jm_fromUnwrappedJsonValue(_ jsonVal: Any) -> Self? {
        if let str = (jsonVal as? _JM_String)?._jm_string?.numberString {
            return Decimal(string: str)
        }
        else if let n = (jsonVal as? _JM_Number)?._jm_number {
            return Decimal(string: n.stringValue)
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
extension NSNumber: JsonProperty, _JM_Number, _JM_String {
    
    var _jm_number: NSNumber? {
        return Double(stringValue).flatMap{ NSNumber(value: $0) }
    }
    
    var _jm_string: String? { stringValue }
    
    static func jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        if Self.self is NSDecimalNumber.Type {
            if let str = (jsonVal as? _JM_String)?._jm_string?.numberString {
                return NSDecimalNumber(string: str) as? Self
            }
            else if let n = (jsonVal as? _JM_Number)?._jm_number {
                return NSDecimalNumber(string: n.stringValue) as? Self
            }
        }
        else if let n = (jsonVal as? _JM_Number)?._jm_number{
            return n as? Self
        }
        return nil
    }
}

extension URL: JsonProperty, _JM_String {
    var _jm_string: String? { absoluteString }
    func jm_toJsonValue() -> Any? { absoluteString }
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let urlstr = (jsonVal as? _JM_String)?._jm_string {
           return Self.init(string: urlstr)
        }
        return nil
    }
}

extension NSURL: JsonProperty, _JM_String {
    var _jm_string: String? { absoluteString }
    func jm_toJsonValue() -> Any? { absoluteString }
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let urlstr = (jsonVal as? _JM_String)?._jm_string  {
            return Self.init(string: urlstr)
        }
        return nil
    }
}

extension Data: JsonProperty, _JM_String {
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

extension NSData: JsonProperty, _JM_String {
    var _jm_string: String? {
        String(data: self as Data, encoding: .utf8)
    }
    
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

extension Array: JsonProperty, _JM_Collection {
    
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        guard let arr = jsonVal as? [Any], let et = Element.self as? JsonProperty.Type else {
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
        guard Element.self is JsonProperty.Type else {
            return []
        }
        return self.compactMap({
            ($0 as? JsonProperty)?.jm_toJsonValue()
        })
    }
}

extension NSArray: JsonProperty, _JM_Collection {
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let arr = jsonVal as? [Any] {
            return NSMutableArray(array: arr) as? Self
        }
        return nil
    }
    
    func jm_toJsonValue() -> Any? {
        return (self as? Array<Any>)?.jm_toJsonValue()
    }
}

extension NSDictionary: JsonProperty {
    
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let dict = jsonVal as? [String:Any] {
            return NSMutableDictionary(dictionary: dict) as? Self
        }
        return nil
    }
    
    func jm_toJsonValue() -> Any? {
        return (self as? [String:Any])?.jm_toJsonValue()
    }
}

extension Dictionary: JsonProperty, _JM_Collection {
    
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        
        guard let dict = jsonVal as? [String:Any] else { return nil }
        guard let vt = Value.self as? JsonProperty.Type else { return nil }
        
        var newDict: [String:Value] = [:]
        for ele in dict {
            if let v = vt.jm_fromJsonValue(ele.value) as? Value {
                newDict.updateValue(v, forKey: ele.key)
            }
        }
        return newDict as? Self
    }
}

protocol _JsonMapperOptionalValue {
    func _jm_unwrappedValue() -> Any?
}

extension Optional: JsonProperty, _JsonMapperOptionalValue {
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let v = (Wrapped.self as? JsonProperty.Type)?.jm_fromJsonValue(jsonVal), let vv = v as? Wrapped {
            return .some(vv)
        }
        else if let wv = jsonVal as? Wrapped {
            return .some(wv)
        }
        return .none
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

extension RawRepresentable where Self: JsonProperty, RawValue: JsonProperty {
    
    // 经过jsonVal as? Self过滤之后
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        if let v = RawValue.jm_fromJsonValue(jsonVal) {
            return Self.init(rawValue: v)
        }
        return nil
    }
    
    func jm_toJsonValue() -> Any? {
        return self.rawValue.jm_toJsonValue()
    }
}
