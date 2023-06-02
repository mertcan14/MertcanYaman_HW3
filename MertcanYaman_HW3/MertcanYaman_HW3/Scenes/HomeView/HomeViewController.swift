//
//  HomeViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import UIKit

final class HomeViewController: UIViewController, LoadingShowable {
    
    // MARK: - Variable Definitions
    var homeViewModel: HomeViewModelProtocol! {
        didSet {
            homeViewModel.delegate = self
        }
    }
    
    // MARK: - IBOutlet Definitions
    @IBOutlet weak var containerViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchOuterView: UIView!
    @IBOutlet weak var recentTableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewModel = HomeViewModel()
        setRegister()
        setNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getWordHistory()
        setShadow()
    }
    
    // MARK: - @IBAction Methods
    @IBAction func searchBtnClicked(_ sender: Any) {
        showLoading()
        self.view.endEditing(true)
        if searchTextField.text != "" {
            homeViewModel.getData(searchTextField.text ?? "")
        }else {
            alertFunc("Searched word cannot be empty")
        }
    }
    
    // MARK: - Funcs
    func getWordHistory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        homeViewModel.fetchWordFromCore(appDelegate)
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
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setRegister() {
        recentTableView.register(UINib(nibName: "RecentSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentSearchTableViewCell")
    }
    
    private func setShadow() {
        searchOuterView.layer.shadowColor = UIColor.black.cgColor
        searchOuterView.layer.shadowOpacity = 0.6
        searchOuterView.layer.shadowOffset = .zero
        searchOuterView.layer.shadowRadius = 1.5
    }
}
// MARK: - Extension UITableViewDelegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homeViewModel.numberOfWordHistory
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoading()
        self.view.endEditing(true)
        guard let word = homeViewModel.getWordHistory(indexPath.row) else { return }
        homeViewModel.getData(word)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recentTableView.dequeueReusableCell(withIdentifier: "RecentSearchTableViewCell", for: indexPath) as! RecentSearchTableViewCell
        guard let word = homeViewModel.getWordHistory(indexPath.row) else { return cell }
        cell.setup(word)
        return cell
    }
}

// MARK: - Extension HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    func goSplashPage() {
        hideLoading()
        let sendVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        searchTextField.text = ""
        sendVC.modalPresentationStyle = .fullScreen
        sendVC.modalTransitionStyle = .coverVertical
        self.present(sendVC, animated: true, completion: nil)
    }
    
    func reloadTableData() {
        self.recentTableView.reloadData()
    }
    
    func alertFunc(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { UIAlertAction in
            self.hideLoading()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addWordHistory(_ word: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        homeViewModel.addWordFromCore(appDelegate, word)
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
