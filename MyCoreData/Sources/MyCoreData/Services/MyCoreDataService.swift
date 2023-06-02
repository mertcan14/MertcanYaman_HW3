//
//  MyCoreDataService.swift
//  
//
//  Created by mertcan YAMAN on 1.06.2023.
//

import Foundation
import CoreData

public enum CoreDataError: Error {
    case operationFailed
    case maxObjectNegative
    case error(Error)
    
    public var message: String? {
        switch self {
        case .operationFailed:
            return "We encountered an unexpected error"
        case .maxObjectNegative:
            return "The value to be returned cannot be negative."
            
        case .error(let error):
            return error.localizedDescription
        }
    }
}

public class MyCoreDataService {
    public static let shared = MyCoreDataService()
    /// Fetch data from Core Data
    public func fetchWordHistory(_ persistentContainer: NSPersistentContainer,
                                 maxObject: Int?,
                                 entityName: String,
                                 sortKey: String?,
                                 completion: @escaping (Result<[String], CoreDataError>) -> Void)
    {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        if let maxObj = maxObject {
            if maxObj < 0 {
                completion(.failure(.maxObjectNegative))
            }else if maxObj > 0 {
                fetchRequest.fetchLimit = maxObj
            }
        }
        
        if let key = sortKey {
            let sort = NSSortDescriptor(key: key, ascending: false)
            fetchRequest.sortDescriptors = [sort]
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                var words: [String] = []
                for result in results as! [NSManagedObject] {
                    guard let word = result.value(forKey: "word") as? String else { return }
                    words.append(word)
                }
                completion(.success(words))
            }
        }catch {
            completion(.failure(.operationFailed))
        }
    }
    
    /// Add data from Core Data 
    public func addWordHistory( persistentContainer: NSPersistentContainer,
                                entityName: String,
                                addObj: [String:Any],
                                word: String,
                                completion: @escaping (Result<Bool, CoreDataError>) -> Void) {
        let context = persistentContainer.viewContext
        guard let nsObject = checkWordHistory(persistentContainer, entityName: entityName, word: word) else {
            let wordHistory = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            addObj.keys.forEach { key in
                wordHistory.setValue(addObj[key], forKey: key)
            }
            do {
                try context.save()
                completion(.success(true))
            }catch {
                completion(.failure(.operationFailed))
            }
            return
        }
        nsObject.setValue(Date(), forKey: "addedDate")
        
        do {
            try context.save()
            completion(.success(true))
        }catch {
            completion(.failure(.operationFailed))
        }
    }
    
    /// Returns Row if word is already inserted, returns nil if there is no row
    private func checkWordHistory(_ persistentContainer: NSPersistentContainer,
                                  entityName: String,
                                  word: String) -> NSManagedObject? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
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
            print("Error")
        }
        return nil
    }
}
