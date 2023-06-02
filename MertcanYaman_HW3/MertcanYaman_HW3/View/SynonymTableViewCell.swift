//
//  SynonymTableViewCell.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 31.05.2023.
//

import UIKit

final class SynonymTableViewCell: UITableViewCell {

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
                    let button = CustomButton()
                    button.setup(16, 6, 15)
                    button.setTitle(words[index].capitalized, for: .normal)
                    button.addTarget(self, action: #selector(self.addFilter), for: .touchUpInside)
                    self.upperView.addArrangedSubview(button)
                }
            }
        }else {
            DispatchQueue.main.async {
                for index in 0 ..< words.count - 1 {
                    let button = CustomButton()
                    button.setup(16, 6, 15)
                    button.setTitle(words[index].capitalized, for: .normal)
                    button.addTarget(self, action: #selector(self.addFilter), for: .touchUpInside)
                    self.upperView.addArrangedSubview(button)
                }
            }
            DispatchQueue.main.async {
                let button = CustomButton()
                button.setup(16, 6, 15)
                button.setTitle(words[words.count - 1].capitalized, for: .normal)
                button.addTarget(self, action: #selector(self.addFilter), for: .touchUpInside)
                self.bottomView.addArrangedSubview(button)
            }
        }
        
    }
    
    @objc func addFilter(_ button: UIButton!) {
        guard let word = button.titleLabel?.text else { return }
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil, userInfo: ["word": word])
    }
}
