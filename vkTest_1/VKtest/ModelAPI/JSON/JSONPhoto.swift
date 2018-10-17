//
//  JSONStruct.swift
//  VKtest
//
//  Created by Станислав Серов on 12.10.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//

import Foundation

struct JSONPhoto: Decodable {
    var response: [MPhotoInfo]
}

struct MPhotoInfo: Decodable {
    let date: Int
    var likes: MLikes
    var reposts: MReposts
    var sizes: [MPhotoSize]?
    
    var photoInfo: String {
        return "Лайков: \(likes.count), Репостов: \(reposts.count) \n Дата: \(unixDateToStr(date: date))"
    }
    
    func unixDateToStr(date: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(date))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
}

struct MPhotoSize: Decodable {
    var url: String?
}

struct MLikes: Decodable {
    let count: Int
}

struct MReposts: Decodable {
    let count: Int
}

