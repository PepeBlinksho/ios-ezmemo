//
//  Memo.swift
//  ezmemo
//
//  Created by kgo on 2021/12/29.
//

import UIKit
import Moya

struct MemoCollection: Codable {
    var memos: [Memo]
    var links: Links
    var meta: Meta
    
    func saveToCache() {
        let coder = JSONEncoder()
        let memoCollectionJosn = try! coder.encode(self)
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let archiveURL = cacheDirectory.appendingPathComponent("MemoCollectionCache").appendingPathExtension("json")
        try! memoCollectionJosn.write(to: archiveURL)
        print("保存しました：" ,archiveURL)
    }
    
    static func loadFromCache() -> MemoCollection? {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let archiveURL = cacheDirectory.appendingPathComponent("MemoCollectionCache").appendingPathExtension("json")
        do {
            let data = try Data(contentsOf: archiveURL)
            let coder = JSONDecoder()
            let memoCollection = try coder.decode(MemoCollection.self, from: data)
            return memoCollection
        } catch {
            return nil
        }
    }
    
    static func loadData(callback: @escaping (MemoCollection?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let provider = MoyaProvider<WebApiService>()
        provider.request(.memoList) { result in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
                case let .success(moyaResponse):
                    do {
                        _ = try moyaResponse.filterSuccessfulStatusCodes()
                        let data = moyaResponse.data
                        let coder = JSONDecoder()
                        let memoCollection = try coder.decode(MemoCollection.self, from: data)
                        callback(memoCollection)
                    }
                    catch {
                        print("Error: ", error)
                        NotificationCenter.default.post(name: LocalNotificationService.getMemoListError, object: nil, userInfo: [
                            "message": "メモリスト取得できません。"
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
    
    enum CodingKeys: String, CodingKey {
        case memos = "data"
        case links
        case meta
    }
    
    struct Memo: Codable {
        var id: String
        var type: String
        var attributes: Attributes
        var relationships: Relationships
        var links: Links
        
        struct Attributes: Codable {
            var title: String
            var contents: String?
            var userId: Int?
            var folderId: Int?
            var isPublic: Bool
            var isArchive: Bool
            var createdAtHumans: String
            var createdAt: String
            var updatedAt: String
            
            enum CodingKeys: String, CodingKey {
                case title
                case contents
                case userId = "user_id"
                case folderId = "folder_id"
                case isPublic = "is_public"
                case isArchive = "is_archive"
                case createdAtHumans = "created_at_humans"
                case createdAt = "created_at"
                case updatedAt = "updated_at"
            }
        }
        
        struct Relationships: Codable {
            var key: String
        }
        
        struct Links: Codable {
            var url: URL
        }
    }
    
    struct Links: Codable {
        var first: URL
        var last: URL?
        var prev: URL?
        var next: URL?
    }
    
    struct Meta: Codable {
        var currentPage: Int
        var from: Int
        var path: URL
        var perPage: Int
        var to: Int
        
        enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case from
            case path
            case perPage = "per_page"
            case to
        }
    }
}
