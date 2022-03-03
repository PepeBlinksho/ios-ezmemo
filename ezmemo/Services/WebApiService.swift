//
//  WebApiService.swift
//  ezmemo
//
//  Created by kgo on 2021/12/29.
//

import Foundation
import Moya

enum WebApiService {
    case memoList
    case uploadImage(image: UIImage)
}

extension WebApiService: TargetType {
    
    var baseURL: URL { URL(string: "http://192.168.86.23/api")! }
    
    var path: String {
        switch self {
        case .memoList:
            return "/v1/user/memos/list"
        case .uploadImage:
            return "/v1/upload"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .memoList:
            return .get
        case .uploadImage:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .memoList:
            return .requestPlain
        case .uploadImage(let image):
            let imageData = image.jpegData(compressionQuality: 1.0)!
            return .uploadMultipart([
                MultipartFormData(provider: .data(imageData), name: "file", fileName: "icon.jpg", mimeType: "image/jpg")
            ])
        }
    }
    
    var headers: [String : String]? {
        return [
            "Accept": "application/json",
            "Authorization": AuthToken.load()!.toAuthorizationHeader()
        ]
    }
    
    var sampleData: Data {
        return "Half measures are as bad as nothing at all.".utf8Encoded
    }
}

enum WebAccessService {
    case load(url: URL)
}

extension WebAccessService: TargetType {
    var baseURL: URL {
        switch self {
        case .load(let url):
            return url
        }
    }
    
    var path: String { return "" }
    var method: Moya.Method { return .get }
    var task: Task { return .requestPlain }
    
    var headers: [String : String]? {
        return [
            "Accept": "application/json",
//            "Authorization": AuthToken.load()!.toAuthorizationHeader()
        ]
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
