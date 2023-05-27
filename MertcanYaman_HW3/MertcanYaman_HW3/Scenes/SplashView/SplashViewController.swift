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
        checkInternet(0)
    }
    
    @IBAction func tryBtnClicked(_ sender: Any) {
        checkInternet(0.5)
    }
    
    func showContentView() {
        self.contentView.isHidden = false
    }
    
    private func checkInternet(_ time: Double) {
        showLoading()
        showContentView()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            if self.splashViewModel.checkConnection() {
                let sendVC = UIStoryboard(name: "HomeView", bundle: nil)
                    .instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                sendVC.modalPresentationStyle = .fullScreen
                sendVC.modalTransitionStyle = .coverVertical
                self.present(sendVC, animated: true, completion: nil)
            }
        }
    }
}

extension SplashViewController: SplashViewModelDelegate {
    func hideContentView() {
        self.contentView.isHidden = true
    }
}
