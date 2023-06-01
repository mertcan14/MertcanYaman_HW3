//
//  SplashViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import UIKit

class SplashViewController: UIViewController, LoadingShowable {
    
    var splashViewModel: SplashViewModelProtocol! {
        didSet {
            splashViewModel.delegate = self
        }
    }
    
    @IBOutlet weak var contentView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splashViewModel = SplashViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        splashViewModel.checkConnection(0)
    }
    
    @IBAction func tryBtnClicked(_ sender: Any) {
        showLoading()
        splashViewModel.checkConnection(0.5)
    }
}

extension SplashViewController: SplashViewModelDelegate {
    func goBackPage() {
        dismiss(animated: true)
    }
    
    func showContentView() {
        self.contentView.isHidden = false
    }
    
    func goHomePage() {
        let sendVC = UIStoryboard(name: "HomeView", bundle: nil)
            .instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        sendVC.modalPresentationStyle = .fullScreen
        sendVC.modalTransitionStyle = .coverVertical
        self.present(sendVC, animated: true, completion: nil)
    }
    
    func hideContentView() {
        self.contentView.isHidden = true
    }
}
