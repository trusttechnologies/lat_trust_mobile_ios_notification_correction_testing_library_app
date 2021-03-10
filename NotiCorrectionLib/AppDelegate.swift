//
//  AppDelegate.swift
//  NotiCorrectionLib
//
//  Created by Kevin Torres on 25-02-21.
//

import UIKit
import TrustDeviceInfo
import TrustNotification
import FirebaseMessaging
import FirebaseCore
import UserNotifications

enum Credentials {
    case prod
    case test
    
    var clientID: String {
        switch self {
        case .prod: return "982862e9fa91bc66da8fd5731241ab9f3c9c0ca7df8e6fc9eeb47b97c160f39b"
        case .test: return "1591e87a-3335-408e-aa12-668128be8dc8"
        }
    }
    
    var clientSecret: String {
        switch self {
        case .prod: return "5608eba6cc53cd94abca50ec3f87142006af9fdf5f2d278445f604218467f5d7"
        case .test: return "57715d62-7607-43f3-9220-349132761afa"
        }
    }
}

@main
class AppDelegate: UIResponder {
    
    let serviceName = "defaultServiceName"
    let accessGroup = "P896AB2AMC.trustID.appLib"
    
    let credentials: Credentials = .prod
    
    let userDeviceInfo = UserDeviceInfo(dni: "")
    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initIdentify()
        Identify.shared.sendDeviceInfo(identityInfo: userDeviceInfo)
        
        initTrustNotifications()
        
        firebaseConfig()
        registerForRemoteNotifications()
        
        return true
    }
}

extension AppDelegate: TrustDeviceInfoDelegate {
    func onTrustIDSaved(savedTrustID: String) {
        Identify.shared.setAppState(dni: "", bundleID: "com.trust.NotiCorrectionLib")
        KeychainWrapper.standard.set("\(savedTrustID)", forKey: "trustID")
    }
    
    func onClientCredentialsSaved(savedClientCredentials: ClientCredentials) {}
    func onRegisterFirebaseTokenSuccess(responseData: RegisterFirebaseTokenResponse) {}
    func onSendDeviceInfoResponse(status: ResponseStatus) {}
}

// MARK: - Notifications - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    //MARK: Initial Settings
    private func firebaseConfig() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    public func registerForRemoteNotifications(){
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Clear badge number func
    public func clearBadgeNumber() {}
    
    // MARK: Background Notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            PushNotifications.shared.getNotification(response: response)
            completionHandler()
        }
    }
    
    // MARK: Foreground Notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        PushNotifications.shared.getNotificationForeground(notification: notification)
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    // MARK: To know arrived notifications use the following obs
    func setNotificationObservers() {
        NotificationCenter.default.post(name: Notification.Name("ReceiveData"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("NotificationArrived"), object: nil)
    }
}

//MARK: Messaging Delegate
extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        guard let fcmToken = fcmToken else { return }
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        guard let bundle = Bundle.main.bundleIdentifier else{
            print("Bundle ID Error")
            return
        }
    // MARK: - *** Register Firebase Token. ***
    // Once initialized REMEMBER to register the firebase token with the help of the TrustIdentify.
        Identify.shared.registerFirebaseToken(firebaseToken: fcmToken, bundleID: bundle)
    }
}

// MARK: - Private Methods
extension AppDelegate {
    
    func initIdentify() {
        Identify.shared.trustDeviceInfoDelegate = self
        Identify.shared.set(currentEnvironment: .prod)
        Identify.shared.set(serviceName: serviceName, accessGroup: accessGroup)
        Identify.shared.createClientCredentials(clientID: credentials.clientID, clientSecret: credentials.clientSecret)
        Identify.shared.enable()
    }
    
    private func initTrustNotifications() {
        PushNotifications.shared.set(currentEnvironment: .prod)
        PushNotifications.shared.set(serviceName: serviceName, accessGroup: accessGroup)
        PushNotifications.shared.createNotiClientCredentials(clientID: credentials.clientID, clientSecret: credentials.clientSecret)
    }
}
