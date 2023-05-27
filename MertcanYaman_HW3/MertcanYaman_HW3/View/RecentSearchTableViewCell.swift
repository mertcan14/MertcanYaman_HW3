//
//  RecentSearchTableViewCell.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import UIKit

class RecentSearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    func setup(_ word: String) {
        wordLabel.text = word
    }
}
