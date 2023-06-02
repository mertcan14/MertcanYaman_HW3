//
//  HomeViewModel.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import Foundation
import DictionaryAPI
import MyCoreData

// MARK: Protocol HomeViewModelDelegate
protocol HomeViewModelDelegate: AnyObject {
    func alertFunc(_ message: String)
    func goDetailPage(_ dictionary: Dictionary)
    func goSplashPage()
    func addWordHistory(_ word: String)
    func reloadTableData()
}

// MARK: Protocol HomeViewModelProtocol
protocol HomeViewModelProtocol {
    var delegate: HomeViewModelDelegate? { get set }
    var numberOfWordHistory: Int { get }
    
    func addWordFromCore(_ appDelegate: AppDelegate, _ word: String)
    func getData(_ word: String)
    func getWordHistory(_ index: Int) -> String?
    func fetchWordFromCore(_ appDelegate: AppDelegate)
}

// MARK: Home View Model
final class HomeViewModel {
    var delegate: HomeViewModelDelegate?
    var dataDictionary: Dictionary?
    var wordHistory: [String] = [] {
        didSet {
            delegate?.reloadTableData()
        }
    }
    
    func fetchDataFromDictionary(_ word: String) {
        DictionaryService.shared.getDictionaryByWord(word) { [weak self] response in
            guard let self else { return }
            switch response {
            case.success(let dictionary):
                guard let firstDictionary = dictionary.first else { return }
                self.delegate?.addWordHistory(word)
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
    
    func fetchWordHistory(_ appDelegate: AppDelegate) {
        
        let persistent = appDelegate.persistentContainer
        MyCoreDataService.shared
            .fetchWordHistory(persistent,
                         maxObject: 5,
                         entityName: "WordHistory",
                         sortKey: "addedDate")
        { [weak self] response in
            guard let self = self else { return }
            switch response.self {
            case .success(let words):
                self.wordHistory = words
            case .failure(let error):
                self.delegate?.alertFunc(error.message ?? "error")
            }
        }
    }
    
    func addWordHistory(_ appDelegate: AppDelegate, _ word: String) {
        
        let context = appDelegate.persistentContainer
        let addWord: [String: Any] = [
            "word": word,
            "addedDate": Date(),
            "id": UUID()
        ]
        
        MyCoreDataService.shared
            .addWordHistory(persistentContainer: context,
                            entityName: "WordHistory",
                            addObj: addWord,
                            word: word)
        { [weak self] response in
            guard let self = self else { return }
            switch response.self {
            case .success(_):
                self.fetchWordHistory(appDelegate)
            case .failure(let error):
                self.delegate?.alertFunc(error.message ?? "")
            }
        }
    }
}

// MARK: Extension HomeViewModelProtocol
extension HomeViewModel: HomeViewModelProtocol {
    func addWordFromCore(_ appDelegate: AppDelegate, _ word: String) {
        self.addWordHistory(appDelegate, word.lowercased())
    }
    
    func fetchWordFromCore(_ appDelegate: AppDelegate) {
        self.fetchWordHistory(appDelegate)
    }
    
    var numberOfWordHistory: Int {
        self.wordHistory.count
    }
    
    func getWordHistory(_ index: Int) -> String? {
        if index >= 0 && index < numberOfWordHistory {
            return wordHistory[index]
        }
        return nil
    }
    
    func getData(_ word: String) {
        fetchDataFromDictionary(word)
    }
}
