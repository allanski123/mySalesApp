//
//  Extensions.swift
//  mySalesApp
//
//  Created by allanski on 7/3/19.
//  Copyright © 2019 allanski. All rights reserved.
//

import UIKit

// https://stackoverflow.com/questions/28332946/how-do-i-get-the-current-date-in-short-format-in-swift
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension UIImage {
    func getCropRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }
}
