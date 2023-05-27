//
//  HomeViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import UIKit

final class HomeViewController: UIViewController {
    
    
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
        recentTableView.register(UINib(nibName: "RecentSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentSearchTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchOuterView.layer.shadowColor = UIColor.black.cgColor
        searchOuterView.layer.shadowOpacity = 0.6
        searchOuterView.layer.shadowOffset = .zero
        searchOuterView.layer.shadowRadius = 1.5
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
