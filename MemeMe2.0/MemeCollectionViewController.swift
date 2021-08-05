//
//  MemeCollectionViewController.swift
//  MemeMe2.0
//
//  Created by 1203 Broadway on 8/2/21.
//
/*
 About MemeCollectionViewController.swift:
 UICollectionViewController subclass. Used to present history of sent memes in a collectionView. User can select meme cell for a detailed view. "+" button in navBar to create a new meme.
 */

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // customize cells per row
    let ITEMS_PER_ROW: CGFloat = 5.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update collection
        self.collectionView.reloadData()
        
        // update enable state of tabBar items
        tabBarItemsEnabled(true)
    }
    
    // view change, rotation, etc
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        /*
         Handle relayout of collectionView by invalidating current layout.
         ..for maintaining same number of cells/row when rotating device
         */
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // segue to meme detail view.
        let navController = segue.destination as! UINavigationController
        let controller = navController.viewControllers[0] as! MemeEditorViewController
        
        // set block in controller. Used when .pagesheet modal mode is presented..
        // ..required for reloading tableView since viewWillAppear is not called
        // when pageSheet is swiped down to dismiss
        controller.updateUIBlock = {
            self.collectionView.reloadData()
        }
    }
}

// MARK: MemeCollectionViewController delegate functions
extension MemeCollectionViewController {
    
    // number of cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    // create a cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath) as! MemeCollectionViewCell
        
        let meme = memes[indexPath.row]
        cell.memeImageView.image = meme.memedImage
        return cell
    }
    
    // handle cell selection, push MemeDetailViewController
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let controller = storyboard?.instantiateViewController(identifier: "MemeDetailViewControllerID") as! MemeDetailViewController
        controller.meme = memes[indexPath.row]
        
        // disable tabBar items when in detail view
        tabBarItemsEnabled(false)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: UICollectionViewDelegateFlowLayout delegate functions
extension MemeCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    // size of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let dimension = collectionView.frame.size.width / ITEMS_PER_ROW
        let size = CGSize(width: dimension, height: dimension)
        return size
    }
    
    // cell insets
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSectionAt: Int) -> UIEdgeInsets {
        
        let inset = UIEdgeInsets(top: 0.0,
                                 left: 0.0,
                                 bottom: 0.0,
                                 right: 0.0)
        
        return inset
    }
    
    // spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    // spacing
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        
        return 0.0
    }
}
