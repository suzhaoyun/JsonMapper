//
//  ViewController.swift
//  JsonMapper-Demo
//
//  Created by ZYSu on 2020/6/28.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum Color: String, JsonMapperProperty{
        case red = "red"
        case yellow = "yellow"
        case blue = "blue"
    }
    
    struct Person<T>: JsonMapper{
//        required init() {
//
//        }
        let ss: Int8 = 1
//        @JsonField("age")
//        @JsonTransform({ v in
//            return Date()
//        })
        @JsonDate("yyyy-MM-dd") var age: Date = Date()
        
        @JsonField("ooo.an.name") var name = ""
        @JsonField("ooo.an.a") var aa = ""
        @JsonDate var bir: NSDate? = nil
        var color: Color = .red
        var i: T?
        var xxd: [String:Any]?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let json: [String : Any] = ["age":  "2010-01-10", "name" : "e22", "color" : "blue", "i" : 10.2323, "ss" : 2, "ooo" : ["name" : "ssss", "an" : ["name": "han", "a" : "xxx"]], "bir" : "2010-01-11", "xxd": ["fdsf":1, "323232": 334.2, "342":"age"]]
        let p = Person<Double>.mapping(json)
        let x = p.ss
        print(p.name, p.ss, x, p.bir, p.xxd)
        print(p.toJson())
        
        
    }

}

