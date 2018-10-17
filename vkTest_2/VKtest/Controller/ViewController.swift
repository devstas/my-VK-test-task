//
//  ViewController.swift
//  VKtest
//
//  Created by Devolper on 01.06.18.
//  Copyright © 2018 Devolper. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsListDelegate  {
    
    let vk = VkAPI()
    
    let friendsTableView = UITableView()
    let photoView = UIImageView()
    
    let idCell = "idFriendCell"
    var framePhotoInCell = CGRect()
    
    lazy var authorizationView: WKWebView = {
        let webView = WKWebView()
        print("Получаем token ...")
        webView.navigationDelegate = self
        webView.frame = self.view.frame
        webView.load(URLRequest(url: vk.getUrlForAuthorization()))
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.frame = self.view.bounds
        friendsTableView.allowsSelection = false
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        let nib = UINib(nibName: "FriendViewCell", bundle: nil)
        friendsTableView.register(nib, forCellReuseIdentifier: idCell)
        friendsTableView.separatorColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        
        vk.delegate = self
        vk.loadToken()
        if vk.token == nil {
            self.view.addSubview(authorizationView)
        } else {
            vk.getFriendsList()
        }
    }
    
    // MARK: - Delegate methods
    func showFriendList() {
        self.view.addSubview(friendsTableView)
        friendsTableView.reloadData()
    }
    
    func presentMaxPhotoVC(photoInfo: String) {
        photoView.contentMode = .scaleAspectFill
        photoView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeViewPhoto(_ :)))
        photoView.addGestureRecognizer(tapGestureRecognizer)
        photoView.isUserInteractionEnabled = true
        
        let indexPath = IndexPath(row: vk.idSelectedPhoto!, section: 0)
        let cell = self.friendsTableView.cellForRow(at: indexPath) as! FriendViewCell
        framePhotoInCell = (cell.photoFriend.superview?.convert(cell.photoFriend.frame, to: nil)) ?? self.view.frame
        //TODO проверить размеры фрейма
        //framePhotoInCell.size
        photoView.frame = framePhotoInCell
        
        print("w=\(photoView.frame.size.width)    h=\(photoView.frame.size.height)")
        
        view.addSubview(photoView)
        //animate
        UIView.transition(with: photoView, duration: 0.4, options: .curveEaseOut, animations: {
            self.photoView.frame = self.view.bounds
        }, completion: {finish in
            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light) )
            self.photoView.addSubview(blurEffectView)
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
            blurEffectView.bottomAnchor.constraint(equalTo: self.view.superview!.bottomAnchor, constant: -30).isActive = true
            blurEffectView.leftAnchor.constraint(equalTo: self.view.superview!.leftAnchor, constant: 20).isActive = true
            blurEffectView.rightAnchor.constraint(equalTo: self.view.superview!.rightAnchor, constant: -20).isActive = true
            
            let labelPhotoInfo = UILabel()
            labelPhotoInfo.numberOfLines = 0
            labelPhotoInfo.lineBreakMode = .byWordWrapping
            labelPhotoInfo.textAlignment = .center
            labelPhotoInfo.text = photoInfo
            
            blurEffectView.contentView.addSubview(labelPhotoInfo)
            
            labelPhotoInfo.translatesAutoresizingMaskIntoConstraints = false
            labelPhotoInfo.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor, constant: 6).isActive = true
            labelPhotoInfo.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor, constant: -6).isActive = true
            labelPhotoInfo.leftAnchor.constraint(equalTo: blurEffectView.contentView.leftAnchor, constant: 6).isActive = true
            labelPhotoInfo.rightAnchor.constraint(equalTo: blurEffectView.contentView.rightAnchor, constant: -6).isActive = true
        })
    }
    
    @objc func closeViewPhoto(_ sender: AnyObject) {
        sender.view.subviews.forEach({ $0.removeFromSuperview() })
        UIView.transition(with: sender.view, duration: 0.4, options: .curveEaseOut, animations: {
            sender.view.frame = self.framePhotoInCell
        }) {(finish) in
            if finish { sender.view.removeFromSuperview() }
        }
    }

    
    func handlerVkError(vkError: VkError) {
        print("[vkError]: code = \(String(vkError.error_code)), descript = \(vkError.error_msg)")
        
        if vkError.error_code == 5 {   //user not authorization
            self.view.addSubview(authorizationView)
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vk.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: idCell, for: indexPath) as! FriendViewCell
        let firstName = vk.friendList[indexPath.row].first_name
        let lastName = vk.friendList[indexPath.row].last_name
        cell.labelNameFriend.text = "\(firstName) \(lastName)"
        cell.imageURL = URL(string: vk.friendList[indexPath.row].photo_100)
        cell.photoFriend.tag = indexPath.row
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewPhoto(_ :)))
        cell.photoFriend.addGestureRecognizer(tapGestureRecognizer)
        cell.photoFriend.isUserInteractionEnabled = true
        cell.onlineStatus.backgroundColor = vk.friendList[indexPath.row].online == 1 ? #colorLiteral(red: 0.4043194056, green: 0.7807696462, blue: 0.07839594036, alpha: 1) : UIColor.clear
        return cell
    }
    
    @objc func viewPhoto(_ sender: AnyObject) {
        vk.idSelectedPhoto = sender.view.tag
        guard let maxPhoto = vk.friendList[sender.view.tag].photo_max_orig else {return}
        guard let urlImage = URL(string: maxPhoto) else {return}
        NetworkServices.shared.downloadImage(url: urlImage) { (image) in
            self.photoView.image = image
        }
        vk.getPhotoInfo()
    }
}

// MARK: - Extension WebKit
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url, url.path == "/blank.html" else {
            decisionHandler(.allow)
            return
        }
        if let token = url.getValue(for: "access_token") {
            print("Получен token: \(token)")
            vk.saveToken(token)
            vk.getFriendsList()
            webView.removeFromSuperview()
        }
        decisionHandler(.cancel)
    }
}


