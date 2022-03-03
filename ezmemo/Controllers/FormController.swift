//
//  FormController.swift
//  ezmemo
//
//  Created by kgo on 2022/01/19.
//

import UIKit
import MobileCoreServices
import Firebase

class FormController: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var flgSwitch: UISwitch!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var countStepper: UIStepper!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.addTarget(self, action: #selector(self.textValueChanged), for: .valueChanged)
        flgSwitch.addTarget(self, action: #selector(self.textValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(self.textValueChanged), for: .valueChanged)
        countStepper.addTarget(self, action: #selector(self.textValueChanged), for: .valueChanged)
        date.addTarget(self, action: #selector(self.textValueChanged), for: .valueChanged)
        
        dateTextField.addTarget(self, action: #selector(self.dateEditing), for: .editingDidBegin)
        sexTextField.addTarget(self, action: #selector(self.sexEditing), for: .editingDidBegin)
        
        self.tableView.keyboardDismissMode = .onDrag
        
        sexTextField.text = "女性"
    }
    
    @IBAction func addImage(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let selectPhotoAction = UIAlertAction(title: "写真を選択", style: .default) { _ in
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                //エラーメッセージ
                return
            }
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            picker.view.tag = 0
            
            self.present(picker, animated: true)
        }
        
        let takePhotoAction = UIAlertAction(title: "写真を撮る", style: .default) { _ in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                //エラーメッセージ
                return
            }
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            
            self.present(picker, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            actionSheet.dismiss(animated: true)
        }
        
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(selectPhotoAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true)
    }
    
    @objc func textValueChanged() {
        print(emailTextField.text)
        print(flgSwitch.state)
        print(slider.value)
        print(countStepper.value)
        print(date.date)
    }
    
    @objc func dateEditing(sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        self.dateTextField.text = sender.date.format("yyyy-MM-dd")
    }
    
    @objc func sexEditing(sender: UITextField) {
        let sexPickerView = UIPickerView()
        sexPickerView.tag = 0
        sexPickerView.delegate = self
        sexPickerView.dataSource = self
        sender.inputView = sexPickerView
        sexPickerView.selectRow(2, inComponent: 0, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FormController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 0:
            return 2
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return 3
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UITheme.bgColor
        ]
        switch pickerView.tag {
        case 0:
            switch row {
            case 0:
                return NSAttributedString(string: "未選択", attributes: attributes)
            case 1:
                return NSAttributedString(string: "男性", attributes: attributes)
            case 2:
                return NSAttributedString(string: "女性", attributes: attributes)
            default:
                return NSAttributedString(string: "ーー", attributes: attributes)
            }
        default:
            return NSAttributedString(string: "ーー", attributes: attributes)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            if row == 1 {
                self.sexTextField.text = "男性"
            }
            
            if row == 2 {
                self.sexTextField.text = "女性"
            }
            
            if row == 0 {
                self.sexTextField.text = "未選択"
            }
        default:
            self.sexTextField.text = ""
        }
    }
}

extension FormController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if picker.view.tag == 0 {
            let medaiType = info[.mediaType] as! String
            
            guard medaiType == (kUTTypeImage as String) else {
                //エラーメッセージ
                return
            }
            
            let image = info[.editedImage] as! UIImage
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let mountainImagesRef = storageRef.child("images/test.jpg")
            let data = image.jpegData(compressionQuality: 1.0)!
            
            
            let uploadTask = mountainImagesRef.putData(data, metadata: nil) { (metadata, error) in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
              }

              // Metadata contains file metadata such as size, content-type.
              let size = metadata.size
              // You can also access to download URL after upload.
                mountainImagesRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
                  
                  print(size)
                  print("downloadURL", downloadURL)
              }
            }
            
            uploadTask.resume()
            
            self.imageView.image = image
            picker.dismiss(animated: true)
        }
    }
}
