//
//  DateFormatter+Static.swift
//  Pods
//
//  Created by Rod Brown on 19/5/17.
//
//

import Foundation

extension DateFormatter {
    
    public static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
}
