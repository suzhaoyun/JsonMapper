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
        @JsonField("age")
        @JsonTransform({ v in
            return Date()
        })
        var age: Date = Date()
        
        @JsonIgnore var name = ""
        var color: Color = .red
        var i: T?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        let json = ["age":  "2010-01-10", "name" : "e22", "color" : "blue", "i" : 10.2323] as [String : Any]
        let p = Person<Double>.mapping(json)
        print(p)
    }


}

