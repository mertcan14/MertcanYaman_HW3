//
//  DictionaryService.swift
//  
//
//  Created by mertcan YAMAN on 26.05.2023.
//

import Foundation
import Alamofire

public protocol NewsServiceProtocol: AnyObject {
    func fetchNews<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void)
}

public class NewsService: NewsServiceProtocol {
    
    public init() {}
    
    public func fetchNews<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        AF.request(url).responseData { response in
            switch response.result {
                
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    print("JSON DECODE ERROR")
                }
            case .failure(let error):
                print("**** GEÇİCİ BİR HATA OLUŞTU: \(error.localizedDescription) ******")
            }
        }
        
    }
}
