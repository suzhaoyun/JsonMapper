//
//  Logger.swift
//  JsonMapper
//
//  Created by ZYSu on 2020/6/28.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation

/// 将type转换成指针
@inline(__always) func TypeRawPointer(_ type: Any.Type) -> UnsafeMutableRawPointer {
    unsafeBitCast(type, to: UnsafeMutableRawPointer.self)
}

/// 获取obj的指针  如果是对象获取到堆空间的地址
func ObjRawPointer<T>(_ obj: inout T) -> UnsafeMutableRawPointer {
    if Swift.type(of: obj) is AnyClass {
        return unsafeBitCast(obj, to: UnsafeMutableRawPointer.self)
    }else {
        return withUnsafeMutablePointer(to: &obj, { UnsafeMutableRawPointer($0) })
    }
}

struct JsonMapperLogger {
    static func logWarning(_ msg: String?) {
        #if DEBUG
        if let m = msg { print("⚠️ [JsonMapper]: ", m) }
        #endif
    }
}

