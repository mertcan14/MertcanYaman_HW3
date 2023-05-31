//
//  DetailViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 28.05.2023.
//

import UIKit
import AVFoundation

final class DetailViewController: UIViewController, LoadingShowable {
    
    var detailViewModel: DetailViewModelProtocol! {
        didSet {
            detailViewModel.delegate = self
        }
    }
    var selectedFilter: Set<String> = []
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    
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
        for word in words {
            let button = CustomButton()
            button.setTitle(word.capitalized, for: .normal)
            button.addTarget(self, action: #selector(self.addFilter), for: .touchUpInside)
            self.filterStackView.addArrangedSubview(button)
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
    }
    
    @objc func removeFilter() {
        selectedFilter.removeAll()
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
        guard let audio = detailViewModel.getAudio() else { return }
        let url = URL(string: audio)
        
        let playerItem = AVPlayerItem(url: url!)
        
        self.player = AVPlayer(playerItem:playerItem)
        player!.play()
    }
    
    @objc func addFilter(_ button: UIButton!) {
        self.showLoading()
        if self.selectedFilter.count == 0 {
            self.cancelOuterView.isHidden = false
            self.selectedFilterView.isHidden = false
        }
        button.isHidden = true
        guard let title = button.titleLabel?.text else { return }
        self.selectedFilter.insert(title)
        selectedFilterLabel.text = selectedFilter.joined(separator: ", ")
        detailViewModel.setDefinitionsBySpeech(self.selectedFilter)
    }
    
    private func registerTableCell() {
        dictionaryTableView.register(UINib(nibName: "MeaningTableViewCell", bundle: nil), forCellReuseIdentifier: "MeaningTableViewCell")
        dictionaryTableView.register(UINib(nibName: "SynonymTableViewCell", bundle: nil), forCellReuseIdentifier: "SynonymTableViewCell")
    }
}

extension DetailViewController: DetailViewModelDelegate {
    func setupViews() {
        self.setupFilterButton()
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
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            switch action.style {
            case .default:
                self.hideLoading()
                self.dismiss(animated: true)
            @unknown default:
                self.hideLoading()
                self.dismiss(animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedFilter.count != 0 {
            return detailViewModel.numberOfDefinitionsBySpeech + 1
        }else {
            return detailViewModel.numberOfDefinitions + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.selectedFilter.count != 0 {
            if detailViewModel.numberOfDefinitionsBySpeech == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SynonymTableViewCell") as! SynonymTableViewCell
                let words = detailViewModel.getSynonymsWords()
                cell.setup(words)
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeaningTableViewCell") as! MeaningTableViewCell
                guard let definition = detailViewModel.getDefinitonSpeechByIndex(indexPath.row) else { return cell }
                cell.setup(definition)
                return cell
            }
            
        }else {
            if detailViewModel.numberOfDefinitions == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SynonymTableViewCell") as! SynonymTableViewCell
                let words = detailViewModel.getSynonymsWords()
                cell.setup(words)
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeaningTableViewCell") as! MeaningTableViewCell
                guard let definition = detailViewModel.getDefinitonByIndex(indexPath.row) else { return cell }
                cell.setup(definition)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
