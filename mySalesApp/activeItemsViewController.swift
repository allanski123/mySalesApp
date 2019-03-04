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
    
    var data = [URL]()
    var info = [String]()
    
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
                //let imageData: Data = try! Data(contentsOf: imageUrl)
                //let imageToShow: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale)!
                
                info.append(title!)
                data.append(imageUrl)
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let imageView = cell?.viewWithTag(1) as! UIImageView
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let textView = cell?.viewWithTag(2) as! UITextField
        textView.text = info[indexPath.row]
        
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "splash"),
            transition: .fadeIn(duration: 0.5)
        )
        
        let request = ImageRequest(
            url: data[indexPath.row],
            targetSize: CGSize(width: 100, height: 100),
            contentMode: .aspectFill)
        
        Nuke.loadImage(with: request, options: options, into: imageView)
        
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

}

