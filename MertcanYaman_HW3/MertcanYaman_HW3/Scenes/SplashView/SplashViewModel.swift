//
//  SplashViewModel.swift
//  MertcanYaman_HW3
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import Foundation
import DictionaryAPI

protocol SplashViewModelDelegate: AnyObject {
    func hideLoading()
    func hideContentView()
    func showContentView()
    func goHomePage()
    func goBackPage()
}

protocol SplashViewModelProtocol {
    var delegate: SplashViewModelDelegate? { get set }
    
    func checkConnection(_ time: Double)
}

final class SplashViewModel {
    
    weak var delegate: SplashViewModelDelegate?
    
    private func checkInternet(_ time: Double) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            self.delegate?.hideLoading()
            if ReachabilityService.isConnectedToInternet() {
                if IsFirstScreen.shared.isFirst {
                    IsFirstScreen.shared.setIsFirst()
                    self.delegate?.goHomePage()
                }else {
                    self.delegate?.goBackPage()
                }
            }else {
                self.delegate?.showContentView()
            }
        }
    }
}

extension SplashViewModel: SplashViewModelProtocol {
    
    func checkConnection(_ time: Double) {
        self.checkInternet(time)
    }
}
