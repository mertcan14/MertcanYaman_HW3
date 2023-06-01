//
//  HomeViewModel.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import Foundation
import DictionaryAPI
import CoreData

protocol HomeViewModelDelegate: AnyObject {
    func alertFunc(_ message: String)
    func goDetailPage(_ dictionary: Dictionary)
    func goSplashPage()
    func addWordHistory(_ word: String)
    func reloadTableData()
}

protocol HomeViewModelProtocol {
    var delegate: HomeViewModelDelegate? { get set }
    var numberOfWordHistory: Int { get }
    
    func addWordFromCore(_ appDelegate: AppDelegate, _ word: String)
    func getData(_ word: String)
    func getWordHistory(_ index: Int) -> String?
    func fetchWordFromCore(_ appDelegate: AppDelegate)
}

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
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WordHistory")
        fetchRequest.fetchLimit = 5
        let sort = NSSortDescriptor(key: "addedDate", ascending: false)
            fetchRequest.sortDescriptors = [sort]
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                self.wordHistory.removeAll()
                for result in results as! [NSManagedObject] {
                    guard let word = result.value(forKey: "word") as? String else { return }
                    self.wordHistory.append(word)
                }
            }
        }catch {
            print("error")
        }
    }
    
    func addWordHistory(_ appDelegate: AppDelegate, _ word: String) {
        let context = appDelegate.persistentContainer.viewContext
        guard let nsObject = checkWordHistory(appDelegate, word) else {
            let wordHistory = NSEntityDescription.insertNewObject(forEntityName: "WordHistory", into: context)
            wordHistory.setValue(word, forKey: "word")
            wordHistory.setValue(Date(), forKey: "addedDate")
            wordHistory.setValue(UUID(), forKey: "id")
            do {
                try context.save()
                fetchWordHistory(appDelegate)
            }catch {
                print(error)
            }
            return
        }
        nsObject.setValue(Date(), forKey: "addedDate")
        
        do {
            try context.save()
            fetchWordHistory(appDelegate)
        }catch {
            print(error)
        }
    }
    
    private func checkWordHistory(_ appDelegate: AppDelegate, _ word: String) -> NSManagedObject? {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WordHistory")
        let predicate = NSPredicate(format: "word = %@", "\(word)")
        fetchRequest.predicate = predicate
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    return result
                }
            }
        }catch {
            delegate?.alertFunc(error.localizedDescription)
        }
        return nil
    }
}

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
