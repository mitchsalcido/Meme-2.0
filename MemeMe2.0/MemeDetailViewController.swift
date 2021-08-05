//
//  MemeDetailViewController.swift
//  MemeMe2.0
//
//  Created by 1203 Broadway on 8/4/21.
//
/*
 About MemeDetailViewController.swift
 UIViewController subclass used to view a meme.
 */

import UIKit

class MemeDetailViewController: UIViewController {

    // outlet to imageView to display meme
    @IBOutlet weak var imageView: UIImageView!
    
    // Meme passed in
    var meme: Meme? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the meme image
        if let meme = meme, let image = meme.memedImage {
            imageView.image = image
        }
    }
}
