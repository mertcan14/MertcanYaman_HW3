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
    func reloadTitleView()
    func showLoading()
    func hideLoading()
    func checkAudio(_ audio: String?)
    func alertFunc(_ message: String)
}

protocol DetailViewModelProtocol {
    var delegate: DetailViewModelDelegate? { get set }
    var numberOfDefinitions: Int { get }
    
    func getDataFromDictionary()
    func getDefinitonByIndex(_ index: Int) -> DefinitionForCell?
    func getWord() -> String
    func getPhonetic() -> String?
    func getAudio() -> String?
}

final class DetailViewModel {
    var delegate: DetailViewModelDelegate?
    var dataDictionary: Dictionary? {
        didSet {
            setDefinitions()
            checkAudio()
            delegate?.reloadTitleView()
        }
    }
    var dataSynonyms: [Synonyms]?
    var definitions: [DefinitionForCell] = [] {
        didSet {
            delegate?.reloadTableView()
            delegate?.hideLoading()
        }
    }
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
                self.delegate?.alertFunc(error.message ?? "Error")
            }
        }
    }
    
    func fetchDataFromSynonyms() {
        DictionaryService.shared.getSynonymsByWord(self.word) { [weak self] response in
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
        guard let meanings = dataDictionary?.meanings else { return }
        for meaning in meanings {
            guard let definitions = meaning.definitions else { return }
            guard let speech = meaning.partOfSpeech else { return }
            var index = 1
            definitions.map { definition in
                self.definitions.append(DefinitionForCell(definition: definition, speech: speech, index: "\(index)"))
                index += 1
            }
        }
    }
    
    func checkAudio() {
        guard let phonetics = dataDictionary?.phonetics else {
            delegate?.checkAudio(nil)
            return
        }
        let audio = phonetics.filter { return $0.audio != "" }
        if audio.count != 0 {
            delegate?.checkAudio(audio.first?.audio)
        }else {
            delegate?.checkAudio(nil)
        }
    }
}

extension DetailViewModel: DetailViewModelProtocol {
    
    func getAudio() -> String? {
        guard let phonetics = dataDictionary?.phonetics else {
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
        return self.dataDictionary?.word ?? ""
    }
    
    func getPhonetic() -> String? {
        return self.dataDictionary?.phonetics?.first?.text
    }
    
    func getDefinitonByIndex(_ index: Int) -> DefinitionForCell? {
        if 0 <= index && definitions.count > index {
            return definitions[index]
        }
        return nil
    }
    
    var numberOfDefinitions: Int {
        definitions.count
    }
    
    func getDataFromDictionary() {
        self.fetchDataFromDictionary()
        self.fetchDataFromSynonyms()
    }
}
