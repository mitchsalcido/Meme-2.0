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
    
    @objc func editMemeBbiPressed(_ sender: UIBarButtonItem) {

        let navController = UINavigationController()
        let controller = storyboard?.instantiateViewController(identifier: "MemeEditorViewControllerID") as! MemeEditorViewController
        
        controller.memeToBeEdited = meme

        controller.updateUIBlock = {(_ meme: Meme?) -> Void in
            if let editedMeme = meme {
                self.meme = editedMeme
                self.imageView.image = self.meme.memedImage
            }
        }
        
        navController.viewControllers = [controller]
        present(navController, animated: true, completion: {})
    }
}
