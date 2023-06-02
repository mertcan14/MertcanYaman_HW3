//
//  SplashViewController.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import UIKit

final class SplashViewController: UIViewController, LoadingShowable {
    // MARK: - Variable Definitions
    var splashViewModel: SplashViewModelProtocol! {
        didSet {
            splashViewModel.delegate = self
        }
    }
    
    // MARK: - IBOutlet Definitions
    @IBOutlet weak var contentView: UIStackView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        splashViewModel = SplashViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        splashViewModel.checkConnection(0)
    }
    
    // MARK: - Lifecycle Methods
    @IBAction func tryBtnClicked(_ sender: Any) {
        showLoading()
        splashViewModel.checkConnection(0.5)
    }
}

// MARK: - Extension SplashViewModelDelegate
extension SplashViewController: SplashViewModelDelegate {
    func goBackPage() {
        dismiss(animated: true)
    }
    
    func showContentView() {
        self.contentView.isHidden = false
    }
    
    func hideContentView() {
        self.contentView.isHidden = true
    }
    
    func goHomePage() {
        let sendVC = UIStoryboard(name: "HomeView", bundle: nil)
            .instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        sendVC.modalPresentationStyle = .fullScreen
        sendVC.modalTransitionStyle = .coverVertical
        self.present(sendVC, animated: true, completion: nil)
    }
}
