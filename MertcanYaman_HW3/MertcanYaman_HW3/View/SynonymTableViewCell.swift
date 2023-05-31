//
//  SynonymTableViewCell.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 31.05.2023.
//

import UIKit

class SynonymTableViewCell: UITableViewCell {


    @IBOutlet weak var bottomView: UIStackView!
    @IBOutlet weak var upperView: UIStackView!
    
    func setup(_ words: [String]) {
        bottomView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        upperView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        if words.count < 5 {
            bottomView.isHidden = true
            DispatchQueue.main.async {
                for index in 0 ..< words.count {
                    let button = UIButton()
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                    button.contentEdgeInsets = UIEdgeInsets(top: 6,left: 12,bottom: 6,right: 12)
                    button.layer.borderColor = UIColor.darkGray.cgColor
                    button.layer.borderWidth = 1
                    button.cornerRadius = 16
                    button.backgroundColor = .white
                    button.setTitleColor(.black, for: .normal)
                    button.setTitle(words[index].capitalized, for: .normal)
                    button.addTarget(self, action: #selector(self.addFilter), for: .touchUpInside)
                    self.upperView.addArrangedSubview(button)
                }
            }
        }else {
            DispatchQueue.main.async {
                for index in 0 ..< words.count - 1 {
                    let button = UIButton()
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                    button.contentEdgeInsets = UIEdgeInsets(top: 6,left: 12,bottom: 6,right: 12)
                    button.layer.borderColor = UIColor.darkGray.cgColor
                    button.layer.borderWidth = 1
                    button.cornerRadius = 16
                    button.backgroundColor = .white
                    button.setTitleColor(.black, for: .normal)
                    button.setTitle(words[index].capitalized, for: .normal)
                    button.addTarget(self, action: #selector(self.addFilter), for: .touchUpInside)
                    self.upperView.addArrangedSubview(button)
                }
            }
            DispatchQueue.main.async {
                let button = UIButton()
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                button.contentEdgeInsets = UIEdgeInsets(top: 6,left: 12,bottom: 6,right: 12)
                button.layer.borderColor = UIColor.darkGray.cgColor
                button.layer.borderWidth = 1
                button.cornerRadius = 16
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
                button.setTitle(words[words.count - 1].capitalized, for: .normal)
                button.addTarget(self, action: #selector(self.addFilter), for: .touchUpInside)
                self.bottomView.addArrangedSubview(button)
            }
        }
        
    }
    
    @objc func addFilter(_ button: UIButton!) {
        print(button.titleLabel?.text)
    }
}
