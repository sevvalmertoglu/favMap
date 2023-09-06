//
//  Localization.swift
//  favMap
//
//  Created by Şevval Mertoğlu on 11.08.2023.
//

import Foundation

class Localizer {
    static func localize(_ key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
}
