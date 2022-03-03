//
//  LoginController.swift
//  ezmemo
//
//  Created by kgo on 2021/12/15.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setup()
        addObservers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Login
    @IBAction func login(_ sender: Any) {
        if let username = emailField.text, let password = passwordField.text {
            AuthToken.login(email: username, password: password) { authToken in
                guard let _ = authToken else { return }
                self.toMainStoryboard()
            }
        }
    }
    
    // MARK: - Setup
    func setup() {
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    // MARK: - デザイン
    func setupUI() {
        emailField.attributedPlaceholder = UITheme.universalPlaceholder(named: "E-mail")
        passwordField.attributedPlaceholder = UITheme.universalPlaceholder(named: "Password")
        emailField.layer.borderWidth = UITheme.borderWidth
        emailField.layer.borderColor = UITheme.accentColor.cgColor
        passwordField.layer.borderWidth = UITheme.borderWidth
        passwordField.layer.borderColor = UITheme.accentColor.cgColor
    }
    
    // MARK: - 通知Observers
    func addObservers() {
        NotificationCenter.default.addObserver(forName: LocalNotificationService.networkError, object: nil, queue: nil) { notification in
            guard let message = notification.userInfo!["message"] else { return }
            
            self.showAlert(title: "エラー", message: message as! String)
        }
        NotificationCenter.default.addObserver(forName: LocalNotificationService.authError, object: nil, queue: nil) { notification in
            guard let message = notification.userInfo!["message"] else { return }
            
            self.showAlert(title: "ログインエラー", message: message as! String)
        }
    }
    
    func showAlert(title: String, message: String) {
        
        let titleString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.foregroundColor : UITheme.accentColor
            ])
        
        let messageString = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.foregroundColor : UITheme.accentColor
            ])
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        
        let action = UIAlertAction(title: "OK", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UITheme.bgColor
        alert.view.subviews.first?.subviews.first?.subviews.first?.layer.cornerRadius = 1
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.layer.borderWidth = 1.0
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.layer.borderColor = UITheme.accentColor.cgColor
        alert.view.tintColor = UITheme.accentColor
        alert.view.layer.borderWidth = 1.0
        alert.view.layer.borderColor = UITheme.accentColor.cgColor
    }
    
    
    // MARK: - Navigation
    func toMainStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainView") as! MainController
        UIView.transition(from: self.view, to: controller.view, duration: 0.6, options: [.transitionCrossDissolve]) { _ in
            UIApplication.shared.keyWindow?.rootViewController = controller
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
}

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            passwordField.becomeFirstResponder()
            break
        case 1:
            textField.resignFirstResponder()
        default:
            break
        }
        
        return true
    }
}
