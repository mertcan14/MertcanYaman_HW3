//
//  ReachabilityService.swift
//
//
//  Created by mertcan YAMAN on 27.05.2023.
//

import Foundation
import Alamofire

public class ReachabilityService {
    public class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
