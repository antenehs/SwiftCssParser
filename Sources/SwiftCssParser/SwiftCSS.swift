//
//  SwiftCSS.swift
//  SwiftCssParser
//
//  Created by Mango on 2017/6/3.
//  Copyright © 2017年 Mango. All rights reserved.
//

import SwiftUI

public class SwiftCSS {
    
    private let parsedCss: [String:[String:Any]]
    
    public init(CssFileURL: URL) {
        let content = try! String(contentsOf: CssFileURL, encoding: .utf8)
        let lexer = CssLexer(input: content)
        let parser = CssParser(lexer: lexer)
        parser.parse()
        parsedCss = parser.outputDic
    }
    
    
    public func int(selector: String, key: String) -> Int {
        
        return Int(double(selector: selector, key: key))
    }
    
    public func double(selector: String, key: String) -> Double {
        return value(selector: selector, key: key) ?? 0
    }
    
    public func string(selector: String, key: String) -> String {
        return value(selector: selector, key: key) ?? ""
    }
    
    public func size(selector: String, key: String) -> CGSize {
        
        guard let dic: [String:Double] = value(selector: selector, key: key),
            let double1 = dic["double1"], let double2 = dic["double2"] else {
            return CGSize(width: 0, height: 0)
        }
        
        return CGSize(width: double1, height: double2)
        
    }
    
    
    public func color(selector: String, key: String) -> Color {
        
        if let rgb:(Double,Double,Double,Double) = value(selector: selector, key: key) {
//            return Color(red: CGFloat(rgb.0/255), green: CGFloat(rgb.1/255), blue: CGFloat(rgb.2/255), alpha: CGFloat(rgb.3))
            return Color(red: CGFloat(rgb.0/255), green: CGFloat(rgb.1/255), blue: CGFloat(rgb.2/255), opacity: Double(rgb.3))
        } else {
//            return Color(string(selector: selector, key: key))
            return Color(hex: string(selector: selector, key: key))
        }
        
    }
    
    public func font(selector: String, key: String, fontSize: CGFloat = 14) -> Font {
        let defaultReturnValue = Font.system(size: fontSize)
        
        if let name: String = value(selector: selector, key: key) {
            return Font.custom(name, size: fontSize)
        } else if let dic: [String:Any] = value(selector: selector, key: key) {
            guard let name = dic["name"] as? String, let size = dic["size"] as? Double else {
                return defaultReturnValue
            }
            return Font.custom(name, size: size)
        } else {
            return defaultReturnValue
        }
    }
    
    private func value<T>(selector: String, key: String) -> T? {
        guard let dic = parsedCss[selector] else {
            return nil
        }
        guard let value = dic[key] as? T else {
            return nil
        }
        
        return value
    }
    
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
