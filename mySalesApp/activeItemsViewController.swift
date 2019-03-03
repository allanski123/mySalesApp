//
//  activeItemsViewController.swift
//  mySalesApp
//
//  Created by allanski on 1/3/19.
//  Copyright © 2019 allanski. All rights reserved.
//

import UIKit
import RealmSwift
import OpalImagePicker
import Photos
import SDWebImage

struct CellData {
    let image: UIImage?
    let message: String?
}

class activeItemsViewController: UITableViewController {
    
    var data = [CellData]()
    
    @IBAction func showItems(_ sender: Any) {
        getActiveItems()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getActiveItems()
    }
    
    // only use for debugging
    // never use on real dataset
    func clearDatabase() {
        let realm = try! Realm()
        try! realm.write() {
            realm.deleteAll()
        }
    }
    
    func getActiveItems() {
        PHImageManager.default()
        data.removeAll()
        
        let realm = try! Realm()
        let results = realm.objects(Item.self).filter("soldDate == nil")
        
        for result in results {
            let title = result.title
            let about = result.about
            let purchasePrice = result.purchasePrice.value
            let category = result.category
            let images = result.images
            
            if FileManager.default.fileExists(atPath: images[0]) {
                let imageUrl: URL = URL(fileURLWithPath: images[0])
                let imageData: Data = try! Data(contentsOf: imageUrl)
                let imageToShow: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale)!
                
                data.append(CellData.init(image: imageToShow, message: title))
            }
        }
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        
        cell.mainImage = data[indexPath.row].image
        cell.message = data[indexPath.row].message
        cell.layoutSubviews()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

}

