//
//  ViewController.swift
//  Friendly Chat
//
//  Created by Jean Fellipe de Almeida Pimentel on 9/2/16.
//  Copyright © 2016 CI&T. All rights reserved.
//

import UIKit
import Firebase

// MARK: - Life Cycle

class ViewController: UIViewController {

    var user: FIRUser?

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        guard let user = FIRAuth.auth()?.currentUser else {
            performSegueWithIdentifier(Constants.Segues.ShowLogin, sender: nil)
            return
        }

        self.user = user
        print(user.displayName)
    }

}

// MARK: - Actions

extension ViewController {

    @IBAction func logout(sender: AnyObject) {
        do {
            try FIRAuth.auth()?.signOut()
            GIDSignIn.sharedInstance().signOut()

            self.user = nil

            performSegueWithIdentifier(Constants.Segues.ShowLogin, sender: nil)
        }
        catch {

        }
    }
}

