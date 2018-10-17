//
//  Extensions.swift
//  VKtest
//
//  Created by Станислав Серов on 28.09.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//

import UIKit


extension URL {
    func getValue(for key: String) -> String? {
        guard let url = URLComponents(url: self, resolvingAgainstBaseURL: false) else {return nil}
        guard let fragment = url.fragment else {return nil}
        guard let jurl = URLComponents(string: "https://oauth.vk.com/blank.html?\(String(fragment))") else {return nil}
        
        for item in jurl.queryItems! {
            if item.name == key {
                return item.value!
            }
        }
        return nil
    }
}


