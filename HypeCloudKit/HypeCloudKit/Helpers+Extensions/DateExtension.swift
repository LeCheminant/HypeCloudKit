//
//  DateExtension.swift
//  HypeCloudKit
//
//  Created by Jacob LeCheminant on 2/4/20.
//  Copyright © 2020 Jacob LeCheminant. All rights reserved.
//

import Foundation

extension Date {
    
    func formatToString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
