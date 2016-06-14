//
//  LocalizedNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/31/15.
//
//

import Foundation

import Foundation

internal struct LocalizedNumberExtractor: TokenExtractor {
    
    private let decimalNumberFormatter = NumberFormatter()
    
    internal init(locale: Locale) {
        decimalNumberFormatter.locale = locale
        decimalNumberFormatter.numberStyle = .decimal
    }
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        return buffer.peekNext() != nil
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> TokenGenerator.Element {
        let start = buffer.currentIndex
        var indexBeforeDecimal: Int?
        
        var soFar = ""
        while let peek = buffer.peekNext() where peek.isWhitespace == false {
            let test = soFar + String(peek)
            
            if indexBeforeDecimal == nil && test.hasSuffix(decimalNumberFormatter.decimalSeparator) {
                indexBeforeDecimal = buffer.currentIndex
            }
            
            if canParseString(test) {
                soFar = test
                buffer.consume()
            } else {
                break
            }
        }
        
        if let indexBeforeDecimal = indexBeforeDecimal where soFar.hasSuffix(decimalNumberFormatter.decimalSeparator) {
            buffer.resetTo(indexBeforeDecimal)
            soFar = buffer[start ..< indexBeforeDecimal]
        }
        
        let indexAfterNumber = buffer.currentIndex
        let range: Range<Int> = start ..< indexAfterNumber
        
        guard indexAfterNumber - start > 0 else {
            let error = MathParserError(kind: .cannotParseNumber, range: range)
            return .Error(error)
        }
        
        let token = RawToken(kind: .localizedNumber, string: soFar, range: range)
        return .Value(token)
    }
    
    private func canParseString(_ string: String) -> Bool {
        guard let _ = decimalNumberFormatter.number(from: string) else { return false }
        return true
    }

}
