//
//  Mapping.swift
//  JsonMapper
//
//  Created by ZYSu on 2020/6/22.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation

//MARK: - 支持转换的属性需要遵循的协议
protocol JsonMapperProperty {
    // 底层赋值取值方法
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool
    static func get(_ ptr: UnsafeMutableRawPointer) -> Any?
    
    // 最核心转换方法
    static func jm_fromJsonValue(_ jsonVal: Any) -> Self?
    func jm_toJsonValue() -> Any?
    
    // 经过Optional解包之后
    static func _jm_fromUnwrappedJsonValue(_ jsonVal: Any) -> Self?
    
    // 经过jsonVal as? Self过滤之后
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self?
}

//MARK - JsonMapperProperty的默认实现
/**
    set调用顺序
    set() -> jm_fromJsonValue -> _jm_fromUnwrappedJsonValue -> _jm_fromUnSelfJsonValue
 
    get调用顺序
    get -> jm_toJsonValue
 */
extension JsonMapperProperty {
    
    static func jm_fromJsonValue(_ jsonVal: Any) -> Self? {
        // 如果是optional把jsonVal解包
        if let v = (jsonVal as? _JsonMapperOptionalValue)?._jm_unwrappedValue() {
            return _jm_fromUnwrappedJsonValue(v)
        }
        return _jm_fromUnwrappedJsonValue(jsonVal)
    }
    
    static func set(_ v: Any, ptr: UnsafeMutableRawPointer) -> Bool {
        if let rv = jm_fromJsonValue(v) {
            ptr.assumingMemoryBound(to: Self.self).pointee = rv
            return true
        }
        return false
    }
    
    static func get(_ ptr: UnsafeMutableRawPointer) -> Any? {
        return ptr.assumingMemoryBound(to: Self.self).pointee.jm_toJsonValue()
    }
    
    // 首先看是否可以直接转换成当前类型，但浮点数和Number这里有问题 需要特殊处理
    static func _jm_fromUnwrappedJsonValue(_ jsonVal: Any) -> Self? {
        if let sv = jsonVal as? Self { return sv }
        return _jm_fromUnSelfJsonValue(jsonVal)
    }
    
    // 默认实现是直接转换成Self
    static func _jm_fromUnSelfJsonValue(_ jsonVal: Any) -> Self? {
        return jsonVal as? Self
    }

    // 转换成json字典时，默认就是将self放入字典
    func jm_toJsonValue() -> Any? { return self }
}

// JsonMapping也是一种JsonMappingProperty
protocol JsonMapper: JsonMapperProperty {
    init()
}

// JsonMapping Core 核心代码
extension JsonMapper {
    // 获取对象对应的类型信息
    mutating func mapperType() -> MapperType? {
        let type = Self.self
        // 获取缓存的info
        if let cacheInfo = MapperTypeCache.get(type) { return cacheInfo }
        
        // 创建jsonMappingInfo
        guard let info = MapperType.create(type, modelPtr: ObjRawPointer(&self)) else {
            return nil
        }

        // 添加缓存
        MapperTypeCache.set(info, key: type)
        return info
    }
    
    func jm_toJsonValue() -> Any? {
        var mutableObj = self
        guard let mapInfo = mutableObj.mapperType() else {
            JsonMapperLogger.logWarning("\(Self.self) can‘t mapping to json because get mapperType failure")
            return nil
        }
        
        var dict: [String:Any] = [:]
        let modelPtr = ObjRawPointer(&mutableObj)
        for p in mapInfo.properties {
            
            // 只能处理支持的类型
            guard let pt = p.type as? JsonMapperProperty.Type else {
                continue
            }
            
            // 只处理有值的属性
            guard let val = pt.get(modelPtr + p.offset) else {
                continue
            }
            
            // 放入字典
            dict.jm_setValueForJsonKey(val, p.jsonKey)
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
            JsonMapperLogger.logWarning("\(Self.self) can‘t mapping from dict because get mapperType failure")
            return model
        }
        
        for pro in mapInfo.properties {
            // 处理不了
            guard let pt = pro.type as? JsonMapperProperty.Type else { continue }
            
            // 只处理var类型
            guard pro.isVar else {
                JsonMapperLogger.logWarning("\(Self.self)‘s property {name=\"\(pro.name)\", type=\(pro.type)} can‘t mapping value because it's a 'let' property, please change to 'var' ")
                continue
            }

            // 未获取到值
            guard let val = dict.jm_valueForJsonKey(pro.jsonKey) else { continue }
            
            // 如果赋值失败
            if pt.set(val, ptr: modelPtr + pro.offset) == false {
                JsonMapperLogger.logWarning("\(Self.self)‘s property {name=\"\(pro.name)\", type=\(pro.type)} can‘t mapping from {value=\(val), type=\(Swift.type(of: val))}")
            }
        }
        return model
    }
    
    static func mapping(_ dictArray: [[String:Any]]) -> [Self] {
        return dictArray.map({ Self.mapping($0) })
    }
}

private extension Dictionary where Key == String, Value == Any {
    
    func jm_valueForJsonKey(_ keys: [String]) -> Any? {
        var lastDict: [String : Any]? = self
        var lastVal: Any? = lastDict
        for k in keys {
            lastVal = lastDict?[k]
            lastDict = lastVal as? [String : Any]
        }
        return lastVal
    }
    
    mutating func jm_setValueForJsonKey(_ val: Any, _ keys: [String]) {
        guard let key = keys.first else { return }
        let count = keys.count
        if count == 1 { updateValue(val, forKey: key); return }
        
        var rsDict = (self[key] as? [String:Any]) ?? [:]
        rsDict.jm_setValueForJsonKey(val, Array<String>(keys[1..<count]))
        updateValue(rsDict, forKey: key)
    }
    
}

//MARK: obj -> json
extension JsonMapper {
    
    func toJson() -> Any? {
        return jm_toJsonValue()
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
