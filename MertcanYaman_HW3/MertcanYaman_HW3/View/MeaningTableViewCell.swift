//
//  MeaningTableViewCell.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 29.05.2023.
//

import UIKit

final class MeaningTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var exampleTitleLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var speechLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    
    func setup(_ definition: DefinitionForCell) {
        indexLabel.text = "\(definition.index) - "
        speechLabel.text = definition.speech.capitalized
        definitionLabel.text = definition.definition.definition
        if let example = definition.definition.example {
            exampleLabel.isHidden = false
            exampleTitleLabel.isHidden = false
            exampleLabel.text = example
        }else {
            exampleLabel.isHidden = true
            exampleTitleLabel.isHidden = true
        }
    }
}
