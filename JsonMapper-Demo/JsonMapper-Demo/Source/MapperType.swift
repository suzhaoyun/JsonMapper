//
//  JsonMappingInfo.swift
//  JsonMapper
//
//  Created by ZYSu on 2020/6/24.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation

//MARK: - 缓存MapperType的信息 防止重复获取
struct MapperTypeCache {
    private static var cache: [UnsafeRawPointer : MapperType] = [:]
    private static let typeLock = NSRecursiveLock()

    static func set(_ obj: MapperType, key: Any.Type) {
        typeLock.lock()
        defer { typeLock.unlock() }
        cache[TypeRawPointer(key)] = obj
    }
    
    static func get(_ key: Any.Type) -> MapperType? {
        return cache[TypeRawPointer(key)]
    }
}

/// 保存了一个type所以的属性信息
class MapperType {
    let kind: Kind
    init(_ kind: Kind) { self.kind = kind }
    
    struct Property {
        var name: String
        let type: Any.Type
        let offset: Int
        let isVar: Bool
        var jsonKey: [String] = []
    }
    var properties: [Property] = []
}

extension MapperType.Property {
    
    func removePrefixName() -> String {
        if name.hasPrefix("_") {
            let offset = String.Index(utf16Offset: 1, in: name)
            return String(name[offset..<name.endIndex])
        }
        return name
    }
    
    mutating func initWrapperStyle(_ ptr: UnsafeMutableRawPointer) {
        if type is _JsonMapperWrapper.Type {
            if let wt = type as? _JsonField.Type {
                let key = wt.fieldName(ptr + offset)
                self.jsonKey = key.split(separator: ".").map({ String($0) })
            }else{
                self.jsonKey = [self.removePrefixName()]
            }
        }else{
            self.jsonKey = [name]
        }
    }
}

extension MapperType {
    
    /// 生成mappingInfo的核心方法
    /// - Parameters:
    ///   - type: Type
    ///   - m: 对象的mirror
    ///   - modelPtr: 对象指针
    /// - Returns: JsonMappingInfo
    static func create(_ type: Any.Type, modelPtr: UnsafeMutableRawPointer) -> MapperType?{
        // 如果不是JsonMapper直接不处理
        guard type is JsonMapper.Type else { return nil }
        
        let metaPtr = TypeRawPointer(type)
        let kind = Kind(type)
        let info = MapperType(kind)
        var fieldOffsets: [Int] = []
        var superclass: AnyClass?
        var fieldDescriptor: UnsafeMutablePointer<FieldDescriptor>
        var genericContext: UnsafeMutableRawPointer
        var genericArguments: UnsafeMutableRawPointer
        switch kind {
        case .class:
            let clsMetaPtr = metaPtr.assumingMemoryBound(to: ClassMetadataMemoryLaout.self)
            if let ot = type as? NSObject.Type {
                // 直接通过oc的runtime获取offset
                fieldOffsets = ot.getFieldOffsets()
            }else{
                fieldOffsets = clsMetaPtr.pointee.getFieldOffsets()
            }
            genericContext = UnsafeMutableRawPointer(clsMetaPtr.pointee.description)
            genericArguments = clsMetaPtr.pointee.getGenericArgs()
            fieldDescriptor = clsMetaPtr.pointee.getFieldDescriptor
            superclass = clsMetaPtr.pointee.superClass
        case .struct:
            let stPtr = metaPtr.assumingMemoryBound(to: StructMetadataMemoryLaout.self)
            fieldOffsets = stPtr.pointee.getFieldOffsets()
            fieldDescriptor = stPtr.pointee.getFieldDescriptor
            genericContext = UnsafeMutableRawPointer(stPtr.pointee.description)
            genericArguments = stPtr.pointee.getGenericArgs()
        default:
            return nil
        }
        
        // 添加父类属性
        if let superCls = superclass {
            var superInfo: MapperType?
            if let cacheInfo = MapperTypeCache.get(superCls) {
                superInfo = cacheInfo
            }else{
                superInfo = MapperType.create(superCls, modelPtr: modelPtr)
                if let info = superInfo {
                    MapperTypeCache.set(info, key: superCls)
                }
            }
            if let sp = superInfo?.properties {
                info.properties.append(contentsOf: sp)
            }
        }
        
        let count = fieldOffsets.count
        if count == 0 { return info }
        
        for i in 0..<count {
            let fp = fieldDescriptor.pointee.fieldRecords.ptr(i)
            let fieldName = fp.pointee.fieldName()
            if fieldName.isEmpty == false, let type = fp.pointee.getType(genericContext, genericArguments) {
                var p = Property(name: fieldName, type: type, offset: fieldOffsets[Int(i)], isVar: fp.pointee.isVar)
                p.initWrapperStyle(modelPtr)
                info.properties.append(p)
            }else{
                JsonMapperLogger.logWarning("\(type) can't get property{name=\(fieldName)} type")
            }
            
        }
        return info
    }
    
}
