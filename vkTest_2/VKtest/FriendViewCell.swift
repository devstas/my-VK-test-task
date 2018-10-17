//
//  FriendViewCell.swift
//  VKtest
//
//  Created by Devolper on 01.06.18.
//  Copyright © 2018 Devolper. All rights reserved.
//

import UIKit

class FriendViewCell: UITableViewCell {

    @IBOutlet weak var photoFriend: UIImageView!
    @IBOutlet weak var labelNameFriend: UILabel!
    @IBOutlet weak var onlineStatus: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            photoFriend.image = nil
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            
            if let url = imageURL {
                NetworkServices.shared.downloadImage (url: url, completion: { [weak self] (image) in
                    guard url == self?.imageURL else {return}
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    self?.photoFriend.image = image
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoFriend.layer.cornerRadius = 6
        photoFriend.clipsToBounds = true
    }
}

