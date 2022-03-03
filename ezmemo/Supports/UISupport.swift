//
//  UISupport.swift
//  ezmemo
//
//  Created by kgo on 2021/12/17.
//

import UIKit
import Moya

struct UITheme {
    static let accentColor: UIColor = UIColor(named: "AccentColor")!
    static let bgColor: UIColor = UIColor(named: "BgColor")!
    static let secondaryColor: UIColor = UIColor(named: "SecondaryColor")!
    static let borderWidth: CGFloat = 1.0
    
    static func universalPlaceholder(named: String) -> NSAttributedString {
        return NSAttributedString(string: named,
                                  attributes: [
                                    NSAttributedString.Key.foregroundColor: UIColor(named: "SecondaryColor")!
                                  ])
    }
}

extension UIImageView {
    func loadFromURL(url: URL) {
        let provider  = MoyaProvider<WebAccessService>()
        provider.request(.load(url: url)) { result in
            switch result {
                case let .success(moyaResponse):
                    do {
                        _ = try moyaResponse.filterSuccessfulStatusCodes()
                        let data = moyaResponse.data
                        let uiImage = UIImage(data: data)
                        
                        if let uiImage = uiImage {
                            uiImage.saveToCache(url: url)
                        }
                        
                        self.image = uiImage
                    }
                    catch {
                        print("Error: ", error)
                        // NO IMAGE
                    }
                case let .failure(error):
                    print(error)
                // NO IMAGE
                }
        }
    }
}

extension UIImage {
    func saveToCache(url: URL) {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let urlString = url.description.replacingOccurrences(of: "/", with: "*")
        let archiveURL = cacheDirectory.appendingPathComponent("images").appendingPathComponent(urlString)
        print(archiveURL)
        let imageData = self.jpegData(compressionQuality: 1.0)!
        try! imageData.write(to: archiveURL)
        print("保存しました", archiveURL)
    }
    
    static func loadFromCache(url: URL) -> UIImage? {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let urlString = url.description.replacingOccurrences(of: "/", with: "*")
        let archiveURL = cacheDirectory.appendingPathComponent("images").appendingPathComponent(urlString)
        do {
            let data = try Data(contentsOf: archiveURL)
            return UIImage(data: data)
        }
        catch {
            return nil
        }
    }
}

