//
//  ViewController.swift
//  JsonMapper-Demo
//
//  Created by ZYSu on 2020/6/28.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    struct Dog {
        var name: String = ""
        var age: Int = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let x:Any.Type = Dog.self
//        let xx = Unmanaged.passUnretained(x)
        
        let p = unsafeBitCast(x, to: UnsafePointer<ClassMetadataMemoryLaout>.self)
        print(p.pointee.kind)
    }

}

 
