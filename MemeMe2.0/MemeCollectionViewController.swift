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
    
    let ITEMS_PER_ROW: CGFloat = 5.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
        tabBarItemsEnabled(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navController = segue.destination as! UINavigationController
        let controller = navController.viewControllers[0] as! MemeEditorViewController
        controller.updateUIBlock = {
            self.collectionView.reloadData()
        }
    }
}

extension MemeCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath) as! MemeCollectionViewCell
        
        let meme = memes[indexPath.row]
        cell.memeImageView.image = meme.memedImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let controller = storyboard?.instantiateViewController(identifier: "MemeDetailViewControllerID") as! MemeDetailViewController
        controller.meme = memes[indexPath.row]
        
        tabBarItemsEnabled(false)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MemeCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let dimension = collectionView.frame.size.width / ITEMS_PER_ROW
        let size = CGSize(width: dimension, height: dimension)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSectionAt: Int) -> UIEdgeInsets {
        
        let inset = UIEdgeInsets(top: 0.0,
                                 left: 0.0,
                                 bottom: 0.0,
                                 right: 0.0)
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        
        return 0.0
    }
}
