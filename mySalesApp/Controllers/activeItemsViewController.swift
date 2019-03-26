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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let realm = try! Realm()
        let uuid = "uuid == '" + "3A623C32-C1EF-400B-9D4C-7819606B430F" + "'"
        let results = realm.objects(Item.self).filter(uuid).first
        
        try! realm.write() {
            realm.delete(results!)
        }
        */
        
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
        var sum = 0.0
        
        PHImageManager.default()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        uuids.removeAll()
        
        let realm = try! Realm()
        let results = realm.objects(Item.self).sorted(byKeyPath: "soldDate", ascending: true)
        
        for result in results {
            let uuid = result.uuid
            uuids.append(uuid!)
            sum += (result.soldPrice.value! - result.purchasePrice.value!)
        }
        
        navigationItem.leftBarButtonItem?.title = "$\(sum)";
        if sum < 0.0 {
            navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        }
        else {
            navigationItem.leftBarButtonItem?.tintColor = UIColor.green
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
        
        if let purchasePrice = results?.purchasePrice.value, let soldPrice = results?.soldPrice.value {
            if soldPrice == 0 {
                cell.itemPriceLabel.text = "$\(purchasePrice)"
                cell.itemPriceLabel.textColor = UIColor.red
            }
            else {
                cell.itemPriceLabel.text = "$\(soldPrice - purchasePrice)"
                cell.itemPriceLabel.textColor = UIColor.green
            }
        }
        
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
            getActiveItems()
        }
    }
    
    var selectedItem: String?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = uuids[indexPath.row]
        performSegue(withIdentifier: "editItemSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editItemSegue" {
            let vc = segue.destination as! createItemViewController
            
            let realm = try! Realm()
            let uuid = "uuid == '" + selectedItem! + "'"
            let results = realm.objects(Item.self).filter(uuid).first
            
            let url = URL(fileURLWithPath: (results?.images[0])!)
            vc.editItemUrl = url
            vc.editTitle = results?.title
            if let pp = results?.purchasePrice.value, let sp = results?.soldPrice.value {
                vc.editBuyPrice = "\(pp)"
                vc.editSellPrice = "\(sp)"
            }
            vc.editTagTextbox = results?.category
            vc.editAboutItem = results?.about
            vc.editUUID = selectedItem!
        }
    }
}
