//
//  DictionaryService+Extension.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import Foundation
import DictionaryAPI

extension DictionaryService {
    /// Fetch data from dictionary API by word, provides internet control
    func getDictionaryByWord(_ word: String, completion: @escaping ((Result<[Dictionary], NetworkError>) -> Void)) {
        if ReachabilityService.isConnectedToInternet() {
            guard let url = DictionaryURL.word(word).url else {
                completion(.failure(NetworkError.invalidChar))
                return
            }
            self.fetchNews(url, completion: completion)
        }else {
            completion(.failure(.connectionError))
        }
    }
    
    /// Fetch data from synonyms API by word and max, provides internet control
    func getSynonymsByWordAndMax(_ word: String, _ max: String, completion: @escaping (Result<[Synonyms], NetworkError>) -> Void) {
        if ReachabilityService.isConnectedToInternet() {
            guard let url = SynonymsURL.wordAndMax(word, max).url else {
                completion(.failure(NetworkError.invalidChar))
                return
            }
            self.fetchNews(url, completion: completion)
        }else {
            completion(.failure(.connectionError))
        }
    }
}
