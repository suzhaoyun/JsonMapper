//
//  Wrappers.swift
//  JsonMapper
//
//  Created by ZYSu on 2020/6/25.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation

// 1. 所有的JsonMapperWrapper也是一种特殊的JsonMapperProperty
// 2. 包装器会改变property的name，会增加一个下划线
protocol _JsonMapperWrapper: JsonMapperProperty { }

//MARK: - 属性忽略包装器
@propertyWrapper struct JsonIgnore<T>: _JsonMapperWrapper{
    init(wrappedValue: T) {
        self.value = wrappedValue
    }
    var value: T
    var wrappedValue: T {
        set { value = newValue }
        get { value }
    }
    
    // ignore的时候 set/get为空
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        return true
    }
    
    static func get(_ ptr: UnsafeMutableRawPointer) -> Any? {
        return nil
    }
}

//MARK: - 属性名替换
protocol _JsonField: _JsonMapperWrapper {
    // 获取是不是自定义了name
    static func fieldName(_ ptr: UnsafeMutableRawPointer) -> String
}

@propertyWrapper struct JsonField<T>: _JsonField {
    static func fieldName(_ ptr: UnsafeMutableRawPointer) -> String{
        return ptr.assumingMemoryBound(to: Self.self).pointee.name
    }
    
    var name: String
    
    init(wrappedValue: T, _ name: String) {
        self.name = name
        self.value = wrappedValue
    }

    var value: T
    var wrappedValue: T {
        set { value = newValue }
        get { value }
    }
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        let attr = ptr.assumingMemoryBound(to: JsonField<T>.self)
        
        // 对value字段赋值
        if let pt = T.self as? JsonMapperProperty.Type {
            return pt.set(v, ptr: withUnsafeMutablePointer(to: &attr.pointee.value, { UnsafeMutableRawPointer($0) }))
        }
        else if let vv = v as? T {
            attr.pointee.wrappedValue = vv
            return true
        }
        return false
    }
    
    func jm_toJsonValue() -> Any? {
        return (self.value as? JsonMapperProperty)?.jm_toJsonValue()
    }
}

//MARK: - 自定义转换包装器
@propertyWrapper struct JsonTransform<T>: _JsonMapperWrapper {
    
    var mapper: ((Any) -> T)
    
    init(wrappedValue: T, _ mapper: @escaping ((Any) -> T)) {
        self.value = wrappedValue
        self.mapper = mapper
    }

    var value: T
    var wrappedValue: T {
        set { value = newValue }
        get { value }
    }
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        let attr = ptr.assumingMemoryBound(to: JsonTransform<T>.self)
        attr.pointee.wrappedValue = attr.pointee.mapper(v)
        return true
    }
    
    func jm_toJsonValue() -> Any? {
        return (self.value as? JsonMapperProperty)?.jm_toJsonValue()
    }
}

//MARK: - 日期包装器 支持Date/NSDate类型 
protocol _JM_Date {
    func jm_toJsonValue() -> Any?
    static func fromDate(_ date: Date) -> Self?
}

extension Date: _JM_Date {
    func jm_toJsonValue() -> Any? {
        return timeIntervalSince1970
    }

    static func fromDate(_ date: Date) -> Self? { date }
}

extension NSDate: _JM_Date {
    func jm_toJsonValue() -> Any? {
        return timeIntervalSince1970
    }
    
    static func fromDate(_ date: Date) -> Self? {
        return Self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}
fileprivate let dateFormatter: DateFormatter = DateFormatter()

@propertyWrapper struct JsonDate<T: _JM_Date>: _JsonMapperWrapper {
    var format: String
    
    init(wrappedValue: T, _ format: String = "yyyyy-MM-dd HH:mm:ss") {
        self.format = format
        self.value = wrappedValue
    }

    var value: T
    var wrappedValue: T {
        set { value = newValue }
        get { value }
    }
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        let attr = ptr.assumingMemoryBound(to: JsonDate<T>.self)
        dateFormatter.dateFormat = attr.pointee.format
        if let str = v as? String, let d = dateFormatter.date(from: str), let t = T.fromDate(d) {
            attr.pointee.wrappedValue = t
            return true
        }
        else if let d = (v as? _JM_Number)?._jm_number?.doubleValue, let t = T.fromDate(Date.init(timeIntervalSince1970: d)){
            attr.pointee.wrappedValue = t
            return true
        }
        else {
            return false
        }
    }
    
    func jm_toJsonValue() -> Any? {
        return self.value.jm_toJsonValue()
    }
}
