//
//  PhotoViewController.swift
//  VKtest
//
//  Created by Станислав Серов on 28.09.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//
import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var vk: VkAPI!
    var photoInfo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        imageView.contentMode = .scaleAspectFill
        if let maxPhoto = vk.friendList[vk.idSelectedPhoto].photo_max_orig {
            
            guard let url = URL(string: maxPhoto) else {return}
            NetworkServices.shared.downloadImage(url: url) { (image) in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.imageView.image = image
            }
        }
        
        if let photoInfo = photoInfo {
            self.infoLabel.text = photoInfo
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePhotoView))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func closePhotoView() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
