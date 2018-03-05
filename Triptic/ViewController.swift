//
//  ViewController.swift
//  Triptic
//
//  Created by Valentin COUSIEN on 01/03/2018.
//  Copyright © 2018 Valentin COUSIEN. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var galleryCollectionView: CustomImagePicker!
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        galleryCollectionView.parentController = self
        galleryCollectionView.prefetchDataSource = galleryCollectionView
        galleryCollectionView.dataSource = galleryCollectionView
        galleryCollectionView.delegate = galleryCollectionView
        galleryCollectionView.launch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setImageView(newImage : UIImage) {
        
        detailImageView.image = newImage
    }

}
