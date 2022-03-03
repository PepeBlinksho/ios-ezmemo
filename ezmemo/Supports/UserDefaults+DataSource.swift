//
//  UserDefaults+DataSource.swift
//  ezmemo
//
//  Created by kgo on 2021/12/22.
//

import Foundation

extension UserDefaults {
    public static let AppGroup = "group.jp.fourmix.dev.ezmemo"
    
    static let dataSource = { () -> UserDefaults in
        guard let dataSource = UserDefaults(suiteName: AppGroup) else {
            fatalError("UserDefaultsが作成できません。IDまたは証明書を確認してください。")
        }
    
        return dataSource
    }
    
    enum EZKeys: String {
        case accessToken = "ezmemo_access_token"
        case refreshToken = "ezmemo_refresh_token"
        case expiresIn = "ezmemo_expires_in"
        case tokenType = "ezmemo_token_type"
    }
    
    func set(_ value: Any?, ezkey: EZKeys) {
        self.set(value, forKey: ezkey.rawValue)
    }
    
    func getString(ezkey: EZKeys) -> String? {
        return self.string(forKey: ezkey.rawValue)
    }
    
    func getInt(ezkey: EZKeys) -> Int {
        return self.integer(forKey: ezkey.rawValue)
    }
}
