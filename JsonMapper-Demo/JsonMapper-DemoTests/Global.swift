//
//  Global.swift
//  JsonMapper
//
//  Created by ZYSu on 2020/07/05.
//  Copyright © 2020 ZYSu. All rights reserved.
//

import XCTest
@testable import JsonMapper_Demo

let timeIntevalInt: Int = 1565922866
let timeIntevalFloat = Float(timeIntevalInt)
let timeInteval = Double(timeIntevalInt)
let timeIntevalString = "\(timeIntevalInt)"
let time = Date(timeIntervalSince1970: timeInteval)
// 16 decimals
let longDoubleString = "0.1234567890123456"
let longDouble: Double = 0.1234567890123456
// 8 decimals
let longFloatString = "0.12345678"
let longFloat: Float = 0.12345678
// 39 decimals
let longDecimalString = "0.123456789012345678901234567890123456789"
var longDecimal = Decimal(string: longDecimalString)!
var longDecimalNumber = NSDecimalNumber(string: longDecimalString)
