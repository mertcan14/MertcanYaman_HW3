//
//  DetailViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import UIKit

class DetailViewController: UIViewController {
    
    var detailViewModel: DetailViewModelProtocol! {
        didSet {
            detailViewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailViewModel.getDataFromDictionary()
    }
}

extension DetailViewController: DetailViewModelDelegate {
    
}
