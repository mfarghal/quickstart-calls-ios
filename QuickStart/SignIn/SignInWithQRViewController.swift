//
//  SignInWithQRViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/17.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class SignInWithQRViewController: UIViewController {
    // Scan QR Code
    @IBOutlet weak var scanButton: UIButton!
    
    // Footnote
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            let sampleVersion = Bundle.main.version
            self.versionLabel.text = "QuickStart \(sampleVersion)  Calls SDK \(SendBirdCall.sdkVersion)"
        }
    }
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.autoLogin == true {
            self.updateButtonUI()
            self.signIn()
        }
    }
    
    func startLoading() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = .gray
        self.view.addSubview(activityIndicator)
        
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopLoading() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func resetButtonUI() {
        self.scanButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.88), for: .normal)
        self.scanButton.backgroundColor = UIColor(red: 123 / 255, green: 83 / 255, blue: 239 / 255, alpha: 1.0)
        self.scanButton.setTitle("Scan QR Code", for: .normal)
        self.scanButton.isEnabled = true
    }
    
    func updateButtonUI() {
        self.scanButton.backgroundColor = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)
        self.scanButton.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.12), for: .normal)
        self.scanButton.setTitle("Signing In...", for: .normal)
        self.scanButton.isEnabled = false
    }
}

// MARK: - QR Code
extension SignInWithQRViewController: QRCodeScanDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "scanQR", let QRCodeVC = segue.destination.children.first as? QRCodeViewController else { return }
        QRCodeVC.delegate = self
    }
    
    @IBAction func didTapScanQRCode() {
        performSegue(withIdentifier: "scanQR", sender: nil)
    }
    
    // Delegate method
    func didScanQRCode(appId: String, userId: String, accessToken: String?) {
        SendBirdCall.configure(appId: appId)

        UserDefaults.standard.appId = appId
        UserDefaults.standard.user.id = userId
        UserDefaults.standard.accessToken = accessToken
        self.updateButtonUI()
        self.signIn()
    }
}

// MARK: SendBirdCalls
extension SignInWithQRViewController {
    func signIn() {
        let userId = UserDefaults.standard.user.id
        let accessToken = UserDefaults.standard.accessToken
        let authParams = AuthenticateParams(userId: userId, accessToken: accessToken, voipPushToken: UserDefaults.standard.pushToken, unique: false)
        self.startLoading()
        
        SendBirdCall.authenticate(with: authParams) { user, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.stopLoading()
                self.resetButtonUI()
            }
            
            guard let user = user, error == nil else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let errorDescription = String(error?.localizedDescription ?? "")
                    self.presentErrorAlert(message: "Failed to authenticate\n\(errorDescription)")
                }
                return
            }
            UserDefaults.standard.autoLogin = true
            UserDefaults.standard.user = (user.userId, user.nickname, user.profileURL)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: "signInWithQRCode", sender: nil)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}