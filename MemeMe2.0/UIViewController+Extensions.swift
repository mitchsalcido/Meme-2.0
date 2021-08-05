//
//  UIViewController+Extensions.swift
//  PitchPerfect
//
//  Created by 1203 Broadway on 5/11/21.
//
/*
 About UIViewController+Extensions.swift
 Extension to include , helpers, UIAlertController creation using LocalizedError info
 */

import UIKit

extension UIViewController {
    
    // return saved memes array
    var memes: [Meme] {
        return appDelegate().sentMemes
    }
    
    // save meme
    func saveMeme(_ meme:Meme) {
        appDelegate().sentMemes.append(meme)
    }
    
    // delete meme
    func deleteMeme(_ index: Int) {
        appDelegate().sentMemes.remove(at: index)
    }
    
    // appDelegate
    func appDelegate() -> AppDelegate {
        let object = UIApplication.shared.delegate
        return object as! AppDelegate
    }
    
    // create a Meme for test/debug
    func createDebugMeme() -> Meme {
        
        let originalImage = UIImage(named: "DebugOriginalImage")
        let memedImage = UIImage(named: "DebugMemedImage")
        let topText = "THIS IS A MEME !"
        let bottomText = "PRESS '+' TO CREATE NEW MEME"
        let meme = Meme(topText: topText,
                        bottomText: bottomText,
                        originalImage: originalImage,
                        memedImage: memedImage)
        
        return meme
    }

    // enable/disable tabBarItems
    func tabBarItemsEnabled(_ enable: Bool) {
        
        if let tabBarItems = self.tabBarController?.tabBar.items {
            for tabBarItem in  tabBarItems {
                tabBarItem.isEnabled = enable
            }
        }
    }
    
    // create/show and alert using LocalizedError properties
    func showAlert(_ error: LocalizedError) {

        // verify good alert info
        let alertTitle = error.errorDescription ?? "Unknown Error"
        let alertMessage = error.recoverySuggestion ?? "Try closing app and restaring"
        let actionTitle = error.helpAnchor ?? "Dismiss"

        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
