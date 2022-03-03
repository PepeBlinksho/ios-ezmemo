//
//  Helpers.swift
//  ezmemo
//
//  Created by kgo on 2022/01/24.
//

import UIKit

extension Date {
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let dateString = formatter.string(from: self)
        
        return dateString
    }
}
