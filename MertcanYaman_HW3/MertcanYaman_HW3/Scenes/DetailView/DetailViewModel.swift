//
//  DetailViewModel.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import Foundation
import DictionaryAPI
import AVFoundation

// MARK: Protocol DetailViewModelDelegate
protocol DetailViewModelDelegate: AnyObject {
    func reloadTableView()
    func showLoading()
    func hideLoading()
    func checkAudio(_ isAudio: Bool)
    func alertFunc(_ message: String)
    func goDetailPage(_ dictionary: Dictionary)
    func goSplashPage()
}

// MARK: Protocol DetailViewModelProtocol
protocol DetailViewModelProtocol {
    var delegate: DetailViewModelDelegate? { get set }
    var numberOfDefinitions: Int { get }
    var numberOfDefinitionsBySpeech: Int { get }
    var numberOfSelectedFilter: Int { get }
    var numberOfSpeech: Int { get }
    
    func removeLastFilter()
    func addSelectedFilter(_ title: String)
    func getSelectedFilter() -> [String]?
    func removeAllSelectedFilter()
    func checkSynonymWords() -> Bool
    func getSynonymsWords() -> [String]
    func checkAudio()
    func getSpeech() -> Set<String>
    func getDefinitonByIndex(_ index: Int) -> DefinitionForCell?
    func getDefinitonSpeechByIndex(_ index: Int) -> DefinitionForCell?
    func getWord() -> (String, String)?
    func fetchDataFromDictionary(_ word: String)
    func startAudio()
}

// MARK: Detail View Model
final class DetailViewModel {
    
    // MARK: - Variable Definitions
    var delegate: DetailViewModelDelegate?
    var player: AVPlayer?
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
    var selectedFilter: [String] = []
    
    init(dictionary: Dictionary) {
        self.dataDictionary = dictionary
        self.fetchDataFromSynonyms()
        self.setDefinitions()
    }
    
    // MARK: - Fetch Funcs
    func fetchDataFromSynonyms() {
        delegate?.showLoading()
        DictionaryService.shared.getSynonymsByWordAndMax(self.dataDictionary.word ?? "", "5") { [weak self] response in
            guard let self else { return }
            switch response {
            case.success(let synonyms):
                self.delegate?.hideLoading()
                self.dataSynonyms = synonyms
            case .failure(let error):
                self.delegate?.hideLoading()
                print("synonyms: \(String(describing: error.message))")
            }
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
                if error.message == NetworkError.connectionError.message {
                    self.delegate?.goSplashPage()
                }else {
                    self.delegate?.alertFunc(error.message ?? "Error")
                }
            }
        }
    }
    
    // MARK: - Audio Funcs
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
    
    func getAudio() -> AVPlayerItem? {
        guard let phonetics = dataDictionary.phonetics else {
            return nil
        }
        var playerItem: AVPlayerItem?
        phonetics.forEach { phonetic in
            if phonetic.audio != "" {
                guard let audio = phonetic.audio else { return }
                let url = URL(string: audio)
                playerItem = AVPlayerItem(url: url!)
                return
            }
        }
        return playerItem
    }
    
    // MARK: - Definitions Funcs
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
    
    func setDefinitionsBySpeech(_ speechs: [String]) {
        var definitionForCell: [DefinitionForCell] = []
        self.definitions.forEach { definition in
            if speechs.contains(definition.speech.capitalized) {
                definitionForCell.append(definition)
            }
        }
        self.definitionsBySpeech = definitionForCell
    }
}

// MARK: Extension HomeViewModelProtocol
extension DetailViewModel: DetailViewModelProtocol {
    
    // MARK: - NumberOfObject Variables
    var numberOfSpeech: Int {
        self.speechs.count
    }
    
    var numberOfSelectedFilter: Int {
        self.selectedFilter.count
    }
    
    var numberOfDefinitionsBySpeech: Int {
        self.definitionsBySpeech.count
    }
    
    var numberOfDefinitions: Int {
        definitions.count
    }
    
    // MARK: - Filter Funcs
    func removeLastFilter() {
        if selectedFilter.count >= 1 {
            self.selectedFilter.remove(at: selectedFilter.count - 1)
            setDefinitionsBySpeech(self.selectedFilter)
        }
    }
    
    func removeAllSelectedFilter() {
        self.selectedFilter.removeAll()
    }
    
    func addSelectedFilter(_ title: String) {
        self.selectedFilter.append(title)
        setDefinitionsBySpeech(self.selectedFilter)
    }
    
    func getSelectedFilter() -> [String]? {
        return selectedFilter
    }
    
    // MARK: - Synonym Funcs
    func checkSynonymWords() -> Bool {
        guard let synonym = self.dataSynonyms else { return false }
        return synonym.count == 0 ? false : true
    }
    
    func getSynonymsWords() -> [String] {
        guard let synonyms = dataSynonyms else { return [] }
        let words: [String] = synonyms.map { synonym in
            return synonym.word ?? ""
        }
        return words
    }
    
    // MARK: - Definiton Funcs
    func getDefinitonSpeechByIndex(_ index: Int) -> DefinitionForCell? {
        if 0 <= index && self.numberOfDefinitionsBySpeech > index {
            return definitionsBySpeech[index]
        }
        return nil
    }
    
    func getDefinitonByIndex(_ index: Int) -> DefinitionForCell? {
        if 0 <= index && self.numberOfDefinitions > index {
            return definitions[index]
        }
        return nil
    }
    
    // MARK: - Word Funcs
    func getSpeech() -> Set<String> {
        self.speechs
    }
    
    func getWord() -> (String, String)? {
        guard let phonetics = self.dataDictionary.phonetics else { return nil }
        guard let word = self.dataDictionary.word else { return nil }
        
        for phonetic in phonetics {
            if phonetic.text != "", let text = phonetic.text {
                return (word, text)
            }
        }
        return (word, "")
    }
    
    func startAudio() {
        guard let player = getAudio() else { return }
        self.player = AVPlayer(playerItem:player)
        self.player?.play()
    }
}
