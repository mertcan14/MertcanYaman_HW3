//
//  DetailViewModel.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import Foundation
import DictionaryAPI

protocol DetailViewModelDelegate: AnyObject {
    func reloadTableView()
    func showLoading()
    func hideLoading()
    func setupViews()
    func checkAudio(_ isAudio: Bool)
    func alertFunc(_ message: String)
    func goDetailPage(_ dictionary: Dictionary)
}

protocol DetailViewModelProtocol {
    var delegate: DetailViewModelDelegate? { get set }
    var numberOfDefinitions: Int { get }
    var numberOfDefinitionsBySpeech: Int { get }
    
    func checkSynonymWords() -> Bool
    func getSynonymsWords() -> [String]
    func setDefinitionsBySpeech(_ speechs: Set<String>)
    func checkAudio()
    func getSpeech() -> Set<String>
    func getDefinitonByIndex(_ index: Int) -> DefinitionForCell?
    func getDefinitonSpeechByIndex(_ index: Int) -> DefinitionForCell?
    func getWord() -> String
    func getPhonetic() -> String?
    func getAudio() -> String?
    func setDefinitions()
    func fetchDataFromDictionary(_ word: String)
}

final class DetailViewModel {
    var delegate: DetailViewModelDelegate?
    var dataDictionary: Dictionary
    var dataSynonyms: [Synonyms]? {
        didSet {
            delegate?.reloadTableView()
        }
    }
    var definitions: [DefinitionForCell] = [] {
        didSet {
            delegate?.hideLoading()
        }
    }
    var definitionsBySpeech: [DefinitionForCell] = [] {
        didSet {
            delegate?.reloadTableView()
            delegate?.hideLoading()
        }
    }
    var speechs: Set<String> = []
    
    init(dictionary: Dictionary) {
        self.dataDictionary = dictionary
        self.fetchDataFromSynonyms()
        self.setDefinitions()
    }
    
    func fetchDataFromSynonyms() {
        DictionaryService.shared.getSynonymsByWord(self.dataDictionary.word ?? "") { [weak self] response in
            guard let self else { return }
            switch response {
            case.success(let synonyms):
                self.dataSynonyms = synonyms
            case .failure(let error):
                print("synonyms: \(String(describing: error.message))")
            }
        }
    }
    
    func setDefinitions() {
        guard let meanings = dataDictionary.meanings else { return }
        var definitionForCell: [DefinitionForCell] = []
        for meaning in meanings {
            guard let definitions = meaning.definitions else { return }
            guard let speech = meaning.partOfSpeech else { return }
            var index = 0
            self.speechs.insert(meaning.partOfSpeech ?? "")
            definitionForCell += definitions.map { definition in
                index += 1
                return DefinitionForCell(definition: definition, speech: speech, index: "\(index)")
            }
        }
        self.definitions = definitionForCell
    }
    
    func setDefinitionsBySpeech(_ speechs: Set<String>) {
        var definitionForCell: [DefinitionForCell] = []
        self.definitions.forEach { definition in
            print(definition.speech)
            if speechs.contains(definition.speech.capitalized) {
                definitionForCell.append(definition)
            }
        }
        self.definitionsBySpeech = definitionForCell
    }
    
    func checkAudio() {
        guard let phonetics = dataDictionary.phonetics else {
            delegate?.checkAudio(false)
            return
        }
        let audio = phonetics.filter { return $0.audio != "" }
        if audio.count != 0 {
            delegate?.checkAudio(true)
        }else {
            delegate?.checkAudio(false)
        }
    }
    
    func fetchDataFromDictionary(_ word: String) {
        DictionaryService.shared.getDictionaryByWord(word) { [weak self] response in
            guard let self else { return }
            switch response {
            case.success(let dictionary):
                guard let firstDictionary = dictionary.first else { return }
                self.delegate?.goDetailPage(firstDictionary)
            case .failure(let error):
                self.delegate?.alertFunc(error.message ?? "Error")
            }
        }
    }
}

extension DetailViewModel: DetailViewModelProtocol {
    func checkSynonymWords() -> Bool {
        guard let synonym = self.dataSynonyms else { return false }
        return synonym.isEmpty
    }
    
    func getSynonymsWords() -> [String] {
        guard let synonyms = dataSynonyms else { return [] }
        let words: [String] = synonyms.map { synonym in
            return synonym.word ?? ""
        }
        return words
    }
    
    func getDefinitonSpeechByIndex(_ index: Int) -> DefinitionForCell? {
        if 0 <= index && self.numberOfDefinitionsBySpeech > index {
            return definitionsBySpeech[index]
        }
        return nil
    }
    
    var numberOfDefinitionsBySpeech: Int {
        self.definitionsBySpeech.count
    }

    func getSpeech() -> Set<String> {
        self.speechs
    }

    func getAudio() -> String? {
        guard let phonetics = dataDictionary.phonetics else {
            return nil
        }
        let audio = phonetics.filter { return $0.audio != "" }
        if audio.count != 0 {
            return audio.first?.audio
        }else {
            return nil
        }
    }
    
    func getWord() -> String {
        return self.dataDictionary.word ?? ""
    }
    
    func getPhonetic() -> String? {
        return self.dataDictionary.phonetics?.first?.text
    }
    
    func getDefinitonByIndex(_ index: Int) -> DefinitionForCell? {
        if 0 <= index && self.numberOfDefinitions > index {
            return definitions[index]
        }
        return nil
    }
    
    var numberOfDefinitions: Int {
        definitions.count
    }
}
