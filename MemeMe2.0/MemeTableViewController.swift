//
//  MemeTableViewController.swift
//  MemeMe2.0
//
//  Created by 1203 Broadway on 8/2/21.
//
/*
 About MemeTableViewController.swift:
 UITableViewController subclass. Used to present history of sent memes in a tableView. User can select meme in table for a detailed view. "+" button in navBar to create a new meme.
 */

import UIKit

class MemeTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add a test meme
        for _ in 0...0 {
            saveMeme(createDebugMeme())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update table
        self.tableView.reloadData()
        
        // update enable state of tabBar items
        tabBarItemsEnabled(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // segue to meme detail view.
        let navController = segue.destination as! UINavigationController
        let controller = navController.viewControllers[0] as! MemeEditorViewController
        
        // set block in controller. Used when .pagesheet modal mode is presented..
        // ..required for reloading tableView since viewWillAppear is not called
        // when pageSheet is swiped down to dismiss
        controller.updateUIBlock = {
            self.tableView.reloadData()
        }
    }
}

// MARK: MemeTableViewController delegate functions
extension MemeTableViewController {
    
    // number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memes.count
    }
    
    // create a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID")!
        let meme = memes[indexPath.row]
        cell.textLabel?.text = meme.topText
        cell.detailTextLabel?.text = meme.bottomText
        cell.imageView?.image = meme.memedImage
        return cell
    }
    
    // handle cell selection, push MemeDetailViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = storyboard?.instantiateViewController(identifier: "MemeDetailViewControllerID") as! MemeDetailViewController
        controller.meme = memes[indexPath.row]
        
        // disable tabBar items when in detail view
        tabBarItemsEnabled(false)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // delete a sent meme
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteMeme(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
