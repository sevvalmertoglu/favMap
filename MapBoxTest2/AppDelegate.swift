//
//  AppDelegate.swift
//  MapBoxTest2
//
//  Created by Şevval Mertoğlu on 7.06.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var timer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if error != nil {
                print(error!)
            } else {
                //kullanıcıdan izin alındı
            }
        }
        
        // Timer başlar
        startTimer()
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundTask()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        stopBackgroundTask()
    }
    
    // Timer'ı başlatan fonksiyon
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 172800, repeats: true) { timer in
            // Timer tetiklendiğinde bildirim gönderir
            self.sendNotification()
        }
    }
    
    // Bildirim gönderen fonksiyon
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title =  Localizer.localize("Where are you?")
        content.body =  Localizer.localize("You haven't opened the app for 2 days. Did you forget to take a look?")
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Arka planda çalışan task'ı ayarlayan fonksiyon
    func scheduleBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            self.stopBackgroundTask()
        }
    }
    
    // Arka plandaki task'ı sonlandıran fonksiyon
    func stopBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

