//
//  AuthToken.swift
//  ezmemo
//
//  Created by kgo on 2021/12/20.
//

import UIKit
import Moya

struct AuthToken: Codable {
    var tokenType: String
    var expiresIn: Int
    var accessToken: String
    var refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
    
    static func login(email username: String, password: String, callback: @escaping (AuthToken?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let provider = MoyaProvider<AuthService>()
        provider.request(.login(username: username, password: password)) { result in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
                case let .success(moyaResponse):
                    do {
                        _ = try moyaResponse.filterSuccessfulStatusCodes()
                        let data = moyaResponse.data
                        let coder = JSONDecoder()
                        let authToken = try coder.decode(AuthToken.self, from: data)
                        authToken.save()
                        callback(authToken)
                    }
                    catch {
                        print("Error: ", error)
                        NotificationCenter.default.post(name: LocalNotificationService.authError, object: nil, userInfo: [
                            "message": "ログインできません。"
                        ])
                        callback(nil)
                    }
                case let .failure(error):
                    print(error)
                    NotificationCenter.default.post(name: LocalNotificationService.networkError, object: nil, userInfo: [
                        "message": "サーバーに接続ができません。"
                    ])
                    callback(nil)
                }
        }
    }
    
    func save() {
        UserDefaults.dataSource().set(tokenType, ezkey: .tokenType)
        UserDefaults.dataSource().set(expiresIn, ezkey: .expiresIn)
        UserDefaults.dataSource().set(accessToken, ezkey: .accessToken)
        UserDefaults.dataSource().set(refreshToken, ezkey: .refreshToken)
    }
    
    func toAuthorizationHeader() -> String {
        return "\(tokenType) \(accessToken)"
    }
    
    static func load() -> AuthToken? {
        guard let tokenType = UserDefaults.dataSource().getString(ezkey: .tokenType), let accessToken = UserDefaults.dataSource().getString(ezkey: .accessToken), let refreshToken = UserDefaults.dataSource().getString(ezkey: .refreshToken) else {
            return nil
        }
        
        let expiresIn = UserDefaults.dataSource().getInt(ezkey: .expiresIn)
        
        let authToken = AuthToken(tokenType: tokenType, expiresIn: expiresIn, accessToken: accessToken, refreshToken: refreshToken)
        
        return authToken
    }
}
