//
//  IsFirstScreen.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 1.06.2023.
//

import Foundation

class IsFirstScreen {
    static let shared = IsFirstScreen()
    
    var isFirst: Bool = true
    
    func setIsFirst() {
        isFirst = false
    }
}
