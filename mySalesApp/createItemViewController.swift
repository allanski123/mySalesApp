//
//  createItemViewController.swift
//
//
//  Created by allanski on 28/2/19.
//

import UIKit
import RealmSwift
import OpalImagePicker
import Photos
import Nuke
import UITextView_Placeholder

class createItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var editUUID: String?
    var editTitle: String?
    var editItemUrl: URL?
    var editBuyPrice: String?
    var editSellPrice: String?
    var editTagTextbox: String?
    var editAboutItem: String?
    
    var currentBox = UITextField()
    var pickerView = UIPickerView()
    
    @IBOutlet weak var adTitle: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var buyPrice: UITextField!
    @IBOutlet weak var sellPrice: UITextField!
    @IBOutlet weak var tagTextbox: UITextField!
    @IBOutlet weak var aboutItem: UITextView!
    @IBOutlet weak var button: UIButton!
    
    
    var imageUrls = [String]()
    
    var tags = [
        "Tools",
        "Furniture",
        "Garden",
        "Appliances",
        "Household",
        "Books, films & music",
        "Video games",
        "Jewellery & Accessories",
        "Bags & luggage",
        "Clothing & shoes - men",
        "Clothing & shoes - women",
        "Toys & games",
        "Baby & kids",
        "Pet supplies",
        "Health & beauty",
        "Mobile phones",
        "Electronics & computers",
        "Sports & outdoors",
        "Musical Instruments",
        "Arts & Crafts",
        "Antiques & collectibles",
        "Car parts",
        "Bicycles",
        "Other"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPage()
    }
    
    func setupPage() {
        self.adTitle.text = editTitle
        self.tagTextbox.text = editTagTextbox
        self.aboutItem.text = editAboutItem
        
        if let info = editItemUrl {
            button.setTitle("Update item details", for: .normal)
            
            let imageData: Data = try! Data(contentsOf: editItemUrl!)
            let imageToShow: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale)!
            
            let options = ImageLoadingOptions(
                placeholder: UIImage(named: "splash"),
                transition: .fadeIn(duration: 0.5)
            )
            
            let request = ImageRequest(
                url: info,
                targetSize: CGSize(width: 351, height: 351 / imageToShow.getCropRatio()),
                contentMode: .aspectFit)
            
            Nuke.loadImage(with: request, options: options, into: itemImageView)
        }
        
        if let info = editBuyPrice {
            self.buyPrice.text = info
        }
        if let info = editSellPrice {
            self.sellPrice.text = info
        }
        
        if editItemUrl == nil {
            itemImageView.image = UIImage(named: "placeholder")
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(tapGestureRecognizer)
 
        aboutItem.layer.borderWidth = 1
        aboutItem.layer.borderColor = UIColor.lightGray.cgColor
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imagePicker = OpalImagePickerController()
        imagePicker.maximumSelectionsAllowed = 1
        
        presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
            for image in assets {
                image.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (editingInput, info) in
                    if let input = editingInput, let imgURL = input.fullSizeImageURL {
                        let localUrl = String(imgURL.absoluteString.dropFirst(5))
                        self.imageUrls.append(localUrl)
                        
                        Nuke.loadImage(with: imgURL, into: self.itemImageView)
                    }
                }
                
            }
            imagePicker.dismiss(animated: true, completion: nil)
            
        }, cancel: {
            
        })
    }
    
    // https://stackoverflow.com/questions/30812057/phasset-to-uiimage
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    @IBAction func addItemButton(_ sender: Any) {
        if button.titleLabel!.text == "Update item details" {
            let realm = try! Realm()
            let uuid = "uuid == '" + editUUID! + "'"
            
            if let results = realm.objects(Item.self).filter(uuid).first {
                try! realm.write {
                    results.title = adTitle.text
                    results.purchasePrice.value = Double(buyPrice.text!)
                    results.soldPrice.value = Double(sellPrice.text!)
                    results.category = tagTextbox.text
                    results.about = aboutItem.text
                    results.images.removeAll()
                    results.images.append(String((editItemUrl?.absoluteString.dropFirst(5))!))
                }
            }
        }
        else {
            if adTitle.text == "" || aboutItem.text == "" || buyPrice.text == "" ||
                tagTextbox.text == "" || imageUrls.isEmpty {
                return
            }
            insertItem()
            print(Realm.Configuration.defaultConfiguration.fileURL)
        }
        
        performSegue(withIdentifier: "activeItemsSegue", sender: nil)
    }
    
    func insertItem() {
        let realm = try! Realm()
        
        let newItem = Item()
        newItem.uuid = UUID().uuidString
        newItem.title = adTitle.text
        newItem.about = aboutItem.text
        newItem.purchasedDate = Date()
        newItem.soldDate = nil
        
        let a = Double(buyPrice.text!) ?? 0
        newItem.purchasePrice.value = (a*100).rounded()/100
        
        let b = Double(sellPrice.text!) ?? 0
        newItem.soldPrice.value = (b*100).rounded()/100
        
        for url in imageUrls {
            newItem.images.append(url)
        }
        
        newItem.category = tagTextbox.text
        
        try! realm.write {
            realm.add(newItem)
        }
        
        imageUrls = [String]()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tags.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tags[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let tag = tags[row]
        tagTextbox.text = tag
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        tagTextbox.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        currentBox = textField
        
        currentBox.inputView = pickerView
        dismissPickerView()
    }
}
