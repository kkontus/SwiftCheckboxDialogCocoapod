//
//  String.swift
//  Pods
//
//  Created by Kristijan Kontus on 16/12/2016.
//
//

import Foundation

extension String {
    
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
}
