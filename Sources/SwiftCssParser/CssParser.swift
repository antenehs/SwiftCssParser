//
//  CssParser.swift
//  SwiftCssParser
//
//  Created by Mango on 2017/6/3.
//  Copyright © 2017年 Mango. All rights reserved.
//

import Foundation

public class CssParser {
    let lexer: CssLexer
    lazy var lookaheads: [Token?] = Array(repeating: nil, count: self.k)
    let k = 6 //LL(6)
    var index = 0 //circular index of next token position to fill
    typealias Token = CssLexer.Token
    
    public var outputDic = [String:[String:Any]]()
    
    public init(lexer: CssLexer) throws {
        self.lexer = lexer
        
        for _ in 1...k {
            try consume()
        }
    }
    
    private var consumedToken = [Token]()
    func consume() throws {
        
        lookaheads[index] = try lexer.nextToken()
        index = (index + 1) % k
        
        //for debug
        if let token =  lookaheads[index] {
            consumedToken.append(token)
        }
    }
    
    // form 1 to k
    func lookaheadToken(_ index: Int) -> Token? {
        let circularIndex = (self.index + index - 1) % k
        return lookaheads[circularIndex]
    }
    
    @discardableResult func match(token: Token) throws -> Token {
        
        guard let lookaheadToken = lookaheadToken(1) else {
            fatalError("lookahead token is nil")
        }
        guard lookaheadToken.type == token.type else {
            fatalError("expecting (\(token.type)) but found (\(lookaheadToken) consumedTokens: \(consumedToken))")
        }
        try consume()
        return lookaheadToken
    }
    
}

//MARK: Rules
extension CssParser {
    
    func element(selector: String ) throws {
        
        guard var selectorDic = outputDic[selector] else {
            fatalError("\(selector) dic not found")
        }
        
        let key = try match(token: .string(""))
        try match(token: .colon)
        
        guard let currentToken = lookaheadToken(1) else {
            fatalError("lookahead token is nil")
        }
        
        switch currentToken {
        case let .double(value):
            
            guard let token2 = lookaheadToken(2) else {
                fatalError("token2 is nil")
            }
            switch token2 {
            case let .double(double):
                // key : double double;
                try match(token: currentToken)
                try match(token: token2)
                selectorDic[key.description] = ["double1":value,"double2":double]
            default:
                // normal double
                try match(token: currentToken)
                selectorDic[key.description] = value
            }
        
        case let .string(value):
            //LL(2)
            guard let token2 = lookaheadToken(2) else {
                fatalError("token2 is nil")
            }
            
            switch token2 {
            case let .double(double):
                //key : name double
                try match(token: currentToken)
                try match(token: token2)
                selectorDic[key.description] = ["name":value,"size":double]
            default:
                //normal string
                try match(token: currentToken)
                selectorDic[key.description] = value
            }
        case let .rgb(r,g,b,a):
            try match(token: currentToken)
            selectorDic[key.description] = (r,g,b,a)
        default:
            break
        }
        
        outputDic[selector] = selectorDic
    }
    
    func elements(selector: String) throws {
        try element(selector: selector)
        while let lookaheadToken = lookaheadToken(1), lookaheadToken.type ==
                Token.semicolon.type {
            try match(token: .semicolon)
            
            //if current token is "}", it means elements rule is parsed.
            if let currentToken = self.lookaheadToken(1), currentToken.type == Token.rightBrace.type {
                return
            }
            
            try element(selector: selector)
        }
    }
    
    func selector() throws {
        let selector = try match(token: .selector(""))
        let dic = [String:Int]()
        outputDic[selector.description] = dic
        
        try match(token: .leftBrace)
        try elements(selector: selector.description)
        try match(token: .rightBrace)
    }
    
    func css() throws {
        
        while lookaheadToken(1) != nil {
            try selector()
        }
    }
    
    public func parse() throws {
        try css()
    }
    
}
