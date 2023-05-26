//
//  ViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 26.05.2023.
//

import UIKit
import DictionaryAPI

class ViewController: UIViewController {

    let service: NewsServiceProtocol = NewsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        service.fetchNews(DictionaryURL.word("Model").url) { [weak self] (response:Result<[WelcomeElement], Error>) in
            guard let self else { return }
            switch response {
            case .success(let movies):
                print("KERIM: \(movies)")
            case .failure(let error):
                print("KERIM: \(error)")
            }
        }
    }
}

