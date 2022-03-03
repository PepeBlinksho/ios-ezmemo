//
//  LocalNotificationService.swift
//  ezmemo
//
//  Created by kgo on 2021/12/22.
//

import UIKit

struct LocalNotificationService {
    static let networkError = Notification.Name("networkError")
    static let authError = Notification.Name("authError")
    static let getMemoListError = Notification.Name("getMemoListError")
}
