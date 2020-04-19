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
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    
    let pickerController = UIImagePickerController()
    
    //MARK -- TO DO: Look up enum two case state cases so you can fix this
    enum ImageState {
        case hasImage
        case noImage
    }
    
    // MARK -- TO DO: Replace the state for toolbar state with this enum.
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
        
        pickerController.delegate = self
        topTextField.delegate = self
        botomTextField.delegate = self
        //        shareButton.isEnabled = false
        configureButtons(.disabled)
        
        
        topTextField.text = "TOP"
        topTextField.textAlignment = NSTextAlignment.center
        botomTextField.text = "BOTTOM"
        botomTextField.textAlignment = NSTextAlignment.center
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: NSNumber.init(value: 3.0)
            
        ]
        
        // Assigns the styling for top and bottom text fields
        topTextField.defaultTextAttributes = memeTextAttributes
        botomTextField.defaultTextAttributes = memeTextAttributes
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
    
    @IBAction func pickAnImageFromLibrary(_ sender: Any) {
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            //            shareButton.isEnabled = true
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
        view.frame.origin.y = -getKeyboardHeight(notification)
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
    
    // MARK - TODO: This should be tied to the activity view controller specifically to the action the user selects in the way to share.
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: botomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
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
            topToolbar.isHidden = false
        case .hide:
            bottomToolbar.isHidden = true
            topToolbar.isHidden = true
        }
    }
}

