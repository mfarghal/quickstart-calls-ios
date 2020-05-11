//
//  AppDelegate.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import CallKit
import PushKit
import SendBirdCalls
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var queue: DispatchQueue = DispatchQueue(label: "com.sendbird.calls.quickstart.appdelegate")
    var voipRegistry: PKPushRegistry?
    
    lazy var provider: CXProvider = {
        let provider = CXProvider.default
        provider.setDelegate(self, queue: .main)
        return provider
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: SendBirdCall.configure(appId:)
        // See [here](https://github.com/sendbird/quickstart-calls-ios#creating-a-sendbird-application) for the application ID.
        // SendBirdCall.configure(appId: YOUR_APP_ID)

        if SendBirdCall.appId != nil {
            // User ID Mode
            self.window = UIWindow(frame: UIScreen.main.bounds)
            guard let window = self.window else { return false }
            window.rootViewController = UIStoryboard.signController()
            window.makeKeyAndVisible()
        } else if let appId = UserDefaults.standard.appId {
            // QR Code Mode
            SendBirdCall.configure(appId: appId)
        }
        
        // You must call `SendBirdCall.addDelegate(_:identifier:)` right after configuring new app ID
        SendBirdCall.addDelegate(self, identifier: "com.sendbird.calls.quickstart.delegate")
        
        let useVoIPPush = false // Modify this value to test Remote Push Notifications
        if useVoIPPush {
            self.voipRegistration()
        } else {
            self.remoteNotificationsRegistration(application)
        }
        return true
    }
}
