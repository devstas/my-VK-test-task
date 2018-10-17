//
//  FriendsListViewController.swift
//  VKtest
//
//  Created by Станислав Серов on 28.09.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//

import UIKit

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FriendsListDelegate {
    
    var vk = VkAPI()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vk.delegate = self
        vk.loadToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if vk.token != nil {
            vk.getFriendsList()
        } else {
            perform(#selector(presentAuthorizationVC), with: nil, afterDelay: 0)
        }
    }
    
    @objc func presentAuthorizationVC() {
        let authorizationVC = storyboard?.instantiateViewController(withIdentifier: "AuthorizationVC") as! AuthorizationViewController
        authorizationVC.vk = self.vk
        present(authorizationVC, animated: false, completion: nil)
    }
    
    // MARK: - Delegate VK methods
    func showFriendList() {
        tableView.reloadData()
    }
    
    func presentMaxPhotoVC(photoInfo: String) {
        let photoViewController = storyboard?.instantiateViewController(withIdentifier: "idPhotoVC") as! PhotoViewController
        photoViewController.modalTransitionStyle = .flipHorizontal
        photoViewController.vk = self.vk
        photoViewController.photoInfo = photoInfo
        self.present(photoViewController, animated: true, completion: nil)
    }
    
    func handlerVkError(vkError: VkError) {
        print("[vkError]: code = \(String(vkError.error_code)), descript = \(vkError.error_msg)")
        
        if vkError.error_code == 5 {   //user not authorization
            let authorizationVC = storyboard?.instantiateViewController(withIdentifier: "AuthorizationVC") as! AuthorizationViewController
            present(authorizationVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vk.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idFriendCell", for: indexPath) as! FriendViewCell
        cell.photoFriend.tag = indexPath.row
        
        let firstName = vk.friendList[indexPath.row].first_name
        let lastName = vk.friendList[indexPath.row].last_name
        cell.labelNameFriend.text = firstName + lastName
        cell.imageURL = URL(string: vk.friendList[indexPath.row].photo_100)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewPhoto(_ :)))
        cell.photoFriend.addGestureRecognizer(tapGestureRecognizer)
        cell.photoFriend.isUserInteractionEnabled = true
        cell.onlineStatus.backgroundColor = vk.friendList[indexPath.row].online == 1 ? #colorLiteral(red: 0.4043194056, green: 0.7807696462, blue: 0.07839594036, alpha: 1) : UIColor.clear
        return cell
    }
    
    @objc func viewPhoto(_ sender: AnyObject) {
        vk.idSelectedPhoto = sender.view.tag
        vk.getPhotoInfo()
    }
}





