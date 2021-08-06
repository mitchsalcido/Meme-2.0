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
    
    var editMemeBbi: UIBarButtonItem!
    
    // Meme passed in
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the meme image
        imageView.image = meme.memedImage
        
        // edit button for editing into new meme
        editMemeBbi = UIBarButtonItem(barButtonSystemItem: .edit,
                                      target: self,
                                      action: #selector(editMemeBbiPressed(_:)))
        navigationItem.rightBarButtonItem = editMemeBbi
    }
    
    // edit the meme
    @objc func editMemeBbiPressed(_ sender: UIBarButtonItem) {

        // create controller in a navVC
        let controller = storyboard?.instantiateViewController(identifier: "MemeEditorViewControllerID") as! MemeEditorViewController
        let navController = UINavigationController()
        navController.viewControllers = [controller]

        // assign meme
        controller.memeToBeEdited = meme

        // block to invoke upon saving meme... update imageView with edited meme
        controller.updateUIBlock = {(_ meme: Meme?) -> Void in
            if let editedMeme = meme {
                self.meme = editedMeme
                self.imageView.image = self.meme.memedImage
            }
        }
        
        // present
        present(navController, animated: true, completion: {})
    }
}
