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
}

protocol SplashViewModelProtocol {
    var delegate: SplashViewModelDelegate? { get set }
    
    func checkConnection() -> Bool
}

final class SplashViewModel {
    
    weak var delegate: SplashViewModelDelegate?
    
    func checkInternetConnection() -> Bool {
        ReachabilityService.isConnectedToInternet()
    }
}

extension SplashViewModel: SplashViewModelProtocol {
    
    func checkConnection() -> Bool {
        if self.checkInternetConnection() {
            delegate?.hideContentView()
            delegate?.hideLoading()
            return true
        }else {
            delegate?.hideLoading()
            return false
        }
        
    }
}
