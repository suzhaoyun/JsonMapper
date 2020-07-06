//
//  JTM_03_Custom.swift
//  JsonMapper-DemoTests
//
//  Created by ZYSu on 2020/7/5.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import XCTest
@testable import JsonMapper_Demo

class JTM_03_Wrapper: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testJsonIgnore() throws {
        struct Dog: JsonMapper {
            @JsonIgnore var name: String = "二哈"
            var age: Int = 0
        }
        
        let json: [String:Any] = ["name":"旺财", "age":2]
        
        let dog = Dog.mapping(json)
        XCTAssert(dog.name == "二哈")
        XCTAssert(dog.age == 2)
//        print(dog.toJson())
    }
    
    func testJsonDate() throws {
        struct Dog: JsonMapper {
            var name: String = "二哈"
            @JsonDate("yyyy-MM-dd") var age1 = Date()
            @JsonDate("yyyy-MM-dd") var age2 = NSDate()
            @JsonDate("yyyy-MM-dd") var age3: Date? = nil
            @JsonDate("yyyy-MM-dd") var age4: NSDate? = nil
        }
        
        let json: [String:Any] = ["name":"旺财", "age1":"2010-02-02", "age2":"2020-03-03", "age3":"2013-02-02", "age4":"2013-02-02"]
        
        let dog = Dog.mapping(json)
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let age1 = fmt.date(from: "2010-02-02")
        let age2 = fmt.date(from: "2020-03-03")
        let age3 = fmt.date(from: "2013-02-02")
        let age4 = fmt.date(from: "2013-02-02")

        XCTAssert(dog.age1 == age1)
        XCTAssert(dog.age2.timeIntervalSince1970 == age2?.timeIntervalSince1970)
        XCTAssert(dog.age3 == age3)
        XCTAssert(dog.age4?.timeIntervalSince1970 == age4?.timeIntervalSince1970)
    }
    
    
    func testJsonField() throws {
        struct Dog: JsonMapper {
            var name: String = "二哈"
            
            @JsonField("dog_age")
            var age: Int? = nil
            
            @JsonField("info.height_info.value")
            var height: CGFloat = 0
        }
        
        let json: [String:Any] = ["name":"旺财", "dog_age":"2", "info":["height_info":["value":2.2]]]
        
        let dog = Dog.mapping(json)
        XCTAssert(dog.name == "旺财")
        XCTAssert(dog.age == 2)
        XCTAssert(dog.height == 2.2)
    }
    
    func testJsonFieldKeyPath() throws {
        struct Dog: JsonMapper {
            var name: String = "二哈"
            
            @JsonField("info.age_info.age")
            var age: Int? = nil
            
            @JsonField("info.height_info.value")
            var height: CGFloat = 0
        }
        
        let json: [String:Any] = ["name":"旺财", "info":["height_info": ["value":2.2], "age_info" : ["age":2]]]
        
        let dog = Dog.mapping(json)
        XCTAssert(dog.name == "旺财")
        XCTAssert(dog.age == 2)
        XCTAssert(dog.height == 2.2)
    }
    
    func testJsonTransform() throws {
        struct Dog: JsonMapper {
            @JsonTransform({ jsonVal in
                return "transform_" + ((jsonVal as? String) ?? "")
            })
            var name: String = "二哈"
        }
        
        let json: [String:Any] = ["name":"旺财"]
        
        let dog = Dog.mapping(json)
        XCTAssert(dog.name == "transform_旺财")
    }
    
    func testWrapperCombin() throws {
        struct Dog: JsonMapper {
            
            @JsonField("dog_age") @JsonDate("yyyy-MM-dd")
            var age: Date? = nil
            
            @JsonField("dog_name") @JsonTransform({ jsonVal in
                return "1111"
            })
            var name: String = ""
            
            @JsonField("info.height_info") @JsonTransform({ jsonVal in
                return 3.3
            })
            var height: CGFloat = 0
        }
        
        let json: [String:Any] = ["dog_age":"2010-02-02", "dog_name": "22222", "info":["height_info":["value":2.2]]]
        
        let dog = Dog.mapping(json)
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let age = fmt.date(from: "2010-02-02")
        XCTAssert(dog.age == age)
        XCTAssert(dog.name == "1111")
        XCTAssert(dog.height == 3.3)
    }
    
}
