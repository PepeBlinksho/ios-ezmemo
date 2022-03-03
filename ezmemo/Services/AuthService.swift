//
//  AuthService.swift.swift
//  ezmemo
//
//  Created by kgo on 2021/12/20.
//

import UIKit
import Moya

let clientId: Int = 2
let clientSecret: String = "KRWn0eMyachoOxmsa3WDC1y3mMNdwo0JkCjAAq7a"

enum AuthService {
    case login(username: String, password: String)
}

extension AuthService: TargetType {
    
    var baseURL: URL { URL(string: "http://192.168.86.23")! }
    
    var path: String {
        switch self {
        case .login:
            return "/oauth/token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .login(let username, let password):
            return .requestParameters(parameters: [
                "grant_type": "password",
                "client_id": clientId,
                "client_secret": clientSecret,
                "username": username,
                "password": password,
                "scope": ""
            ], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Accept": "application/json"]
    }
    
    var sampleData: Data {
        return "Half measures are as bad as nothing at all.".utf8Encoded
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data { Data(self.utf8) }
}
