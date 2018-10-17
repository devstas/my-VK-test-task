//
//  VkontakteAPI.swift
//  VKtest
//
//  Created by Станислав Серов on 28.09.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//


import Foundation
import UIKit


protocol FriendsListDelegate: class {
    func handlerVkError(vkError: VkError)
    func showFriendList()
    func presentMaxPhotoVC(photoInfo: String)
}

class VkAPI {
    
    weak var delegate: FriendsListDelegate?
    
    var friendList = [Friend]()
    var idSelectedPhoto: Int!
    var token: String?
    let keyToken = "VkontakteToken"
    
    private let urlVkFriends = "https://api.vk.com/method/friends.get"
    private var paramFriendItems = [
        "fields"        : "first_name,last_name,photo_100,photo_max_orig,photo_id",
        "v"             : "5.78"]
    
    private let urlVkPhotos = "https://api.vk.com/method/photos.getById"
    private var paramPhoto = [
        "extended"      : "1",
        "photo_sizes"   : "1",
        "v"             : "5.78"]
    
    // MARK: - API methods
    func getPhotoInfo() {
        guard let photoId = friendList[idSelectedPhoto].photo_id else {return}
        paramPhoto["photos"] = photoId
        guard let token = self.token else {return}
        paramPhoto["access_token"] = token
        let urlRequest = getUrlRequest(url: urlVkPhotos, parameters: paramPhoto)
        
        NetworkServices.shared.getData(urlRequest: urlRequest) { [weak self] (data, vkError) in
            if let vkError = vkError {
                self?.delegate?.handlerVkError(vkError: vkError)
                return
            }
            
            if let decodePhoto = try? JSONDecoder().decode(JSONPhoto.self, from: data) {
                guard !decodePhoto.response.isEmpty else {return}
                let photoInfo = decodePhoto.response[0].photoInfo
                self?.delegate?.presentMaxPhotoVC(photoInfo: photoInfo)
            }
        }
    }
    
    func getFriendsList() {
        guard let token = self.token else {return}
        paramFriendItems["access_token"] = token
        let urlRequest = getUrlRequest(url: urlVkFriends, parameters: paramFriendItems)
        
        NetworkServices.shared.getData(urlRequest: urlRequest) { [weak self] (data, vkError) in
            if let vkError = vkError {
                self?.delegate?.handlerVkError(vkError: vkError)
                return
            }
            if let decodeFrinds = try? JSONDecoder().decode(JSONFriendList.self, from: data) {
                self?.friendList = (decodeFrinds.response.items)!
                self?.delegate?.showFriendList()
            }
        }
    }
    
    
    //MARK: - Token UserDefaults
    func loadToken() {
        if let token = UserDefaults.standard.string(forKey: keyToken) {
            self.token = token
            print("Load token from UserDefaults: \(String(describing: token))")
        } else {
            self.token = nil
        }
    }

    func saveToken(_ newToken: String) {
        self.token = newToken
        UserDefaults.standard.set(token, forKey: keyToken)
    }
    
    
    // MAKR: - private helper methods
    private func getUrlRequest(url: String, parameters: [String: String]) -> URL {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        return components.url!
    }
    
}

