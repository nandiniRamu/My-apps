//
//  SigninViewController.swift
//  demoApp
//
//  Created by nandini on 2/20/18.
//  Copyright © 2018 abc. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class SigninViewController: UIViewController ,  GIDSignInDelegate, GIDSignInUIDelegate{

    @IBOutlet weak var signinView: UIView!
    let signInButton = GIDSignInButton()
    private let scopes = [kGTLRAuthScopeYouTubeReadonly]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
       // GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().scopes = scopes
        
        // Add the sign-in button.
        signinView.addSubview(signInButton)
    }
    //MARK : google signin implementation
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription,presenter: self)
          
        } else {
            self.signInButton.isHidden = true
          self.performSegue(withIdentifier: SegueIdentifiers.showsearchvideoIdentifier, sender: self)
        }
    }
    
}
