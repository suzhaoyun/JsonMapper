//
//  ViewController.swift
//  JsonMapper-Demo
//
//  Created by ZYSu on 2020/6/28.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import UIKit
import JMMetadata

class PP{
    let v: String = ""
    let a = 0
}

protocol PPP {
    var size: Int { get }
}

extension PPP {
    var size: Int {  MemoryLayout.size(ofValue: self) }
}

extension Int8: PPP {}
extension Int: PPP {}
extension Double: PPP {}
extension Date:PPP {}
extension String: PPP {}

extension Optional: PPP {}
class ViewController: UIViewController {
    
    
//    struct PP: Mapable {
//        var mapAbleId: Int8
//    }
    
    enum Color: String, JsonMapperProperty{
        case red = "red"
        case yellow = "yellow"
        case blue = "blue"
    }
    
    struct Person<T>: JsonMapper{
       
        var ss: Int8 = 0
//        @JsonField("age")
//        @JsonTransform({ v in
//            return Date()
//        })
        var age: Date = Date()
        
        @JsonIgnore var name = ""
        var color: Color = .red
        var i: T?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let countPtr = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        
//        let metadata = unsafeBitCast(Person<Double>.self, to: UnsafeMutableRawPointer.self)
        jm_copyIvarList(TypeRawPointer(Person<Double>.self), countPtr)
        return
        let pt1 = Person<Int>.self
        let pt2 = Person<Int8>.init()
        let m = Mirror(reflecting: pt2)
        m.children.forEach({
            print("\($0.label)", ($0.value as? PPP)?.size)
        })
        
        
        return
//        print(TypeRawPointer(pt1) == TypeRawPointer(pt2))
        
        // Do any additional setup after loading the view.
        let json = ["age":  "2010-01-10", "name" : "e22", "color" : "blue", "i" : 10.2323] as [String : Any]
        let p = Person<Double>.mapping(json)
        print(p)
    }

}

