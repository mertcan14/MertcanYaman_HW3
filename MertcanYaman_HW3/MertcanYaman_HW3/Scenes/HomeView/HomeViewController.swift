//
//  HomeViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import UIKit

final class HomeViewController: UIViewController {
    
    var homeViewModel: HomeViewModelProtocol!
    
    @IBOutlet weak var containerViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchOuterView: UIView!
    @IBOutlet weak var recentTableView: UITableView!
    
    var strings: [String] = [
        "Mert",
        "Can",
        "Mertcan",
        "Yaman",
        "Mertcan Yaman"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewModel = HomeViewModel()
        recentTableView.register(UINib(nibName: "RecentSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentSearchTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchOuterView.layer.shadowColor = UIColor.black.cgColor
        searchOuterView.layer.shadowOpacity = 0.6
        searchOuterView.layer.shadowOffset = .zero
        searchOuterView.layer.shadowRadius = 1.5
    }
    @IBAction func searchBtnClicked(_ sender: Any) {
        if searchTextField.text != "" {
            guard let word = searchTextField.text else { return }
            let sendVC = UIStoryboard(name: "DetailView", bundle: nil)
                .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            sendVC.detailViewModel = DetailViewModel(word: word)
            sendVC.modalPresentationStyle = .fullScreen
            sendVC.modalTransitionStyle = .coverVertical
            self.present(sendVC, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recentTableView.dequeueReusableCell(withIdentifier: "RecentSearchTableViewCell", for: indexPath) as! RecentSearchTableViewCell
        cell.setup(self.strings[indexPath.row])
        return cell
    }
}
