//
//  LoginViewController.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/04/02.
//

import UIKit
//
import Firebase
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        loginButton.layer.cornerRadius = 10
        loginButton.isEnabled = false

        // password
        passwordTextField.isSecureTextEntry = true

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        HUD.show(.progress)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let err = error {
                print("login err: ",err)
                HUD.hide()
                return
            }
            HUD.hide()
            print("login success!!",result.debugDescription)
            // 呼び出し元に戻る前に、chatListViewController のfetchChatRoomsInfoFromFirestoreを実行してチャットリストを取得してから、閉じる
            // self.presentingViewController　で、モーダル遷移元
            let nav = self.presentingViewController as! UINavigationController
            let chatListViewController = nav.viewControllers[nav.viewControllers.count-1] as? ChatListViewController
            chatListViewController?.fetchChatRoomsInfoFromFirestore()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


// MARK: -
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
//        print("textField: ",textField.text)
        let isEmailEmpty =  emailTextField.text?.isEmpty ?? true
        let isPasswordEmpty = passwordTextField.text?.isEmpty ?? true
        
        if isEmailEmpty && isPasswordEmpty {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
        }
        
    }
    
}
