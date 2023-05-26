//
//  Dictionary.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 26.05.2023.
//

import Foundation

// MARK: - WelcomeElement
public struct WelcomeElement: Decodable {
    let word: String?
    let phonetics: [Phonetic]?
    let meanings: [Meaning]?
    let license: License?
    let sourceUrls: [String]?
}

// MARK: - License
public struct License: Decodable {
    let name: String?
    let url: String?
}

// MARK: - Meaning
public struct Meaning: Decodable {
    let partOfSpeech: String?
    let definitions: [Definition]?
    let synonyms, antonyms: [String]?
}

// MARK: - Definition
public struct Definition: Decodable {
    let definition: String?
    let synonyms, antonyms: [String]?
    let example: String?
}

// MARK: - Phonetic
public struct Phonetic: Decodable {
    let audio: String?
    let sourceURL: String?
    let license: License?
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case audio
        case sourceURL = "sourceUrl"
        case license, text
    }
}
