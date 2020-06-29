//
//  Wrappers.swift
//  JsonMapper
//
//  Created by ZYSu on 2020/6/25.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import Foundation

protocol _JsonMapperIgnore {}
protocol _JsonMapperConfig {
    // 获取是不是自定义了name
    static func replaceName(_ ptr: UnsafeMutableRawPointer) -> String
}

@propertyWrapper struct JsonMapperIgnore<T>: _JsonMapperIgnore{
    init(wrappedValue: T) {
        self.value = wrappedValue
    }
    var value: T
    var wrappedValue: T {
        set { value = newValue }
        get { value }
    }
}

@propertyWrapper struct JsonMapperConfig<T> {
    
    var name: String
    var mapper: ((Any) -> T)?
    
    init(wrappedValue: T, name: String = "", mapper: ((Any) -> T)? = nil) {
        self.name = name
        self.value = wrappedValue
        self.mapper = mapper
    }

    var value: T
    var wrappedValue: T {
        set { value = newValue }
        get { value }
    }
    
}

extension JsonMapperConfig: _JsonMapperConfig {
    static func replaceName(_ ptr: UnsafeMutableRawPointer) -> String{
        return ptr.assumingMemoryBound(to: Self.self).pointee.name
    }
}
