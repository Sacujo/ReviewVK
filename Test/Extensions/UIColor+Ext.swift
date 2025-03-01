//
//  UIColor+Ext.swift
//  Test
//
//  Created by Igor Guryan on 01.03.2025.
//
import UIKit

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
