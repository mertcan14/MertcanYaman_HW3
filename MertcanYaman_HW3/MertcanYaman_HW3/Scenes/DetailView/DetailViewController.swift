//
//  DetailViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import UIKit

final class DetailViewController: UIViewController, LoadingShowable {
    
    var detailViewModel: DetailViewModelProtocol! {
        didSet {
            detailViewModel.delegate = self
        }
    }
    var checkSynonym: Bool = false
    
    @IBOutlet weak var filterStackView: UIStackView!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var phoneticLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dictionaryTableView: UITableView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var selectedFilterView: UIView!
    @IBOutlet weak var selectedFilterLabel: UILabel!
    @IBOutlet weak var cancelOuterView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGesture()
        setNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        detailViewModel.checkAudio()
        setTitleView()
        setFilterViewBorder(cancelOuterView, UIColor.blue)
        setFilterViewBorder(selectedFilterView, UIColor.blue)
        registerTableCell()
        setupViews()
    }
    
    func setTitleView() {
        DispatchQueue.main.async {
            self.titleLabel.text = self.detailViewModel.getWord().capitalized
            guard let phonetic = self.detailViewModel.getPhonetic() else {
                self.phoneticLabel.isHidden = true
                return
            }
            self.phoneticLabel.text = phonetic
        }
    }
    
    func setupFilterButton() {
        filterStackView.arrangedSubviews.forEach { view in
            if type(of: view) == CustomButton.self {
                view.removeFromSuperview()
            }
        }
        let words = detailViewModel.getSpeech()
        let fontSize: Double = UIScreen.main.bounds.size.width > 380 ? 14 : 13
        guard let filterSpeech = detailViewModel.getSelectedFilter() else { return }
        for word in words {
            if !filterSpeech.contains(word.capitalized) {
                let button = CustomButton()
                button.setup(12, 6, fontSize)
                button.setTitle(word.capitalized, for: .normal)
                button.addTarget(self, action: #selector(self.addFilter), for: .touchUpInside)
                self.filterStackView.addArrangedSubview(button)
            }
        }
    }
    
    private func setFilterViewBorder(_ view: UIView, _ color: UIColor) {
        view.layer.borderWidth = 1
        view.layer.borderColor = color.cgColor
    }
    
    private func setGesture() {
        let cancelTap = UITapGestureRecognizer(target: self, action: #selector(removeFilter))
        cancelOuterView.addGestureRecognizer(cancelTap)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(back))
        backButton.addGestureRecognizer(backTap)
        
        let audioTap = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        audioImageView.addGestureRecognizer(audioTap)
        
        let removeTap = UITapGestureRecognizer(target: self, action: #selector(removeLastFilter))
        self.selectedFilterView.addGestureRecognizer(removeTap)
    }
    
    @objc func removeLastFilter() {
        detailViewModel.removeLastFilter()
        guard let selectedFilters = detailViewModel.getSelectedFilter() else { return }
        if selectedFilters.count == 0 {
            removeFilter()
        }else {
            setupFilterButton()
            selectedFilterLabel.text = selectedFilters.joined(separator: ", ")
        }
    }
    
    @objc func removeFilter() {
        detailViewModel.removeAllSelectedFilter()
        setupFilterButton()
        selectedFilterView.isHidden = true
        cancelOuterView.isHidden = true
        reloadTableView()
    }
    
    @objc func back() {
        dismiss(animated: true)
    }
    
    @objc func playButtonTapped()
    {
        detailViewModel.startAudio()
    }
    
    @objc func addFilter(_ button: UIButton!) {
        self.showLoading()
        if detailViewModel.numberOfSelectedFilter == 0 {
            self.cancelOuterView.isHidden = false
            self.selectedFilterView.isHidden = false
        }
        button.isHidden = true
        guard let title = button.titleLabel?.text else { return }
        detailViewModel.addSelectedFilter(title)
        guard let selectedFilters = detailViewModel.getSelectedFilter() else { return }
        selectedFilterLabel.text = selectedFilters.joined(separator: ", ")
    }
    
    private func registerTableCell() {
        dictionaryTableView.register(UINib(nibName: "MeaningTableViewCell", bundle: nil), forCellReuseIdentifier: "MeaningTableViewCell")
        dictionaryTableView.register(UINib(nibName: "SynonymTableViewCell", bundle: nil), forCellReuseIdentifier: "SynonymTableViewCell")
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        guard let word = notification.userInfo,
                let wordd = word["word"] as? String
                else { return }
        showLoading()
        detailViewModel.fetchDataFromDictionary(wordd)
    }
    
    func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)
    }
}

extension DetailViewController: DetailViewModelDelegate {
    func goSplashPage() {
        hideLoading()
        let sendVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        sendVC.modalPresentationStyle = .fullScreen
        sendVC.modalTransitionStyle = .coverVertical
        self.present(sendVC, animated: true, completion: nil)
    }
    
    func setupViews() {
        if detailViewModel.numberOfSpeech <= 1 {
            filterStackView.isHidden = true
        }else {
            self.setupFilterButton()
        }
        
    }
    
    func checkAudio(_ isAudio: Bool) {
        if !isAudio {
            audioImageView.isHidden = true
        }
    }
    
    func reloadTableView() {
        dictionaryTableView.reloadData()
    }
    
    func alertFunc(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { UIAlertAction in
            self.hideLoading()
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.checkSynonym = detailViewModel.checkSynonymWords()
        if detailViewModel.numberOfSelectedFilter != 0 {
            return detailViewModel.numberOfDefinitionsBySpeech + (self.checkSynonym ? 0 : 1)
        }else {
            return detailViewModel.numberOfDefinitions + (self.checkSynonym ? 0 : 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !self.checkSynonym {
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
            if totalRows - 1 == indexPath.row {
                let synonymCell = tableView.dequeueReusableCell(withIdentifier: "SynonymTableViewCell") as! SynonymTableViewCell
                let words = detailViewModel.getSynonymsWords()
                synonymCell.setup(words)
                return synonymCell
            }
        }
        
        if detailViewModel.numberOfSelectedFilter != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeaningTableViewCell") as! MeaningTableViewCell
            guard let definition = detailViewModel.getDefinitonSpeechByIndex(indexPath.row) else { return cell }
            cell.setup(definition)
            return cell
            
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeaningTableViewCell") as! MeaningTableViewCell
            guard let definition = detailViewModel.getDefinitonByIndex(indexPath.row) else { return cell }
            cell.setup(definition)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func goDetailPage(_ dictionary: Dictionary) {
        removeFilter()
        hideLoading()
        let sendVC = UIStoryboard(name: "DetailView", bundle: nil)
            .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        sendVC.detailViewModel = DetailViewModel(dictionary: dictionary)
        sendVC.modalPresentationStyle = .fullScreen
        sendVC.modalTransitionStyle = .coverVertical
        self.present(sendVC, animated: true, completion: nil)
    }
}
