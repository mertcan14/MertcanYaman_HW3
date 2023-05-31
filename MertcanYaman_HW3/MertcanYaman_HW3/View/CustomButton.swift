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
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.contentEdgeInsets = UIEdgeInsets(top: 6,left: 12,bottom: 6,right: 12)
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1
        self.cornerRadius = 16
        self.backgroundColor = .white
        self.setTitleColor(.black, for: .normal)
    }
    
}
