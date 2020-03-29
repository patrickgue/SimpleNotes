//
//  MDTextView.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 21.02.20.
//  Copyright © 2020 Patrick Günthard. All rights reserved.
//

import Cocoa

class MDTextView: NSTextView {
    override func didChangeText() {
        super.didChangeText()
        setHighlight()
    }
    
    func setHighlight() {
        let fullRange = NSRange(location: 0, length: self.textStorage!.length)
        for paragraph in self.textStorage!.paragraphs {
            let paragraphRange = NSRange(location: 0, length: paragraph.length)
            if paragraph.string.hasPrefix("# ") {
                paragraph.addAttributes([.foregroundColor:NSColor.selectedContentBackgroundColor, .font:NSFont.systemFont(ofSize: 24, weight: NSFont.Weight.black)], range: paragraphRange)
            }
            else if paragraph.string.hasPrefix("## ") {
                paragraph.addAttributes([.font:NSFont.systemFont(ofSize: 20, weight: NSFont.Weight.black)], range: paragraphRange)
            }
            else if paragraph.string.hasPrefix("### ") {
                paragraph.addAttributes([.font:NSFont.systemFont(ofSize: 16, weight: NSFont.Weight.bold)], range: paragraphRange)
            }
            else if paragraph.string.hasPrefix("#### ") {
                paragraph.addAttributes([.font:NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.bold)], range: paragraphRange)
            }
            
            /*let italicsPattern = try? NSRegularExpression(pattern: " \\*[A-z0-9,.:; !-=\"'<>{}]*\\*[^\\*]", options: .useUnixLineSeparators)
            let boldPattern = try? NSRegularExpression(pattern: "\\*\\*[A-z0-9,.:; !-=\"'<>{}]*\\*\\*", options: .useUnixLineSeparators)
                        
            for match:NSTextCheckingResult in (boldPattern?.matches(in: paragraph.string, options: .withoutAnchoringBounds, range: paragraphRange))! {
                            
                if let font = paragraph.font {
                    
                    NSFontManager.shared.convertWeight(true, of: font)
                    paragraph.addAttributes([.font:  NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask) ], range: match.range)
                }
            }
                        
            for match:NSTextCheckingResult in (italicsPattern?.matches(in: textView.textStorage!.string, options: .withoutAnchoringBounds, range: fullRange))! {
                textView.textStorage!.addAttributes([NSAttributedString.Key.obliqueness:0.2], range: match.range)
            }
            */
        }
    }
    
    func resetHighliting() {
        self.textStorage?.setAttributes([.foregroundColor:NSColor.textColor], range: NSRange(location: 0, length: self.textStorage!.length))
    }

}
