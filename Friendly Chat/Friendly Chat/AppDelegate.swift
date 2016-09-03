//
//  AppDelegate.swift
//  Friendly Chat
//
//  Created by Jean Fellipe de Almeida Pimentel on 9/2/16.
//  Copyright © 2016 CI&T. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        IQKeyboardManager.sharedManager().enable = true
        
        FIRApp.configure()

        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)

        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            let storyboard =  UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            self.window?.rootViewController = storyboard.instantiateInitialViewController()
        }
    }

    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!, withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

}

