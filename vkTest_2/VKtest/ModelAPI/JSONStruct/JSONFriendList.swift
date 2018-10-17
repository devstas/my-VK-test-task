//
//  JSONFriendList.swift
//  VKtest
//
//  Created by Станислав Серов on 04.06.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//

import Foundation

struct JSONFriendList : Decodable {
    var response : JSONFriends
}

struct JSONFriends: Decodable {
    var count: Int
    var items: [Friend]?
}

struct Friend: Decodable {
    let id: Int
    let first_name: String
    let last_name: String
    let photo_100: String
    let photo_max_orig: String?
    let photo_id: String?
    let online: Int
}
