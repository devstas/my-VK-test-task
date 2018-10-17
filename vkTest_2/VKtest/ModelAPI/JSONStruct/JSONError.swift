//
//  JSONError.swift
//  VKtest
//
//  Created by Станислав Серов on 04.06.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//

import Foundation

struct JSONError: Decodable {
    let error: VkError
}

struct VkError : Decodable {
    let error_code: Int
    let error_msg: String
}
