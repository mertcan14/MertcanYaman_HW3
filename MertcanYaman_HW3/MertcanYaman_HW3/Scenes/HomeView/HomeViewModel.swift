//
//  HomeViewModel.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import Foundation
import DictionaryAPI

protocol HomeViewModelDelegate: AnyObject {
    func alertFunc(_ message: String)
    func goDetailPage(_ dictionary: Dictionary)
    func addWordHistory(_ word: String)
}

protocol HomeViewModelProtocol {
    var delegate: HomeViewModelDelegate? { get set }
    
    func getData(_ word: String)
}

final class HomeViewModel {
    var delegate: HomeViewModelDelegate?
    var dataDictionary: Dictionary?
    
    func fetchDataFromDictionary(_ word: String) {
        DictionaryService.shared.getDictionaryByWord(word) { [weak self] response in
            guard let self else { return }
            switch response {
            case.success(let dictionary):
                guard let firstDictionary = dictionary.first else { return }
                self.delegate?.addWordHistory(word)
                self.delegate?.goDetailPage(firstDictionary)
            case .failure(let error):
                self.delegate?.alertFunc(error.message ?? "Error")
            }
        }
    }
}

extension HomeViewModel: HomeViewModelProtocol {
    func getData(_ word: String) {
        fetchDataFromDictionary(word)
    }
}
