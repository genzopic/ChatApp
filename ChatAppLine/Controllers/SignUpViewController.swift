//
//  SignUpViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/27.
//

import UIKit
//
import Firebase


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alredyHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.height / 2
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor

        registerButton.layer.cornerRadius = 10
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)

        emailTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        
    }
    
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        guard let image = profileImageButton.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { (metadata, error) in
            if let err = error {
                print("save image err: ",err.localizedDescription)
                return
            }
            storageRef.downloadURL { (url, error) in
                if let err = error {
                    print("download image err: ",err.localizedDescription)
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                print("download image url: ",urlString)
                self.createUserToFirestore(profileImageUrl: urlString)
            }
        }
    }
    
    private func createUserToFirestore(profileImageUrl: String) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let userName = userNameTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let err = error {
                print("signIn err: ",err.localizedDescription)
                return
            }
            // save users for firestore
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let docData = [
                            "email": email,
                            "username": userName,
                            "createAt": Timestamp(),
                            "profileImageUrl": profileImageUrl
                            ] as [String : Any]
            Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
                if let err = error {
                    print("save database err: ",err.localizedDescription)
                    return
                }
                print("save database success!!")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

}

// MARK: - textFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let userNameIsEmpty = userNameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || userNameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
        
    }
    
}

// MARK: - imagePicker
extension SignUpViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            print("didFinishPickingMediaWithInfo editedImage")
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            print("didFinishPickingMediaWithInfo originalImage")
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
}
