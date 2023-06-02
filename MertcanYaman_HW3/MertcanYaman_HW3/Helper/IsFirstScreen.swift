//
//  IsFirstScreen.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 1.06.2023.
//

import Foundation

/// Checking if splash screen is the first page. If it is the first page, it is get dismiss func if it is not Home Page.
final class IsFirstScreen {
    static let shared = IsFirstScreen()
    
    var isFirst: Bool = true
    
    func setIsFirst() {
        isFirst = false
    }
}
