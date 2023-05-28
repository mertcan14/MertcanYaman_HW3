//
//  DetailViewModel.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import Foundation
import DictionaryAPI

protocol DetailViewModelDelegate: AnyObject {
    
}

protocol DetailViewModelProtocol {
    var delegate: DetailViewModelDelegate? { get set }
    
    func getDataFromDictionary()
}

final class DetailViewModel {
    var delegate: DetailViewModelDelegate?
    var dataDictionary: Dictionary?
    var dataSynonyms: [Synonyms]?
    var word: String
    
    init(word: String) {
        self.word = word
    }
    
    func fetchDataFromDictionary() {
        DictionaryService.shared.getDictionaryByWord(self.word) { [weak self] response in
            guard let self else { return }
            switch response {
            case.success(let dictionary):
                guard let firstDictionary = dictionary.first else { return }
                self.dataDictionary = firstDictionary
            case .failure(let error):
                print("dictionary: \(error.message)")
            }
        }
    }
    
    func fetchDataFromSynonyms() {
        DictionaryService.shared.getSynonymsByWord(self.word) { [weak self] response in
            guard let self else { return }
            switch response {
            case.success(let synonyms):
                self.dataSynonyms = synonyms
                print(self.dataSynonyms)
            case .failure(let error):
                print("synonyms: \(error.message)")
            }
        }
    }
}

extension DetailViewModel: DetailViewModelProtocol {
    func getDataFromDictionary() {
        self.fetchDataFromDictionary()
        self.fetchDataFromSynonyms()
    }
}
