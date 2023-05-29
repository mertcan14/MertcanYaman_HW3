//
//  DetailViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import UIKit

class DetailViewController: UIViewController, LoadingShowable {
    
    var detailViewModel: DetailViewModelProtocol! {
        didSet {
            detailViewModel.delegate = self
        }
    }
    var selectedFilter: Set<String> = []
    
    @IBOutlet weak var phoneticLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dictionaryTableView: UITableView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var selectedFilterView: UIView!
    @IBOutlet weak var selectedFilterLabel: UILabel!
    @IBOutlet weak var adjectiveOuterView: UIView!
    @IBOutlet weak var verbOuterView: UIView!
    @IBOutlet weak var cancelOuterView: UIView!
    @IBOutlet weak var nounOuterView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailViewModel.getDataFromDictionary()
        setGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showLoading()
        setFilterViewBorder(adjectiveOuterView, UIColor.lightGray)
        setFilterViewBorder(verbOuterView, UIColor.lightGray)
        setFilterViewBorder(cancelOuterView, UIColor.blue)
        setFilterViewBorder(nounOuterView, UIColor.lightGray)
        setFilterViewBorder(selectedFilterView, UIColor.blue)
        dictionaryTableView.register(UINib(nibName: "MeaningTableViewCell", bundle: nil), forCellReuseIdentifier: "MeaningTableViewCell")
    }
    
    private func setFilterViewBorder(_ view: UIView, _ color: UIColor) {
        view.layer.borderWidth = 1
        view.layer.borderColor = color.cgColor
    }
    
    private func setGesture() {
        let nounTap = UITapGestureRecognizer(target: self, action: #selector(selectFilter))
        let cancelTap = UITapGestureRecognizer(target: self, action: #selector(selectFilter))
        let verbTap = UITapGestureRecognizer(target: self, action: #selector(selectFilter))
        let adjectiveTap = UITapGestureRecognizer(target: self, action: #selector(selectFilter))
        let backTap = UITapGestureRecognizer(target: self, action: #selector(back))
        nounOuterView.addGestureRecognizer(nounTap)
        cancelOuterView.addGestureRecognizer(cancelTap)
        verbOuterView.addGestureRecognizer(verbTap)
        adjectiveOuterView.addGestureRecognizer(adjectiveTap)
        backButton.addGestureRecognizer(backTap)
    }
    
    @objc func selectFilter(_ sender: UITapGestureRecognizer? = nil) {
        if selectedFilter.count == 0 {
            cancelOuterView.isHidden = false
            selectedFilterView.isHidden = false
        }
        guard let view = sender?.view else { return }
        switch view {
        case cancelOuterView:
            selectedFilter.removeAll()
            adjectiveOuterView.isHidden = false
            nounOuterView.isHidden = false
            verbOuterView.isHidden = false
            selectedFilterView.isHidden = true
        default:
            guard let text = view.subviews.first as? UILabel else { return }
            selectedFilter.insert(text.text ?? "")
        }
        view.isHidden = true
        selectedFilterLabel.text = selectedFilter.joined(separator: ", ")
    }
    
    @objc func back() {
        dismiss(animated: true)
    }
}

extension DetailViewController: DetailViewModelDelegate {
    func reloadTitleView() {
        DispatchQueue.main.async {
            self.titleLabel.text = self.detailViewModel.getWord().capitalized
            self.phoneticLabel.text = self.detailViewModel.getPhonetic()
        }
    }
    
    func reloadTableView() {
        dictionaryTableView.reloadData()
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailViewModel.numberOfDefinitions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeaningTableViewCell") as! MeaningTableViewCell
        guard let definition = detailViewModel.getDefinitonByIndex(indexPath.row) else { return cell }
        cell.setup(definition)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
