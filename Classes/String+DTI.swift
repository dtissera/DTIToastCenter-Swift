//
//  String+DTI.swift
//  SampleDTIToastCenter
//
//  Created by dtissera on 25/10/2014.
//  Copyright (c) 2014 o--O--o. All rights reserved.
//

import UIKit

extension String {
    func doubleValue() -> Double {
        let str = NSString(string: self)
        return str.doubleValue
    }
}
