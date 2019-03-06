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
import Nuke

class activeItemsViewController: UITableViewController {
    
    var uuids = [String]()
    
    /*
     @IBAction func showItems(_ sender: Any) {
     getActiveItems()
     tableView.reloadData()
     }
     */
    
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
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        navigationItem.rightBarButtonItem = editButtonItem
        
        uuids.removeAll()
        
        let realm = try! Realm()
        let results = realm.objects(Item.self).filter("soldDate == nil")
        
        for result in results {
            let uuid = result.uuid
            uuids.append(uuid!)
        }
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let realm = try! Realm()
        let uuid = "uuid == '" + uuids[indexPath.row] + "'"
        let results = realm.objects(Item.self).filter(uuid).first
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "splash"),
            transition: .fadeIn(duration: 0.5)
        )
        
        if results == nil {
            return UITableViewCell()
        }
        
        let imageUrl: URL = URL(fileURLWithPath: (results?.images[0])!)
        let imageData: Data = try! Data(contentsOf: imageUrl)
        let imageToShow: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale)!
        
        let imageCrop = imageToShow.getCropRatio()
        let scaledWidth = 64 * UIScreen.main.scale
        let scaledHeight = scaledWidth / imageCrop
        
        let request = ImageRequest(
            url: imageUrl,
            targetSize: CGSize(width: scaledWidth, height: scaledHeight),
            contentMode: .aspectFit)
        
        Nuke.loadImage(with: request, options: options, into: cell.itemImageView)
        cell.itemTitleLabel.text = results?.title
        cell.itemDescLabel.text = results?.about
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uuids.count
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let realm = try! Realm()
            let uuid = "uuid == '" + uuids[indexPath.row] + "'"
            let object = realm.objects(Item.self).filter(uuid).first
            
            try! realm.write {
                realm.delete(object!)
            }
            
            uuids.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
    }
    
}

extension UIImage {
    func getCropRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }
}
