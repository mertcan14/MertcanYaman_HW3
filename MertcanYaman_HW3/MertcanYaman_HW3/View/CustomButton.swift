//
//  CustomButton.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 31.05.2023.
//

import UIKit

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(_ horizontal: Double, _ vertical: Double, _ fontSize: Double) {
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.titleLabel?.minimumScaleFactor = 0.5
        self.contentEdgeInsets = UIEdgeInsets(top: vertical,left: horizontal,bottom: vertical,right: horizontal)
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
        self.cornerRadius = 16
        self.backgroundColor = .white
        self.setTitleColor(.black, for: .normal)
    }
    
}
