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
    var titles = [String]()
    var descripts = [String]()
    var aspectRatios = [CGFloat]()
    
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
        
        data.removeAll()
        titles.removeAll()
        descripts.removeAll()
        
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
                
                titles.append(title!)
                data.append(imageUrl)
                descripts.append(about!)
                aspectRatios.append(imageToShow.getCropRatio())
                
            }
        }
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "splash"),
            transition: .fadeIn(duration: 0.5)
        )
        
        let scaledWidth = 64 * UIScreen.main.scale
        let scaledHeight = scaledWidth / aspectRatios[indexPath.row]
        
        let request = ImageRequest(
            url: data[indexPath.row],
            targetSize: CGSize(width: scaledWidth, height: scaledHeight),
            contentMode: .aspectFit)
        
        Nuke.loadImage(with: request, options: options, into: cell.itemImageView)
        cell.itemTitleLabel.text = titles[indexPath.row]
        cell.itemDescLabel.text = descripts[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

}

extension UIImage {
    func getCropRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }
}
