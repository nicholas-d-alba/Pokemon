//
//  Utility.swift
//  PokeDex
//
//  Created by Nicholas Alba on 6/22/21.
//

import Foundation

extension String {
    
    // Returns the current value of the string, but with the first
    // letter capitalized and the remaining characters in lower case.
    func asTitle() -> String {
        if self.count == 0 {
            return ""
        }
        let titleString = self.lowercased()
        let firstCharacter = titleString.first!.uppercased()
        return firstCharacter + titleString[titleString.index(after: titleString.startIndex)...]
    }
}
