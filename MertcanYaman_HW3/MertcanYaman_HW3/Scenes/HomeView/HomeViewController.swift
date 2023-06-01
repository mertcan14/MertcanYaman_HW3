//
//  HomeViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import UIKit
import CoreData

final class HomeViewController: UIViewController, LoadingShowable {
    
    var homeViewModel: HomeViewModelProtocol! {
        didSet {
            homeViewModel.delegate = self
        }
    }
    
    @IBOutlet weak var containerViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchOuterView: UIView!
    @IBOutlet weak var recentTableView: UITableView!
    
    var strings: [String] = [] {
        didSet {
            recentTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewModel = HomeViewModel()
        recentTableView.register(UINib(nibName: "RecentSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentSearchTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getWordHistory()
        searchOuterView.layer.shadowColor = UIColor.black.cgColor
        searchOuterView.layer.shadowOpacity = 0.6
        searchOuterView.layer.shadowOffset = .zero
        searchOuterView.layer.shadowRadius = 1.5
    }
    @IBAction func searchBtnClicked(_ sender: Any) {
        showLoading()
        self.view.endEditing(true)
        if searchTextField.text != "" {
            homeViewModel.getData(searchTextField.text ?? "")
        }else {
            alertFunc("Searched word cannot be empty")
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 1) {
                    self.containerViewBottomConst.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if containerViewBottomConst.constant != 0 {
            UIView.animate(withDuration: 1) {
                self.containerViewBottomConst.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        strings.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoading()
        self.view.endEditing(true)
        homeViewModel.getData(strings[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recentTableView.dequeueReusableCell(withIdentifier: "RecentSearchTableViewCell", for: indexPath) as! RecentSearchTableViewCell
        cell.setup(self.strings[indexPath.row])
        return cell
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func alertFunc(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            switch action.style {
            case .default:
                self.hideLoading()
            @unknown default:
                self.hideLoading()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addWordHistory(_ word: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        guard let nsObject = checkWordHistory(word.lowercased()) else {
            let wordHistory = NSEntityDescription.insertNewObject(forEntityName: "WordHistory", into: context)
            wordHistory.setValue(word.lowercased(), forKey: "word")
            wordHistory.setValue(Date(), forKey: "addedDate")
            wordHistory.setValue(UUID(), forKey: "id")
            do {
                try context.save()
                getWordHistory()
            }catch {
                print(error)
            }
            return
        }
        nsObject.setValue(Date(), forKey: "addedDate")
        
        do {
            try context.save()
            getWordHistory()
        }catch {
            print(error)
        }
    }
    
    func getWordHistory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WordHistory")
        fetchRequest.fetchLimit = 5
        let sort = NSSortDescriptor(key: "addedDate", ascending: false)
            fetchRequest.sortDescriptors = [sort]
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                strings.removeAll()
                for result in results as! [NSManagedObject] {
                    guard let word = result.value(forKey: "word") as? String else { return }
                    self.strings.append(word)
                }
            }
        }catch {
            print("error")
        }
    }
    
    func checkWordHistory(_ word: String) -> NSManagedObject? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
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
            print("error")
            return nil
        }
        return nil
    }
    
    func goDetailPage(_ dictionary: Dictionary) {
        hideLoading()
        let sendVC = UIStoryboard(name: "DetailView", bundle: nil)
            .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        sendVC.detailViewModel = DetailViewModel(dictionary: dictionary)
        searchTextField.text = ""
        sendVC.modalPresentationStyle = .fullScreen
        sendVC.modalTransitionStyle = .coverVertical
        self.present(sendVC, animated: true, completion: nil)
    }
}
