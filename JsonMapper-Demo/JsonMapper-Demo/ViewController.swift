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

        let color: Color = .red
        var i: T?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let json: [String : Any] = ["age":  "2010-01-10", "name" : "e22", "color" : "blue", "i" : 10.2323, "ss" : 2, "ooo" : ["name" : "ssss", "an" : ["name": "han", "a" : "xxx"]]]
        let p = Person<Double>.mapping(json)
        let x = p.ss
        print(p.name, p.ss, x)
        print(p.toJson())
        
        
    }

}

