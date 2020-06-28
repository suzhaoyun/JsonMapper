//
//  Mappers.swift
//  SSMapping
//
//  Created by ZYSu on 2020/6/25.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif
protocol _JMString {
    var string: String { get }
}

protocol _JMNumber {
    var number: NSNumber { get }
}

extension String: _JMString, _JMNumber {
    var string: String { self }
    var number: NSNumber {
        switch self.lowercased() {
        case "true", "yes", "1":
            return NSNumber(value: true)
        case "false", "no", "nil", "null", "0":
            return NSNumber(value: false)
        default:
            return NSDecimalNumber(string: self)
        }
    }
}

extension NSString: _JMString, _JMNumber {
    var string: String { self as String }
    var number: NSNumber { (self as String).number }
}

extension JsonMapper {
    static func _jm_convert(from jsonVal: Any) -> Self? {
        if let dict = jsonVal as? [String:Any] {
            return Self.mapping(dict)
        }
        return nil
    }
}

extension String: JsonMapperProperty {
    static func _jm_convert(from jsonVal: Any) -> String? {
        return (jsonVal as? _JMString)?.string
    }
}
extension NSString: JsonMapperProperty {
    static func _jm_convert(from jsonVal: Any) -> Self? {
        return (jsonVal as? _JMString)?.string as? Self
    }
}

protocol NumberProperty: JsonMapperProperty {
    init?(truncating: NSNumber)
}

extension NumberProperty {
    init?(truncating: NSNumber){ self.init(truncating: truncating)}
    static func _jm_convert(from jsonVal: Any) -> Self? {
        if let n = jsonVal as? _JMNumber {
            return Self.init(truncating: n.number)
        }
        return nil
    }
}
extension _JMString {
    var string: String { return String("\(self)") }
}
extension Bool: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
    var string: String { return self ? "true" : "false" }
}
extension Int: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension UInt: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension Int8: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension UInt8: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension Int16: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension UInt16: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension Int32: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension UInt32: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension Int64: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension UInt64: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension Float: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}
extension Double: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: self) }
}

#if canImport(CoreGraphics)
extension CGFloat: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { NSNumber(value: Double(self)) }
}
#endif

extension NSNumber: NumberProperty, _JMNumber, _JMString {
    var number: NSNumber { self }
}

extension Array: JsonMapperProperty {
    static func _jm_convert(from jsonVal: Any) -> Array<Element>? {
        guard let arr = jsonVal as? [[String:Any]] else {
            return nil
        }
        guard let et = Element.self as? JsonMapperProperty.Type else {
            return nil
        }
        var models:[Element] = []
        for dict in arr {
            if let v = et._jm_convert(from: dict) as? Element {
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

extension NSArray: JsonMapperProperty {
    static func _jm_convert(from jsonVal: Any) -> Self? {
        if let a = jsonVal as? [Any] {
            return Self.init(array: a)
        }
        return jsonVal as? Self
    }
    
    func _jm_toJsonValue() -> Any? {
        return (self as? Array<Any>)?._jm_toJsonValue()
    }
}

extension NSDictionary: JsonMapperProperty {
    static func _jm_convert(from jsonVal: Any) -> Self? {
        return jsonVal as? Self
    }
    
    func _jm_toJsonValue() -> Any? {
        return (self as? [String:Any])?._jm_toJsonValue()
    }
}

extension Dictionary: JsonMapperProperty {
    static func _jm_convert(from jsonVal: Any) -> Dictionary<Key, Value>? {
        return jsonVal as? Dictionary<Key, Value>
    }
}

extension Optional: JsonMapperProperty {
    static func _jm_convert(from jsonVal: Any) -> Optional<Wrapped>? {
        if let x = Wrapped.self as? JsonMapperProperty.Type {
            if let y = x._jm_convert(from: jsonVal), let v = y as? Wrapped {
                return Optional.some(v)
            }
        }
        return Optional.none
    }
    
    func _jm_toJsonValue() -> Any? {
        if let v = self, let vv = v as? JsonMapperProperty {
            return vv._jm_toJsonValue()
        }
        return nil
    }
}

extension RawRepresentable where Self: JsonMapperProperty {
    static func _jm_convert(from jsonVal: Any) -> Self? {
        if let rt = RawValue.self as? JsonMapperProperty.Type {
            if let v = rt._jm_convert(from: jsonVal), let rv = v as? RawValue, let e = Self(rawValue: rv) {
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
    
    static func _jm_convert(from jsonVal: Any) -> Self? {
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
            if let rv = pt._jm_convert(from: v) as? T {
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

