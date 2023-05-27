//
//  DictionaryService+Extension.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import Foundation
import DictionaryAPI

extension DictionaryService {
    func getDictionaryByWord(_ word: String, completion: @escaping ((Result<[Dictionary], NetworkError>) -> Void)) {
        self.fetchNews(DictionaryURL.word(word).url, completion: completion)
    }
    
    func getSynonymsByWord(_ word: String, completion: @escaping (Result<[Synonyms], NetworkError>) -> Void) {
        self.fetchNews(SynonymsURL.word(word).url, completion: completion)
    }
    
    func getSynonymsByWordAndMax(_ word: String, _ max: String, completion: @escaping (Result<[Synonyms], NetworkError>) -> Void) {
        self.fetchNews(SynonymsURL.wordAndMax(word, max).url, completion: completion)
    }
}
