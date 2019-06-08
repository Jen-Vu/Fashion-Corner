//
//  ItemsCollectionVC.swift
//  Fashion Corner
//
//  Created by Pramodya Abeysinghe on 7/6/19.
//  Copyright © 2019 Pramodya. All rights reserved.
//

import UIKit
import Firebase

class ItemsCollectionVC: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedCategory: Category!
    var fashionItems = [FashionItem]()
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        self.title = selectedCategory.name
        collectionView.isHidden = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "FashionItemCell", bundle: nil), forCellWithReuseIdentifier: "FashionItemCell")
        
        getItems()
    }

    func getItems() {
        spinner.startAnimating()
        db.collection("items").whereField("category", isEqualTo: selectedCategory.name).getDocuments { (snap, error) in
            if let error = error {
                debugPrint(error)
                return
            }
            
            for document in snap!.documents {
                let data = document.data()
                let newItem = FashionItem(data: data)
                self.fashionItems.append(newItem)
            }
            
            self.spinner.stopAnimating()
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
        
    }
}

extension ItemsCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fashionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FashionItemCell", for: indexPath) as? FashionItemCell {
            cell.configureCell(item: fashionItems[indexPath.item])
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let cellWidth = (width - 50 ) / 2
        let cellHeight = cellWidth * 1.5
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItem" {
            
            if let indexPaths = self.collectionView.indexPathsForSelectedItems {
                let indexPath = indexPaths[0]
                let item = fashionItems[indexPath.item]
                let destinationVC = segue.destination as? ItemVC
                destinationVC?.selectedItem = item
            }
        }
    }
    
}
