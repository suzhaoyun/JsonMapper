//
//  MTJ_01_Basic.swift
//  JsonMapper-DemoTests
//
//  Created by ZYSu on 2020/7/7.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import XCTest
@testable import JsonMapper_Demo

class MTJ_01_Basic: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testStruct() throws {
        struct Dog: JsonMapper {
            var name: String = ""
            var age: Int = 0
        }
        
        let json: [String:Any] = ["name":"旺财", "age":2]
        
        let dog = Dog.mapping(json)
        let dJson = dog.toJson() as? [String:Any]
        XCTAssert(dJson != nil)
        XCTAssert(dJson!["name"] as? String == "旺财")
        XCTAssert(dJson!["age"] as? Int == 2)
    }
    
    func testNSObjectClass() {
        class Dog: NSObject, JsonMapper {
            var name: String = ""
            var age: Int = 0
            required override init() { }
        }
        
        let json: [String:Any] = ["name":"旺财", "age":2, "weight": 20.2]
        
        let dJson = Dog.mapping(json).toJson() as? [String:Any]
        XCTAssert(dJson!["name"] as? String == "旺财")
        XCTAssert(dJson!["age"] as? Int == 2)
        
        class JinMao: Dog {
            var weight: Double = 0
        }
        
        let jJson = JinMao.mapping(json).toJson() as? [String:Any]
        XCTAssert(jJson!["name"] as? String == "旺财")
        XCTAssert(jJson!["age"] as? Int == 2)
        XCTAssert(jJson!["weight"] as? Double == 20.2)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
