//
//  Item.swift
//  mySalesApp
//
//  Created by allanski on 28/2/19.
//  Copyright © 2019 allanski. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var uuid: String?
    @objc dynamic var title: String?
    @objc dynamic var about: String?
    @objc dynamic var category: String?
    @objc dynamic var purchasedDate: Date?
    @objc dynamic var soldDate: Date?
    let purchasePrice = RealmOptional<Double>()
    let soldPrice = RealmOptional<Double>()
    let images = List<String>()
    
}
