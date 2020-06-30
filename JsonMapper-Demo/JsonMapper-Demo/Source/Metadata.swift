//
//  Metadata.swift
//  JsonMapper
//
//  Created by ZYSu on 2020/6/23.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation

 struct RelativePointer<T> {
    var offset: Int32
    mutating func getRelativePointer() -> UnsafeMutablePointer<T> {
        let off = offset
        return withUnsafeMutablePointer(to: &self, {
            UnsafeMutableRawPointer($0) + Int(off) }).assumingMemoryBound(to: T.self)
    }
}

struct FieldRecord {
    let flags: Int32
    let _mangledTypeName: Int32
    var _fieldName: RelativePointer<Int8>
    mutating func fieldName() -> String {
        let p = _fieldName.getRelativePointer()
        return String(cString: p)
    }
    var isVar: Bool { return (flags & 0x2) == 0x2 }
}

struct FieldRecordList {
    var _l: FieldRecord
    mutating func ptr(_ i: Int) -> UnsafeMutablePointer<FieldRecord> {
        withUnsafeMutablePointer(to: &self._l, { $0 }) + i
    }
}

struct FieldDescriptor {
    var mangledTypeName: UInt32
    let superclass: UInt32
    let _kind : UInt16
    let fieldRecordSize : UInt16
    let numFields : UInt32
    var fieldRecords: FieldRecordList
}

struct ClassDescriptor {
    let flags: UInt32
    let parent: Int32
    var name: RelativePointer<Int8>
    let accessFunctionPtr: Int32
    var fields: RelativePointer<FieldDescriptor>
    let superclassType: Int32
    let metadataNegativeSizeInWords: UInt32
    let metadataPositiveSizeInWords: UInt32
    let numImmediateMembers: UInt32
    let numFields: UInt32
    let fieldOffsetVectorOffset: Int32
    
    func getOffsets(_ type: Any.Type) -> [Int] {
        return []
    }
    //let genericContextHeader: void
}

struct ClassMetadataMemoryLaout {
    let kind: UnsafeRawPointer
    let superclass: Any.Type

    let runtimeReserved0: UInt
    let runtimeReserved1: UInt
    let rodata: UInt
    let flags: UInt32
    let instanceAddressPoint: UInt32
    let instanceSize: UInt32
    let instanceAlignMask: UInt16
    let reserved: UInt16
    let classSize: UInt32
    let classAddressPoint: UInt32
    var description: UnsafeMutablePointer<ClassDescriptor>
    let iVarDestroyer: UnsafeRawPointer
}

struct StructDescriptor {
    let flags: UInt32
    let parent: UInt32
    var name: RelativePointer<Int8>
    let accessFunctionPtr: UInt32
    var fields: RelativePointer<FieldDescriptor>
    let numFields: UInt32
    let fieldOffsetVectorOffset: Int32
    //let genericContextHeader: void
}

struct StructMetadataMemoryLaout {
    let kind: UnsafeRawPointer
    var description: UnsafeMutablePointer<StructDescriptor>
}

struct EnumDescriptor {
    let flags: UInt32
    let parent: UInt32
    var name: UInt32
    let accessFunctionPtr: UInt32
    var fields: RelativePointer<FieldDescriptor>
    let numPayloadCasesAndPayloadSizeOffset: UInt32
    let numEmptyCases: UInt32
    let fieldOffsetVectorOffset: Int32
    //let genericContextHeader: void
}

struct EnumMetadataMemoryLaout {
    let kind: UnsafeRawPointer
    var description: UnsafeMutablePointer<EnumDescriptor>
}

//MARK: - 获取Layout中的一些信息
protocol HasProperties {
    var getFieldDescriptor: UnsafeMutablePointer<FieldDescriptor> { get }
    var fieldOffsetVectorOffset: Int32 { get }
    
    associatedtype FieldOffsetType: BinaryInteger
    mutating func getFieldOffsets() -> [Int]
}

extension HasProperties {
    mutating func getFieldOffsets() -> [Int] {
        let numFields = getFieldDescriptor.pointee.numFields
        let metaPtr = withUnsafeMutablePointer(to: &self, { UnsafeMutableRawPointer($0) })
        let offset = Int(self.fieldOffsetVectorOffset)
        let _vec = (metaPtr.assumingMemoryBound(to: Int.self) + offset)
        let vec = UnsafeMutableRawPointer(_vec).assumingMemoryBound(to: FieldOffsetType.self)
        var offsets: [Int] = []
        for i in 0..<numFields {
            offsets.append(Int(vec[Int(i)]))
        }
        return offsets
    }
}

extension ClassMetadataMemoryLaout: HasProperties {
    typealias FieldOffsetType = Int
    
    var fieldOffsetVectorOffset: Int32 {
        return self.description.pointee.fieldOffsetVectorOffset
    }
    
    var getFieldDescriptor: UnsafeMutablePointer<FieldDescriptor> {
        return self.description.pointee.fields.getRelativePointer()
    }
    
    var isSwiftClass: Bool {
        // include/swift/Runtime/Config.h SWIFT_CLASS_IS_SWIFT_MASK
        return (self.rodata & 0x1) == 0x1 || (self.rodata & 0x2) == 0x2
    }
    
    var superClass: AnyClass? {
        if self.superclass == NSObject.self { return nil }
        return self.superclass as? AnyClass
    }
}

extension StructMetadataMemoryLaout : HasProperties {
    typealias FieldOffsetType = Int32
    
    var fieldOffsetVectorOffset: Int32 {
        return self.description.pointee.fieldOffsetVectorOffset
    }
    
    var getFieldDescriptor: UnsafeMutablePointer<FieldDescriptor> {
        return self.description.pointee.fields.getRelativePointer()
    }
}

extension EnumMetadataMemoryLaout : HasProperties {
    typealias FieldOffsetType = Int32
    
    var fieldOffsetVectorOffset: Int32 {
        return self.description.pointee.fieldOffsetVectorOffset
    }
    
    var getFieldDescriptor: UnsafeMutablePointer<FieldDescriptor> {
        return self.description.pointee.fields.getRelativePointer()
    }
}

public enum Kind {
    // MARK: - cases
    
    case `class`
    /// e.g. Int、String
    case `struct`
    /// e.g. MemoryLayout<T>
    case `enum`
    /// e.g. Optional<T>、T?
    case optional
    /// Such as a Core Foundation class, e.g. CFArray
    case foreignClass
    /// A type whose value is not exposed in the metadata system
    case opaque
    case tuple
    /// A monomorphic function, e.g. () -> Void
    case function
    /// An existential type, e.g. protocol
    case existential
    /// A metatype
    case metatype
    /// An ObjC class wrapper, e.g. NSString
    case objCClassWrapper
    /// An existential metatype
    case existentialMetatype
    /// A heap-allocated local variable using statically-generated metadata
    case heapLocalVariable
    case heapArray
    /// A heap-allocated local variable using runtime-instantiated metadata.
    case heapGenericLocalVariable
    /// A native error object.
    case errorObject
    
    // MARK: - Some flags
    /// Non-type metadata kinds have this bit set
    private static let nonType: UInt = 0x400
    /// Non-heap metadata kinds have this bit set
    private static let nonHeap: UInt = 0x200
    /*
     The above two flags are negative because the "class" kind has to be zero, and class metadata is both type and heap metadata.
     */
    /// Runtime-private metadata has this bit set. The compiler must not statically generate metadata objects with these kinds, and external tools should not rely on the stability of these values or the precise binary layout of their associated data structures
    private static let runtimePrivate: UInt = 0x100
    private static let runtimePrivate_nonHeap = runtimePrivate | nonHeap
    private static let runtimePrivate_nonType = runtimePrivate | nonType
    
    // MARK: - initialization
    
    /// 获得Any.Type对应的MetadataKind
    init(_ type: Any.Type) {
        let kind = unsafeBitCast(type, to: UnsafePointer<UInt>.self).pointee
        switch kind {
        case 0 | Kind.nonHeap, 1: self = .struct
        case 1 | Kind.nonHeap, 2: self = .enum
        case 2 | Kind.nonHeap, 3: self = .optional
        case 3 | Kind.nonHeap: self = .foreignClass
            
        case 0 | Kind.runtimePrivate_nonHeap, 8: self = .opaque
        case 1 | Kind.runtimePrivate_nonHeap, 9: self = .tuple
        case 2 | Kind.runtimePrivate_nonHeap, 10: self = .function
        case 3 | Kind.runtimePrivate_nonHeap, 12: self = .existential
        case 4 | Kind.runtimePrivate_nonHeap, 13: self = .metatype
        case 5 | Kind.runtimePrivate_nonHeap, 14: self = .objCClassWrapper
        case 6 | Kind.runtimePrivate_nonHeap, 15: self = .existentialMetatype
            
        case 0 | Kind.nonType, 64: self = .heapLocalVariable
        case 0 | Kind.runtimePrivate_nonType: self = .heapGenericLocalVariable
        case 1 | Kind.runtimePrivate_nonType: self = .errorObject
            
        case 65: self = .heapArray
            
        case 0: fallthrough
        default: self = .class
        }
    }
}
