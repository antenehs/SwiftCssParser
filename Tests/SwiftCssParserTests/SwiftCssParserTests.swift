//
//  SwiftCssParserTests.swift
//  SwiftCssParserTests
//
//  Created by Mango on 2017/6/3.
//  Copyright © 2017年 Mango. All rights reserved.
//

import SwiftUI
import XCTest
@testable import SwiftCssParser

class SwiftCssParserTests: XCTestCase {
    lazy var testCSS: SwiftCSS = {
        let cssPath = Bundle.module.url(forResource: "tests", withExtension: "css")
        return SwiftCSS(CssFileURL: cssPath!)
    }()
    
    lazy var testCSSString: String = {
        let cssPath = Bundle.module.url(forResource: "tests", withExtension: "css")
        var text = ""
        do {
            text = try String(contentsOf: cssPath!)
        } catch {}
        return text
    }()
    
    //MARK: - SPECIALIZED
    func testSpecialKey() {
        var divisions: [String] = []
        divisions = testCSSString.components(separatedBy: ";")
        print(divisions)
        
        var loop = 0
        var index: Int?
        
        for component in divisions {
            if component.contains("width") {
                index = loop
                break
            } else {
                loop += 1
            }
        }
        
        XCTAssertTrue(index == 0)
    }
    
    //MARK: - TYPES
    func testInt() {
        let width = testCSS.int(selector: "#View", key: "width")
        XCTAssertTrue(width == 118, "get width")
    }
    
    func testParseDouble() {
        let height = testCSS.double(selector: "#View", key: "height")
        XCTAssertTrue(height == 120.5, "get height")
    }
    
    func testColor() {
        let color1 = testCSS.color(selector: "#View", key: "color1")
        print("Color is \(color1)")
        XCTAssertTrue(color1 == Color(hex: "#888888"), "get color")
        
        let color2 = testCSS.color(selector: "#View", key: "color2")
        XCTAssertTrue(color2 == Color(red: 200/255, green: 200/255, blue: 200/255, opacity: 1), "get color")
        
        let color3 = testCSS.color(selector: "#View", key: "color3")
        XCTAssertTrue(color3 == Color(red: 200/255, green: 200/255, blue: 200/255, opacity: 0.5), "get color")
    }
    
    func testFont() {
        let font1  = testCSS.font(selector: "#View", key: "font1")
        let font1test = Font.custom("Helvetica-Bold", size: 18)
        XCTAssertTrue(font1 == font1test , "get font")
        
        let font2 = testCSS.font(selector: "#View", key: "font2", fontSize: 14)
        let font2test = Font.custom("Cochin", size: 14)
        XCTAssertTrue(font2 == font2test, "get font")
    }
    
    func testSize() {
        let size = testCSS.size(selector: "#View", key: "size")
        XCTAssertTrue(size == CGSize(width: 10, height: 10) )
    }
}
