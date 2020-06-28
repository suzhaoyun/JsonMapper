//
//  Mapping.swift
//  SSMapping
//
//  Created by ZYSu on 2020/6/22.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation

//MARK: - 支持转换的属性需要遵循的协议
protocol JsonMapperProperty {
    // 将jsonVal转换成当前类型
    static func _jm_convert(from jsonVal: Any) -> Self?
    // 转换成json字典需要的数据
    func _jm_toJsonValue() -> Any?
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool
    static func get(_ ptr: UnsafeMutableRawPointer) -> Any?
}

extension JsonMapperProperty {
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        if let rv = _jm_convert(from: v) {
            ptr.assumingMemoryBound(to: Self.self).pointee = rv
            return true
        }
        return false
    }
    
    static func get(_ ptr: UnsafeMutableRawPointer) -> Any? {
        return ptr.assumingMemoryBound(to: Self.self).pointee._jm_toJsonValue()
    }
    
    // 转换成json字典时，默认就是将self放入字典
    func _jm_toJsonValue() -> Any? { return self }
}

// JsonMapping也是一种JsonMappingProperty
protocol JsonMapper: JsonMapperProperty {
    init()
}

// JsonMapping Core 核心代码
private extension JsonMapper {
    // 获取对象对应的类型信息
    mutating func mapperType() -> MapperType? {
        let type = Self.self
        // 获取缓存的info
        if let cacheInfo = MapperTypeCache.get(type) {
            return cacheInfo
        }
        
        // 创建jsonMappingInfo
        guard let info = MapperType.create(type, m: Mirror(reflecting: self), modelPtr: ObjRawPointer(&self)) else {
            return nil
        }

        // 添加缓存
        MapperTypeCache.set(info, key: type)
        return info
    }
    
    func _jm_toJsonValue() -> Any? {
        var mutableObj = self
        guard let mapInfo = mutableObj.mapperType() else {
            JsonMapperLog("\(Self.self) can‘t mapping to json because get mapperType failure")
            return nil
        }
        
        var dict: [String:Any] = [:]
        let modelPtr = ObjRawPointer(&mutableObj)
        for (_,p) in mapInfo.properties {
            
            // 如果是ignore的key直接忽略
            if case .ignore = p.wrapperStyle { continue }
            
            // 如果有值才放入字典
            if let pt = p.type as? JsonMapperProperty.Type, let val = pt.get(modelPtr + p.offset) {
                dict.updateValue(val, forKey: p.key)
            }else{
                JsonMapperLog("\(Self.self)‘s property {name=\"\(p.name)\", type=\(p.type)} unsupport to jsonValue")
            }
        }
        return dict
    }
}

//MARK: json -> obj
extension JsonMapper {
    
    static func mapping(_ dict: [String:Any]) -> Self {
        var model:Self
        if let ot = Self.self as? NSObject.Type {
            model = ot.jm_createObj() as! Self
        }else{
            model = Self.init()
        }
            
        let modelPtr = ObjRawPointer(&model)
        guard let mapInfo = model.mapperType() else {
            JsonMapperLog("\(Self.self) can‘t mapping from dict because get mapperType failure")
            return model
        }
        for obj in dict {
            // 如果有这个key才进行处理
            guard let propertie = mapInfo.properties[obj.key] else { continue }
            
            // 如果是ignore的key直接忽略
            if case .ignore = propertie.wrapperStyle { continue }
            
            // 如果是NSNull
            if obj.value is NSNull.Type { continue }
            
            // 赋值
            if let pt = propertie.type as? JsonMapperProperty.Type, pt.set(obj.value, ptr: modelPtr + propertie.offset) {
            }else{
                JsonMapperLog("\(Self.self)‘s property {name=\"\(propertie.name)\", type=\(propertie.type)} can‘t mapping from {value=\(obj.value), type=\(Swift.type(of: obj.value))}")
            }
        }
        return model
    }
    
    static func mapping(_ dictArray: [[String:Any]]) -> [Self] {
        return dictArray.map({ Self.mapping($0) })
    }
}

//MARK: obj -> json
extension JsonMapper {
    
    func toJson() -> Any? {
        return _jm_toJsonValue()
    }
    
    func toJsonData() -> Data? {
        guard let jsonObj = toJson() else { return nil }
        return try? JSONSerialization.data(withJSONObject: jsonObj, options: .fragmentsAllowed)
    }
    
    func toJsonString() -> String? {
        if let data = toJsonData() { return String(data: data, encoding: .utf8) }
        return nil
    }
}

// NSObject类init特殊处理
extension NSObject {
    
    class func jm_createObj() -> NSObject {
        return Self.init()
    }
    
    static func getFieldOffsets() -> [Int] {
        var fieldOffsets: [Int] = []
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        if let list = class_copyIvarList(self, countPtr) {
            for i in 0..<Int(countPtr.pointee) {
                fieldOffsets.append(ivar_getOffset(list[i]))
            }
        }
        countPtr.deallocate()
        return fieldOffsets
    }
}
