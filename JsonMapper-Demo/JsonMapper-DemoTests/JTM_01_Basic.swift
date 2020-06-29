//
//  Test-basic.swift
//  JsonMapper-DemoTests
//
//  Created by ZYSu on 2020/6/28.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import XCTest
@testable import JsonMapper_Demo

class JTM_01_Basic: XCTestCase {
    struct Cat: JsonMapper {
        var weight: Double = 0.0
        var name: String = ""
    }
    
    // MARK: - Generic Type
    func testGeneric() {
        let name = "Miaomiao"
        let weight = 6.66
        
        // json can also be NSDictionary\NSMutableDictionary
        let json: [String: Any] = [
            "weight": weight,
            "name": name
        ]
        
        let cat = Cat.mapping(json)
        XCTAssert(cat.name == name)
        XCTAssert(cat.weight == weight)
    }
    
    // MARK: - NSNull
    func testNSNull() {
        struct Cat: JsonMapper {
            var weight: Double = 0.0
            var name: String = "xx"
            var data: NSNull?
        }
        
        let json: [String: Any] = [
            "name": NSNull(),
            "weight": 6.6,
            "data": NSNull()
        ]
        
        let cat = Cat.mapping(json)
        // convert failed, keep default value
        XCTAssert(cat.name == "xx")
        XCTAssert(cat.weight == 6.6)
//        XCTAssert(cat.data == NSNull())
    }
    
    // MARK: - let
    func testLet() {
        struct Cat: JsonMapper {
            // let of integer type is very restricted in release mode
            // please user `private(set) var` instead of `let`
            private(set) var weight: Double = 0.0
            let name: String = ""
        }
        let name: String = "Miaomiao"
        let weight: Double = 6.66
        
        let json: [String: Any] = [
            "weight": weight,
            "name": name
        ]
        
        let cat = Cat.mapping(json)
        XCTAssert(cat.name == name)
        XCTAssert(cat.weight == weight)
    }
    
    // MARK: - Class Type
    func testClass() {
        class Person: JsonMapper {
            var name: String = ""
            var age: Int = 0
            required init() {}
        }
        
        class Student: Person {
            var score: Int = 0
            var no: String = ""
        }
        
        let name = "jack"
        let age = 18
        let score = 98
        let no = "9527"
        
        let json: [String: Any] = [
            "name": name,
            "age": age,
            "score": score,
            "no": no
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.name == name)
        XCTAssert(student.age == age)
        XCTAssert(student.score == score)
        XCTAssert(student.no == no)
    }
    
    // MARK: - NSObject Class Type
    func testNSObjectClass() {
        class Person: NSObject, JsonMapper {
            var name: String = ""
            var age: Int = 0
            required override init() {}
        }
        
        class Student: Person {
            var score: Int = 0
            var no: String = ""
        }
        
        let name = "jack"
        let age = 18
        let score = 98
        let no = "9527"
        
        let json: [String: Any] = [
            "name": name,
            "age": age,
            "score": score,
            "no": no
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.name == name)
        XCTAssert(student.age == age)
        XCTAssert(student.score == score)
        XCTAssert(student.no == no)
    }
    
    // MARK: - Convert
    func testConvert() {
        let name = "Miaomiao"
        let weight = 6.66
        
        let json: [String: Any] = [
            "weight": weight,
            "name": name
        ]
        
        let cat = Cat.mapping(json)
        XCTAssert(cat.name == name)
        XCTAssert(cat.weight == weight)
    }
    
//
//    static var allTests = [
//        "testGeneric": testGeneric,
//        "testAny": testAny,
//        "testJSONString": testJSONString,
//        "testJSONData": testJSONData,
//        "testNSNull": testNSNull,
//        "testLet": testLet,
//        "testClass": testClass,
//        "testNSObjectClass": testNSObjectClass,
//        "testConvert": testConvert,
//        "testCallback1": testCallback1,
//        "testCallback2": testCallback2,
//        "testOCModel": testOCModel
//    ]
}
