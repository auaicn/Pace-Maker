//
//  UnderlineLabel.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/06/07.
//

import Foundation
import UIKit

class UnderlinedLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSRange(location: 0, length: text.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: textRange)
            // Add other attributes if needed
            self.attributedText = attributedText
        }
    }
}
