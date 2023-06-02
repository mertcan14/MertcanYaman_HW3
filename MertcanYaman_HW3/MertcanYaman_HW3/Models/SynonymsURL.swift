//
//  SynonymsURL.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import Foundation

enum SynonymsURL {
    private var baseURL: String { return "https://api.datamuse.com" }
    private var path: String { return "/words" }
    
    case wordAndMax(String, String)
    
    private var fullPath: String {
        var endpoint:String
        switch self {
        case .wordAndMax(var wordString, let maxString):
            let words = wordString.split(separator: " ")
            wordString = ""
            words.forEach { splitWord in
                if splitWord == words[words.count - 1] {
                    wordString += splitWord
                }else {
                    wordString += splitWord + "_"
                }
                
            }
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
