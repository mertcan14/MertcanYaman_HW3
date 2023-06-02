//
//  DictionaryURL.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 26.05.2023.
//

import Foundation

enum DictionaryURL {
    private var baseURL: String { return "https://api.dictionaryapi.dev" }
    private var api: String { return "/api" }
    private var version: String { return "/v2" }
    private var category: String { return "/entries" }
    private var language: String { return "/en" }
    
    case word(String)
    
    private var fullPath: String {
        var endpoint:String
        switch self {
        case .word(var wordString):
            let words = wordString.split(separator: " ")
            wordString = ""
            words.forEach { splitWord in
                if splitWord == words[words.count - 1] {
                    wordString += splitWord
                }else {
                    wordString += splitWord + "%20"
                }
                
            }
            endpoint = "/\(wordString)"
        }
        return baseURL + api + version + category + language + endpoint
    }
    
    var url: URL? {
        guard let url = URL(string: fullPath) else {
            return nil
        }
        return url
    }
}
