//
//  SignUpViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/27.
//

import UIKit
//
import Firebase
import PKHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alredyHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
    }
    
    private func setupViews() {
        // プロフィール画像
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.height / 2
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        // Registerボタン
        registerButton.layer.cornerRadius = 10
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        // password
        passwordTextField.isSecureTextEntry = true
        //
        emailTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        // 既にアカウントをお持ちの方のアクションを設定
        alredyHaveAccountButton.addTarget(self, action: #selector( tappedAlreadyHaveAccountButton), for: .touchUpInside)
        
    }
    // 既にアカウントをお持ちの方をタップ
    @objc private func tappedAlreadyHaveAccountButton() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    // プロフィール画像をタップ
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    // Registerボタンをタップ
    @IBAction func tappedRegisterButton(_ sender: Any) {
        let image = profileImageButton.imageView?.image ?? UIImage(named: "person")
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
        HUD.show(.progress)
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { (metadata, error) in
            if let err = error {
                print("save image err: ",err.localizedDescription)
                HUD.hide()
                return
            }
            storageRef.downloadURL { (url, error) in
                if let err = error {
                    print("download image err: ",err.localizedDescription)
                    HUD.hide()
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
        HUD.show(.progress)
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let err = error {
                print("signIn err: ",err.localizedDescription)
                HUD.hide()
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
                    HUD.hide()
                    return
                }
                print("save database success!!")
                HUD.hide()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチしたらキーボードを閉じる
        view.endEditing(true)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Enterでキーボードを閉じる
        textField.resignFirstResponder()
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
