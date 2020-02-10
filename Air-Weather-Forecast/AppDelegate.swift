//
//  AppDelegate.swift
//  Air-Weather-Forecast
//
//  Created by seol on 04/06/2019.
//  Copyright © 2019 seol. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var splash : UIImageView!
    private var isSplashDidRemove:Bool = false
    
    func splashDidShow() {
        
        /* 앱에서 작동하는 LunchImage 이외에 스플래시 이미지를 따로 만들어 주어 보여주는 부분입니다. */
        /* 사용자에게는 그저 LunchScreen이 길게 보이는 것처럼 보여집니다. */
        
        func getSplashImageName() -> String {
            /* 여러 해상도에 맞는 스플래시 이미지의 이름을 가져오는 부분입니다.
             이부분을 사용하지 않고
             splash.image = UIImage(named: "LunchImage")
             이렇게 하여도 동작하긴 하나, Default이미지가 가져와지므로 해상도 별로 적절한 이미지가 보여지지 않습니다 ( 이미지가 늘어져 보이는 이슈가 생길 수 있습니다. )
             */
            
            let viewSize = UIScreen.main.bounds.size
            
            guard let imagesDict = Bundle.main.infoDictionary as [String: AnyObject]?,
                let imagesArray = imagesDict["UILaunchImages"] as? [[String: String]] else {
                    return "LaunchImage"
            }
            
            var viewOrientation: String
            switch UIDevice.current.orientation {
            // 이부분은 https://stackoverflow.com/questions/25796545/getting-device-orientation-in-swift 를 참고하세요
            case .portrait:
                viewOrientation = "Portrait"
            case .portraitUpsideDown:
                viewOrientation = "PortraitUpsideDown"
            default:
                viewOrientation = "Portrait"
            }
            
            for dict in imagesArray {
                if let sizeString = dict["UILaunchImageSize"], let imageOrientation = dict["UILaunchImageOrientation"] {
                    let imageSize = NSCoder.cgSize(for: sizeString)
                    if imageSize.equalTo(viewSize) && viewOrientation == imageOrientation {
                        if let imageName = dict["UILaunchImageName"] {
                            return imageName
                        }
                    }
                }
            }
            
            return "LaunchImage"
        }
        
        UIApplication.shared.isStatusBarHidden = true
        /* 상단에 status바가 보이지 않도록 합니다. */
        splash = UIImageView(frame: self.window!.frame)
        splash.image = UIImage(named: getSplashImageName())
        self.window!.addSubview(splash)
        self.window?.bringSubviewToFront(splash)
    }
    
    func splashDidRemove() {
        print(#function)
        UIView.animate(withDuration: 0.4,
                       animations: { self.splash.alpha = 0 },
                       completion: { _ in
                        self.splash.removeFromSuperview()
                        UIApplication.shared.isStatusBarHidden = false
                        /* 상단에 status바가 보이도록 합니다. */
                        self.isSplashDidRemove = true
        })
    }

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Air_Weather_Forecast")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

