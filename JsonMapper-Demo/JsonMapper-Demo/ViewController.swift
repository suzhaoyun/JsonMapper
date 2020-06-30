//
//  ViewController.swift
//  JsonMapper-Demo
//
//  Created by ZYSu on 2020/6/28.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    struct Person: JsonMapper {
        @JsonField("age")
        @JsonTransfrom({ v in
            return Date()
        })
        var age: Date = Date()
        
        @JsonIgnore var name = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let json = ["age":  "2010-01-10", "name" : "e22"]
        let p = Person.mapping(json)
        print(p)
    }


}

