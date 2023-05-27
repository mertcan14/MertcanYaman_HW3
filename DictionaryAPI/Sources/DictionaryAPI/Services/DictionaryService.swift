//
//  DictionaryService.swift
//
//
//  Created by mertcan YAMAN on 26.05.2023.
//

import Foundation
import Alamofire

public enum NetworkError: Error {
    case emptyDataError
    case operationFailed
    case connectionError
    case error(Error)
    
    public var message: String? {
        switch self {
            
        case .operationFailed:
            return "We encountered an unexpected error"
        case .connectionError:
            return "You do not have an internet connection"
        case .error(let error):
            return error.localizedDescription
        case .emptyDataError:
            return "We couldn't find the result you were looking for"
        }
    }
}

public protocol DictionaryServiceProtocol: AnyObject {
    func fetchNews<T: Decodable>(_ url: URL, completion: @escaping (Result<T, NetworkError>) -> Void)
}

public class DictionaryService: DictionaryServiceProtocol {
    
    public static let shared = DictionaryService()
    
    public init() {}
    
    public func fetchNews<T: Decodable>(
        _ url: URL,
        completion: @escaping (Result<T, NetworkError>) -> Void)
    {
        AF.request(url).responseData { response in
            
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.emptyDataError))
                }
            case .failure(_):
                completion(.failure(.operationFailed))
            }
        }
    }
}
