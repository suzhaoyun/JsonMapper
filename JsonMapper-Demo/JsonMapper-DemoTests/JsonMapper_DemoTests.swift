//
//  JsonMapper_DemoTests.swift
//  JsonMapper-DemoTests
//
//  Created by ZYSu on 2020/6/28.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import XCTest
@testable import JsonMapper_Demo

class JsonMapper_DemoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        struct Dog: JsonMapper {
            
            @JsonTransform({ jsonVal in
                return "二哈"
            })
            var name: String = ""
            var age: Int = 0
        }
        
        let json: [String:Any] = ["name" : "旺财",
                                  "age"  : 2]
        
        // mapping struct
        let dog = Dog.mapping(json)
        dog.toJsonString()
        // mapping class
//        let cat = Cat.mapping(json)
        
        print(dog.name, dog.age)
//        print(cat.name, cat.age)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
