//
//  AlertHelper.swift
//  demoApp
//
//  Created by nandini on 2/21/18.
//  Copyright © 2018 abc. All rights reserved.
//

import UIKit

// Helper for showing an alert
func showAlert(title : String, message: String , presenter : UIViewController) {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: UIAlertControllerStyle.alert
    )
    let ok = UIAlertAction(
        title: "OK",
        style: UIAlertActionStyle.default,
        handler: { (okaction)->Void in 
            alert.dismiss(animated: true, completion: nil)
    }
    )
    alert.addAction(ok)
    presenter.present(alert, animated: true, completion: nil)
}
