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
    
    func testStruct() throws {
        struct Dog: JsonMapper {
            var name: String = ""
            var age: Int = 0
        }
        
        let json: [String:Any] = ["name":"旺财", "age":2]
        
        let dog = Dog.mapping(json)
        XCTAssert(dog.name == "旺财")
        XCTAssert(dog.age == 2)
    }
    
    func testClass() throws {
        class Dog: JsonMapper {
            var name: String = ""
            var age: Int = 0
            required init() { }
        }
        
        let json: [String:Any] = ["name":"旺财", "age":2, "weight": 20.2]
        
        let dog = Dog.mapping(json)
        XCTAssert(dog.name == "旺财")
        XCTAssert(dog.age == 2)
        
        class JinMao: Dog {
            var weight: Double = 0
        }
        
        let jd = JinMao.mapping(json)
        XCTAssert(jd.name == "旺财")
        XCTAssert(jd.age == 2)
        XCTAssert(jd.weight == 20.2)
    }
    
    func testNSObjectClass() {
        class Dog: NSObject, JsonMapper {
            var name: String = ""
            var age: Int = 0
            required override init() { }
        }
        
        let json: [String:Any] = ["name":"旺财", "age":2, "weight": 20.2]
        
        let dog = Dog.mapping(json)
        XCTAssert(dog.name == "旺财")
        XCTAssert(dog.age == 2)
        
        class JinMao: Dog {
            var weight: Double = 0
        }
        
        let jd = JinMao.mapping(json)
        XCTAssert(jd.name == "旺财")
        XCTAssert(jd.age == 2)
        XCTAssert(jd.weight == 20.2)
    }
    
    func testArray() throws {
        struct Dog: JsonMapper {
            var name: String = ""
            var age: Int = 0
        }
        
        let json: [[String:Any]] = [["name":"旺财", "age":2]]
        
        let dog = Dog.mapping(json)
        XCTAssert(dog.first?.name == "旺财")
        XCTAssert(dog.first?.age == 2)
    }
    
    func testOptional() throws {
        struct Dog: JsonMapper {
            var age1: Int? //Optional<Int>
            var age2: Int?? //Optional<Optional<Int>>
            var age3: Int??? //...
        }
        
        let json: [String:Any] = ["age1":1, "age2":2, "age3":3]
        let dog = Dog.mapping(json)
        XCTAssert(dog.age1 == 1)
        XCTAssert(dog.age2 == 2)
        XCTAssert(dog.age3 == 3)
    }
    
    func testEnum01() throws  {
        enum State: Int, JsonProperty {
            case s1 = 1
            case s2 = 4
        }
        
        struct Dog: JsonMapper {
            var name: String = ""
            var age: Int = 0
            var s: State = .s1
        }
        
        let json1: [String:Any] = ["s":4]
        let dog1 = Dog.mapping(json1)
        XCTAssert(dog1.s == State.s2)
        
        let json2: [String:Any] = ["s":5]
        let dog2 = Dog.mapping(json2)
        XCTAssert(dog2.s == State.s1)
    }
    
    func testGeneric() throws {
        struct Dog<T>: JsonMapper {
            var age1: T?
            var age2: [T] = []
        }
        
        let json: [String:Any] = ["age1":2.2, "age2": [3.2, 22.23]]
        let dog = Dog<Double>.mapping(json)
        XCTAssert(dog.age1 == 2.2)
        XCTAssert(dog.age2 == [3.2, 22.23])
        
        let dog1 = Dog<Int>.mapping(json)
        XCTAssert(dog1.age1 == 2)
        XCTAssert(dog1.age2 == [3, 22])
    }
    
    func testModelProperty() throws {
        class Dog: JsonMapper {
            var name: String = ""
            var age: Int = 0
            required init() { }
        }
        
        class Person: JsonMapper {
            var name: String = ""
            var dog: Dog?
            required init() {}
        }
        
        let json: [String:Any] = ["name":"张三", "dog":["name":"wangcai","age":1]]
        let p = Person.mapping(json)
        XCTAssert(p.dog?.name == "wangcai")
        XCTAssert(p.dog?.age == 1)
    }
    
    func testModelPropertyArray() throws {
        class Dog: JsonMapper {
            var name: String = ""
            var age: Int = 0
            required init() { }
        }
        
        class Person: JsonMapper {
            var name: String = ""
            var dogs: [Dog] = []
            required init() {}
        }
        
        let json: [String:Any] = ["name":"张三", "dogs":[["name":"wangcai","age":1], ["name":"二哈","age":2]]]
        
        let p = Person.mapping(json)
        XCTAssert(p.dogs[0].name == "wangcai")
        XCTAssert(p.dogs[0].age == 1)
        
        XCTAssert(p.dogs[1].name == "二哈")
        XCTAssert(p.dogs[1].age == 2)
    }
    
    
    func testMemoryLeak() throws {
        class Dog: JsonMapper {
            var name: String = "wangcai"
            var age: Int = 0
            required init() {
                print("Dog init")
            }
            deinit {
                print("Dog deinit")
            }
        }
        
        class Person: JsonMapper {
            var name: String = ""
            var dog = Dog()
            required init() {}
        }
        
        let p = Person()
        print(p.dog.name)
        
        //void *ptr = &p.dog;
        let ptr = withUnsafeMutablePointer(to: &p.dog, {UnsafeMutableRawPointer($0)})

        //Dog *dogPtr = (Dog *)ptr;
        let dogPtr = ptr.assumingMemoryBound(to: Dog.self)
        let d = Dog()
        d.name = "erha"
        
        // swift_relese(*dogPtr)
        // *dogPtr = d;
        // swift_retain(d)
        dogPtr.pointee = d
        print(p.dog.name)
        
        XCTAssert(p.name == "")
    }
}
