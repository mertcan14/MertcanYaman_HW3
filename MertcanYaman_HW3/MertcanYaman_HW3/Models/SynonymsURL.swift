//
//  SynonymsURL.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import Foundation

public enum SynonymsURL {
    private var baseURL: String { return "https://api.datamuse.com" }
    private var path: String { return "/words" }
    
    case word(String)
    case wordAndMax(String, String)
    
    private var fullPath: String {
        var endpoint:String
        switch self {
        case .word(let wordString):
            endpoint = "?rel_syn=\(wordString)&max=5"
        case .wordAndMax(let wordString, let maxString):
            endpoint = "?rel_syn=\(wordString)&max=\(maxString)"
        }
        return baseURL + path + endpoint
    }
    
    var url: URL? {
        guard let url = URL(string: fullPath) else {
            return nil
        }
        return url
    }
}
