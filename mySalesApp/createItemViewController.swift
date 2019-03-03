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

class createItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var currentBox = UITextField()
    var pickerView = UIPickerView()
    
    
    @IBOutlet weak var adTitle: UITextField!
    @IBOutlet weak var aboutItem: UITextView!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var tagTextbox: UITextField!

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
        aboutItem.layer.borderWidth = 1
        aboutItem.layer.borderColor = UIColor.black.cgColor
        
        super.viewDidLoad()
        
    }
    
    // Soure code for retrieving image URL from PHAsset
    // https://stackoverflow.com/questions/44472070/how-to-get-image-url-from-phasset-is-it-possible-to-save-image-using-phasset-ur
    @IBAction func selectImageButton(_ sender: Any) {
        let imagePicker = OpalImagePickerController()
        
        presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
            
            for image in assets {
                image.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (editingInput, info) in
                    if let input = editingInput, let imgURL = input.fullSizeImageURL {
                        let localUrl = String(imgURL.absoluteString.dropFirst(5))
                        self.imageUrls.append(localUrl)
                    }
                }
            }
            
            imagePicker.dismiss(animated: true, completion: nil)
            
        }, cancel: {
            
        })
        
    }
    
    @IBAction func addItemButton(_ sender: Any) {
        
        if adTitle.text == "" || aboutItem.text == "" || price.text == "" ||
            tagTextbox.text == "" || imageUrls.isEmpty {
            return
        }
        
        insertItem()
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
    func insertItem() {
        let realm = try! Realm()
        
        var newItem = Item()
        newItem.title = adTitle.text
        newItem.about = aboutItem.text
        newItem.purchasedDate = Date()
        newItem.soldDate = nil
        
        let a = Double(price.text!) ?? 0
        newItem.purchasePrice.value = (a*100).rounded()/100
        
        newItem.soldPrice.value = 0
        
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

// https://stackoverflow.com/questions/28332946/how-do-i-get-the-current-date-in-short-format-in-swift
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
