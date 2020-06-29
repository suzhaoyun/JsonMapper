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
        enum WrapperStyle {
            case none
            case ignore
            case attr(String)
        }
        var name: String
        let type: Any.Type
        let offset: Int
        var wrapperStyle: WrapperStyle = .none
    }
    var properties: [String:Property] = [:]
}

extension MapperType.Property {
    
    func removePrefixName() -> String {
        if name.hasPrefix("_") {
            let offset = String.Index(utf16Offset: 1, in: name)
            return String(name[offset..<name.endIndex])
        }
        return name
    }
    
    var key: String {
        if case let .attr(newName) = wrapperStyle, newName.isEmpty == false {
            return newName
        }
        return name
    }
    
    mutating func initWrapperStyle(_ ptr: UnsafeMutableRawPointer) {
        if type is _JsonMapperIgnore.Type {
            self.wrapperStyle = .ignore
        }
        else if let wt = type as? _JsonMapperConfig.Type {
            let replaceName = wt.replaceName(ptr + offset)
            if replaceName.isEmpty {
                self.wrapperStyle = .attr(self.removePrefixName())
            }else{
                self.wrapperStyle = .attr(replaceName)
            }
        }
        else{
            self.wrapperStyle = .none
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
    static func create(_ type: Any.Type, m: Mirror, modelPtr: UnsafeMutableRawPointer) -> MapperType?{
        // 如果不是JsonMapper直接不处理
        guard type is JsonMapper.Type else { return nil }
        
        let metaPtr = TypeRawPointer(type)
        let kind = Kind(type)
        let info = MapperType(kind)
        var fieldOffsets: [Int] = []
        var superclass: AnyClass?
        switch kind {
        case .class:
            let clsMetaPtr = metaPtr.assumingMemoryBound(to: ClassMetadataMemoryLaout.self)
            if let ot = type as? NSObject.Type {
                // 直接通过oc的runtime获取offset
                fieldOffsets = ot.getFieldOffsets()
            }else{
                fieldOffsets = clsMetaPtr.pointee.getFieldOffsets()
            }
            superclass = clsMetaPtr.pointee.superClass
        case .struct:
            fieldOffsets = metaPtr.assumingMemoryBound(to: StructMetadataMemoryLaout.self).pointee.getFieldOffsets()
        default:
            return nil
        }
        
        // 添加父类属性
        if let superCls = superclass, let superM = m.superclassMirror, superM.subjectType != NSObject.self {
            var superInfo: MapperType?
            if let cacheInfo = MapperTypeCache.get(superCls) {
                superInfo = cacheInfo
            }else{
                superInfo = MapperType.create(superCls, m: superM, modelPtr: modelPtr)
                if let info = superInfo { MapperTypeCache.set(info, key: superCls) }
            }
            superInfo?.properties.forEach { (key, v) in
                info.properties.updateValue(v, forKey: key)
            }
        }
        
        let count = fieldOffsets.count
        if count == 0 { return info }
        let children = m.children
        if count != children.count {
            JsonMapperLog("\(type)’s fieldOffset count is not equal mirror children count!")
            return info
        }
        
        for (i, child) in children.enumerated() {
            if let name = child.label, count > i {
                var p = Property(name: name, type: Swift.type(of: child.value), offset: fieldOffsets[Int(i)])
                p.initWrapperStyle(modelPtr)
                info.properties.updateValue(p, forKey: p.key)
            }
        }
        return info
    }
    
}
