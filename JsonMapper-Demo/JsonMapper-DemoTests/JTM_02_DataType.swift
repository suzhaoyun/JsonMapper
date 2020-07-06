//
//  JTM_02_DataType.swift
//  JsonMapper-Tests
//
//  Created by ZYSu on 2020/6/30.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import XCTest
@testable import JsonMapper_Demo

class JTM_02_DataType: XCTestCase {
    // MARK: - Int Type
    func testInt() {
        struct Student: JsonMapper {
            var age1: Int8 = 6
            var age2: Int16 = 0
            var age3: Int32 = 0
            var age4: Int64 = 0
            var age5: UInt8 = 0
            var age6: UInt16 = 0
            var age7: UInt32 = 0
            var age8: UInt64 = 0
            var age9: UInt = 0
            var age10: Int = 0
            var age11: Int = 0
        }
        
        let json: [String: Any] = [
            "age1": "suan8fa8",
            "age2": "6suan8fa8",
            "age3": "6",
            "age4": 6.66,
            "age5": NSNumber(value: 6.66),
            "age6": Int32(6),
            "age7": true,
            "age8": "FALSE", // true\false\yes\no\TRUE\FALSE\YES\NO
            "age9": Decimal(6.66),
            "age10": NSDecimalNumber(value: 6.66),
            "age11": timeIntevalInt
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.age1 == 6) 
        XCTAssert(student.age2 == 0)
        XCTAssert(student.age3 == 6)
        XCTAssert(student.age4 == 6)
        XCTAssert(student.age5 == 6)
        XCTAssert(student.age6 == 6)
        XCTAssert(student.age7 == 1)
        XCTAssert(student.age8 == 0)
        XCTAssert(student.age9 == 6)
        XCTAssert(student.age10 == 6)
        XCTAssert(student.age11 == timeIntevalInt)
    }
    
    // MARK: - Float Type
    func testFloat() {
        struct Student: JsonMapper {
            var height1: Float = 0.0
            var height2: Float = 0.0
            var height3: Float = 0.0
            var height4: Float = 0.0
            var height5: Float = 0.0
            var height6: Float = 0.0
            var height7: Float = 0.0
            var height8: Float = 0.0
            var height9: Float = 0.0
        }
        
        let json: [String: Any] = [
            "height1": "6.66suan8fa8",
            "height2": longFloatString,
            "height3": NSDecimalNumber(string: longFloatString),
            "height4": Decimal(string: longFloatString) as Any,
            "height5": 666,
            "height6": true,
            "height7": "NO", // true\false\yes\no\TRUE\FALSE\YES\NO
            "height8": CGFloat(longFloat),
            "height9": time
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.height1 == 0)
        XCTAssert(student.height2 == longFloat)
        XCTAssert(student.height3 == longFloat)
        XCTAssert(student.height4 == longFloat)
        XCTAssert(student.height5 == 666.0)
        XCTAssert(student.height6 == 1.0)
        XCTAssert(student.height7 == 0.0)
        XCTAssert(student.height8 == longFloat)
        XCTAssert(student.height9 == timeIntevalFloat)
    }
    
    // MARK: - Double Type
    func testDouble() {
        struct Student: JsonMapper {
            var height1: Double = 0.0
            var height2: Double = 0.0
            var height3: Double = 0.0
            var height4: Double = 0.0
            var height5: Double = 0.0
            var height6: Double = 0.0
            var height7: Double = 0.0
            var height8: Double = 0.0
            var height9: Double = 0.0
        }
        
        let json: [String: Any] = [
            "height1": "6.66suan8fa8",
            "height2": longDoubleString,
            "height3": NSDecimalNumber(string: longDoubleString),
            "height4": Decimal(string: longDoubleString) as Any,
            "height5": 666,
            "height6": true,
            "height7": "NO", // true\false\yes\no\TRUE\FALSE\YES\NO
            "height8": CGFloat(longDouble),
            "height9": time
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.height1 == 0)
        XCTAssert(student.height2 == longDouble)
        XCTAssert(student.height3 == longDouble)
        XCTAssert(student.height4 == longDouble)
        XCTAssert(student.height5 == 666.0)
        XCTAssert(student.height6 == 1.0)
        XCTAssert(student.height7 == 0.0)
        XCTAssert(student.height8 == longDouble)
        XCTAssert(student.height9 == timeInteval)
    }
    
    // MARK: - CGFloat Type
    func testCGFloat() {
        struct Student: JsonMapper {
            var height1: CGFloat = 0.0
            var height2: CGFloat = 0.0
            var height3: CGFloat = 0.0
            var height4: CGFloat = 0.0
            var height5: CGFloat = 0.0
            var height6: CGFloat = 0.0
            var height7: CGFloat = 0.0
            var height8: CGFloat = 0.0
            var height9: CGFloat = 0.0
        }
        
        let json: [String: Any] = [
            "height1": "6.66suan8fa8",
            "height2": longDoubleString,
            "height3": NSDecimalNumber(string: longDoubleString),
            "height4": Decimal(string: longDoubleString) as Any,
            "height5": 666,
            "height6": true,
            "height7": "NO", // true\false\yes\no\TRUE\FALSE\YES\NO
            "height8": longDouble,
            "height9": time
        ]
        let student = Student.mapping(json)
        XCTAssert(student.height1 == 0)
        XCTAssert(student.height2 == CGFloat(longDouble))
        XCTAssert(student.height3 == CGFloat(longDouble))
        XCTAssert(student.height4 == CGFloat(longDouble))
        XCTAssert(student.height5 == 666.0)
        XCTAssert(student.height6 == 1.0)
        XCTAssert(student.height7 == 0.0)
        XCTAssert(student.height8 == CGFloat(longDouble))
        XCTAssert(student.height9 == CGFloat(timeInteval))
    }
    
    // MARK: - Bool Type
    func testBool() {
        struct Student: JsonMapper {
            var rich1: Bool = false
            var rich2: Bool = false
            var rich3: Bool = false
            var rich4: Bool = false
            var rich5: Bool = false
            var rich6: Bool = false
            var rich7: Bool = false
        }
        
        // 0 -> false , other -> true
        let json: [String: Any] = [
            "rich1": 100,
            "rich2": 0.0,
            "rich3": "1",
            "rich4": NSNumber(value: 0.666),
            "rich5": "true",
            "rich6": "NO", // true\false\yes\no\TRUE\FALSE\YES\NO
            "rich7": CGFloat(6.666),
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.rich1 == true)
        XCTAssert(student.rich2 == false)
        XCTAssert(student.rich3 == true)
        XCTAssert(student.rich4 == true)
        XCTAssert(student.rich5 == true)
        XCTAssert(student.rich6 == false)
        XCTAssert(student.rich7 == true)
    }
    
    // MARK: - String Type
    func testString() {
        struct Student: JsonMapper {
            var name1: String = ""
            var name2: String = ""
            var name3: NSMutableString = ""
            var name4: NSString = ""
            var name5: NSMutableString = ""
            var name6: NSMutableString = ""
            var name7: String = ""
            var name8: String = ""
            var name9: String = ""
        }
        
        let json: [String: Any] = [
            "name1": 666,
            "name2": NSMutableString(string: "777"),
            "name3": [1,[2,3],"4"],
            "name4": longDecimalNumber,
            "name5": 6.66,
            "name6": false,
            "name7": NSURL(fileURLWithPath: "/users/mj/desktop"),
            "name8": URL(string: "http://www.520suanfa.com") as Any,
//            "name9": time
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.name1 == "666")
        XCTAssert(student.name2 == "777")
        XCTAssert(student.name3 == "[1,[2,3],\"4\"]")
        XCTAssert(student.name4 == longDecimalString as NSString)
        XCTAssert(student.name5 == "6.66")
        XCTAssert(student.name6 == "false")
        XCTAssert(student.name7.starts(with: "file:///users/mj/desktop"))
        XCTAssert(student.name8 == "http://www.520suanfa.com")
//        XCTAssert(student.name9 == timeIntevalString)
    }
    
    // MARK: - Decimal Type
    func testDecimal() {
        struct Student: JsonMapper {
            var money1: Decimal = 0
            var money2: Decimal = 0
            var money3: Decimal = 0
            var money4: Decimal = 0
            var money5: Decimal = 0
            var money6: Decimal = 0
            var money7: Decimal = 0
            var money8: Decimal = 0
        }
        
        let json: [String: Any] = [
            "money1": longDouble,
            "money2": true,
            "money3": longDecimalNumber,
            "money4": longDecimalString,
            "money5": 666,
            "money6": "NO", // true\false\yes\no\TRUE\FALSE\YES\NO
            "money7": CGFloat(longDouble),
            "money8": time
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.money1 == Decimal(string: longDoubleString))
        XCTAssert(student.money2 == 1)
        XCTAssert(student.money3 == Decimal(string: longDecimalString))
        XCTAssert(student.money4 == Decimal(string: longDecimalString))
        XCTAssert(student.money5 == 666)
        XCTAssert(student.money6 == 0)
        XCTAssert(student.money7 == Decimal(string: longDoubleString))
        XCTAssert(student.money8 == Decimal(string: timeIntevalString))
    }
    
    // MARK: - Decimal Number Type
    func testDecimalNumber() {
        struct Student: JsonMapper {
            var money1: NSDecimalNumber = 0
            var money2: NSDecimalNumber = 0
            var money3: NSDecimalNumber = 0
            var money4: NSDecimalNumber = 0
            var money5: NSDecimalNumber = 0
            var money6: NSDecimalNumber = 0
            var money7: NSDecimalNumber = 0
            var money8: NSDecimalNumber = 0
        }
        
        let json: [String: Any] = [
            "money1": longDouble,
            "money2": true,
            "money3": longDecimal,
            "money4": longDecimalString,
            "money5": 666.0,
            "money6": "NO", // true\false\yes\no\TRUE\FALSE\YES\NO
            "money7": CGFloat(longDouble),
            "money8": time
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.money1 == NSDecimalNumber(string: longDoubleString))
        XCTAssert(student.money2 == true)
        XCTAssert(student.money2 == 1)
        XCTAssert(student.money3 == longDecimalNumber)
        XCTAssert(student.money4 == longDecimalNumber)
        XCTAssert(student.money5 == 666)
        XCTAssert(student.money6 == false)
        XCTAssert(student.money6 == 0)
        XCTAssert(student.money7 == NSDecimalNumber(string: longDoubleString))
        XCTAssert(student.money8 == NSDecimalNumber(string: timeIntevalString))
    }
    
    // MARK: - Number Type
    func testNumber() {
        struct Student: JsonMapper {
            var money1: NSNumber = 0
            var money2: NSNumber = 0
            var money3: NSNumber = 0
            var money4: NSNumber = 0
            var money5: NSNumber = 0
            var money6: NSNumber = 0
            var money7: NSNumber = 0
            var money8: NSNumber = 0
        }
        
        let json: [String: Any] = [
            "money1": longDouble,
            "money2": true,
            "money3": Decimal(string: longDoubleString) as Any,
            "money4": longDoubleString,
            "money5": 666.0,
            "money6": "NO", // true\false\yes\no\TRUE\FALSE\YES\NO
            "money7": CGFloat(longDouble),
            "money8": time
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.money1 == NSNumber(value: longDouble))
        XCTAssert(student.money2 == true)
        XCTAssert(student.money2 == 1)
        XCTAssert(student.money2 == 1.0)
//        XCTAssert(student.money3 == NSNumber(value: longDouble))
        XCTAssert(student.money4 == NSNumber(value: longDouble))
        XCTAssert(student.money5 == 666)
        XCTAssert(student.money5 == 666.0)
        XCTAssert(student.money6 == false)
        XCTAssert(student.money6 == 0)
        XCTAssert(student.money6 == 0.0)
        XCTAssert(student.money7 == NSNumber(value: longDouble))
        XCTAssert(student.money8 == NSNumber(value: timeInteval))
    }
    
    // MARK: - Optional Type
    func testOptional() {
        struct Student: JsonMapper {
            var rich1: Bool = false
            var rich2: Bool? = false
            var rich3: Bool?? = false
            var rich4: Bool??? = false
            var rich5: Bool???? = false
            var rich6: Bool????? = false
        }
        
        let rich1: Int????? = 100
        let rich2: Double???? = 0.0
        let rich3: String??? = "0"
        let rich4: NSNumber?? = NSNumber(value: 0.666)
        let rich5: String? = "true"
        let rich6: String = "NO" // true\false\yes\no\TRUE\FALSE\YES\NO
        
        // 0 -> false , other -> true
        let json: [String: Any] = [
            "rich1": rich1 as Any,
            "rich2": rich2 as Any,
            "rich3": rich3 as Any,
            "rich4": rich4 as Any,
            "rich5": rich5 as Any,
            "rich6": rich6
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.rich1 == true)
        XCTAssert(student.rich2 == false)
        XCTAssert(student.rich3 == false)
        XCTAssert(student.rich4 == true)
        XCTAssert(student.rich5 == true)
        XCTAssert(student.rich6 == false)
    }
    
    // MARK: - URL Type
    func testURL() {
        struct Student: JsonMapper {
            var url1: NSURL?
            var url2: NSURL?
            var url3: URL?
            var url4: URL?
        }
        
        let url = "http://520suanfa.com/红黑树"
        let encodedUrl = "http://520suanfa.com/%E7%BA%A2%E9%BB%91%E6%A0%91"
        
        let json: [String: Any] = [
            "url1": url,
            "url2": URL(string: encodedUrl) as Any,
            "url3": url,
            "url4": NSURL(string: encodedUrl) as Any
        ]
        
        let student = Student.mapping(json)
//        XCTAssert(student.url1?.absoluteString == encodedUrl)
        XCTAssert(student.url2?.absoluteString == encodedUrl)
//        XCTAssert(student.url3?.absoluteString == encodedUrl)
        XCTAssert(student.url4?.absoluteString == encodedUrl)
    }
    
    // MARK: - Data Type
    func testData() {
        struct Student: JsonMapper {
            var data1: NSData?
            var data2: NSData?
            var data3: Data?
            var data4: Data?
            var data5: NSMutableData?
            var data6: NSMutableData?
        }
        
        let str = "RedBlackTree"
        let data = str.data(using: .utf8)!
        
        let json: [String: Any] = [
            "data1": str,
            "data2": data,
            "data3": str,
            "data4": NSMutableData(data: data),
            "data5": str,
            "data6": data
        ]
        
        let student = Student.mapping(json)
        XCTAssert(String(data: (student.data1)! as Data, encoding: .utf8) == str)
        XCTAssert(String(data: (student.data2)! as Data, encoding: .utf8) == str)
        XCTAssert(String(data: (student.data3)!, encoding: .utf8) == str)
        XCTAssert(String(data: (student.data4)!, encoding: .utf8) == str)
        XCTAssert(String(data: (student.data5)! as Data, encoding: .utf8) == str)
        XCTAssert(String(data: (student.data6)! as Data, encoding: .utf8) == str)
    }
    
    // MARK: - Date Type
    func testDate() {
        struct Student: JsonMapper {
            var date1: NSDate?
            var date2: NSDate?
            var date3: Date?
            var date4: Date?
            var date5: Date?
            var date6: Date?
            var date7: Date?
        }
        
        let json: [String: Any] = [
            "date1": timeInteval,
            "date2": Date(timeIntervalSince1970: timeInteval),
            "date3": timeInteval,
            "date4": NSDate(timeIntervalSince1970: timeInteval),
            "date5": timeIntevalString,
            "date6": NSDecimalNumber(string: timeIntevalString),
            "date7": Decimal(string: timeIntevalString) as Any
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.date1?.timeIntervalSince1970 == timeInteval)
        XCTAssert(student.date2?.timeIntervalSince1970 == timeInteval)
        XCTAssert(student.date3?.timeIntervalSince1970 == timeInteval)
        XCTAssert(student.date4?.timeIntervalSince1970 == timeInteval)
        XCTAssert(student.date5?.timeIntervalSince1970 == timeInteval)
        XCTAssert(student.date6?.timeIntervalSince1970 == timeInteval)
        XCTAssert(student.date7?.timeIntervalSince1970 == timeInteval)
    }
    
    // MARK: - Enum Type
    func testEnum1() {
        enum Grade: String, JsonProperty {
            case perfect = "A"
            case great = "B"
            case good = "C"
            case bad = "D"
        }
        
        struct Student: JsonMapper {
            var grade1: Grade = .perfect
            var grade2: Grade = .perfect
        }
        
        let json: [String: Any] = [
            "grade1": "C",
            "grade2": "D"
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.grade1 == .good)
        XCTAssert(student.grade2 == .bad)
    }
    
    func testEnum2() {
        enum Grade: Double, JsonProperty {
            case perfect = 8.88
            case great = 7.77
            case good = 6.66
            case bad = 5.55
        }
        
        struct Student: JsonMapper {
            var grade1: Grade = .perfect
            var grade2: Grade = .perfect
            var grade3: Grade = .perfect
            var grade4: Grade = .perfect
        }
        
        let json: [String: Any] = [
            "grade1": "5.55",
            "grade2": 6.66,
            "grade3": NSNumber(value: 7.77),
            "grade4": NSDecimalNumber(string: "8.88")
        ]
        
        let student = Student.mapping(json)
        XCTAssert(student.grade1 == .bad)
        XCTAssert(student.grade2 == .good)
        XCTAssert(student.grade3 == .great)
        XCTAssert(student.grade4 == .perfect)
    }
    
    func testEnumArray() {
        enum Grade: String, JsonProperty {
            case perfect = "A"
            case great = "B"
            case good = "C"
            case bad = "D"
        }

        struct Student: JsonMapper {
            var name: String?
            var grades: [Grade]?
        }

        let json: [String: Any] = [
            "name": "Jack",
            "grades": ["D", "B"]
        ]

        let stu = Student.mapping(json)
        XCTAssert(stu.name == "Jack")
        XCTAssert(stu.grades?[0] == .bad)
        XCTAssert(stu.grades?[1] == .great)
    }
    
    func testEnumArrayInDict() {
        enum Grade: String, JsonProperty {
            case perfect = "A"
            case great = "B"
            case good = "C"
            case bad = "D"
        }

        struct Student: JsonMapper {
            var name: String?
            var grades: [String: [Grade?]]?
        }

        let json: [String: Any] = [
            "name": "Jack",
            "grades": ["2019": ["A", "B"], "2020": ["C", "D"]]
        ]

        let stu = Student.mapping(json)
        XCTAssert(stu.name == "Jack")
        XCTAssert(stu.grades?["2019"]?[0] == .perfect)
        XCTAssert(stu.grades?["2019"]?[1] == .great)
        XCTAssert(stu.grades?["2020"]?[0] == .good)
        XCTAssert(stu.grades?["2020"]?[1] == .bad)
    }
    
    func testEnumDict() {
        enum Grade: String, JsonProperty{
            case perfect = "A"
            case great = "B"
            case good = "C"
            case bad = "D"
        }

        struct Student: JsonMapper {
            var name: String?
            var grades: [String: Grade]?
        }

        let json: [String: Any] = [
            "name": "Jack",
            "grades": ["2019": "D", "2020": "B"]
        ]

        let stu = Student.mapping(json)
        XCTAssert(stu.name == "Jack")
        XCTAssert(stu.grades?["2019"] == .bad)
        XCTAssert(stu.grades?["2020"] == .great)
    }
    
    // MARK: - Array Type
    func testArray() {
        struct Person: JsonMapper {
            var array1: [CGFloat]?
            var array2: NSArray?
            var array3: NSMutableArray?
        }
        
        let array: [CGFloat] = [5.55, 6.66, 7.77]
        
        let json: [String: Any] = [
            "array1": NSMutableArray(array: array),
            "array2": array,
            "array3": array,
        ]
        
        let person = Person.mapping(json)
        XCTAssert(person.array1 == array)
        XCTAssert(person.array2 == array as NSArray)
        XCTAssert(person.array3 == NSMutableArray(array: array))
    }
    
    
    // MARK: - Dictionary Type
    func testDictionary() {
        struct Person: JsonMapper {
            var dict1: [String: Any]?
            var dict2: NSDictionary?
            var dict3: NSMutableDictionary?
        }
        
        let dict = ["no1": 100, "no2": 200]
        
        let json: [String: Any] = [
            "dict1": NSMutableDictionary(dictionary: dict),
            "dict2": dict,
            "dict3": dict
        ]
        
        let person = Person.mapping(json)
        for (k, v) in dict {
            XCTAssert(person.dict1?[k] as? Int == v)
            XCTAssert(person.dict2?[k] as? Int == v)
            XCTAssert(person.dict3?[k] as? Int == v)
        }
    }

}
