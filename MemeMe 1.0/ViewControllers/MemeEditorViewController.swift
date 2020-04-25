//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Brian Andreasen on 4/15/20.
//  Copyright © 2020 Brian Andreasen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var botomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let pickerController = UIImagePickerController()
    
    enum ToolbarState {
        case show
        case hide
    }
    
    enum ButtonState {
        case enabled
        case disabled
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons(.disabled)
        styleTextField(topTextField, "ENTER TOP TEXT")
        styleTextField(botomTextField, "ENTER BOTTOM TEXT")
    }
    
    func styleTextField(_ textField: UITextField, _ defaultText: String) {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
              NSAttributedString.Key.strokeColor: UIColor.black,
              NSAttributedString.Key.foregroundColor: UIColor.white,
              NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
              NSAttributedString.Key.strokeWidth: NSNumber.init(value: -2.5)
              
          ]
        
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    func pickFromSource(_ source: UIImagePickerController.SourceType) {
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromLibrary(_ sender: Any) {
        pickFromSource(.photoLibrary)
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickFromSource(.camera)
    }
    
    @IBAction func share(_ sender: Any) {
        
        let memedImage = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: [])
        
        present(activityVC, animated: true)
        
        activityVC.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
            Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
                return
            } else {
                return
            }
        }
        
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = shareButton
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            configureButtons(.enabled)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if (botomTextField.isEditing) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        configureToolbar(.hide)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        configureToolbar(.show)
        return memedImage
    }
    
    func save() {
        _ = Meme(topText: topTextField.text!, bottomText: botomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    func configureButtons(_ buttonState: ButtonState) {
        switch buttonState {
        case .enabled:
            shareButton.isEnabled = true
        case .disabled:
            shareButton.isEnabled = false
        }
    }
    
    func configureToolbar(_ toolbarState: ToolbarState) {
        switch toolbarState {
        case .show:
            bottomToolbar.isHidden = false
            navigationBar.isHidden = false
        case .hide:
            bottomToolbar.isHidden = true
            navigationBar.isHidden = true
        }
    }
}

