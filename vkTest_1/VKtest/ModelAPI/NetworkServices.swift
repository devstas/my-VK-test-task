//
//  NetworkServices.swift
//  VKtest
//
//  Created by Станислав Серов on 28.09.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//


import UIKit

class NetworkServices {
    
    private init() {}
    static let shared  = NetworkServices()
    
    // MARK: - Send request
    func getData(urlRequest: URL, completion: @escaping (Data, VkError?) -> ()) {
        var vkError: VkError?
        let request = URLRequest(url: urlRequest)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("[HTTPRequest]: status code = \(httpStatus.statusCode)")
                return
            }
            
            vkError = nil
            if let decodeError = try? JSONDecoder().decode(JSONError.self, from: data) {
                vkError = decodeError.error
            }
            
            DispatchQueue.main.async {
                completion(data, vkError)
            }
        }.resume()
    }
    
    
    // MARK: - Download image
    private var imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(url: URL, useCache: Bool = true, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString), useCache {
            print("Load image from cache [for url]: \(url.absoluteString)")
            completion(cachedImage)
        } else {
            
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad , timeoutInterval: 20)
            
            URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard error == nil, data != nil else {return}
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {return}
                guard let image = UIImage(data: data!) else {return}
                if useCache {
                    self?.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                }
                
                DispatchQueue.main.async {
                    print("Load image from vk.com [for url]: \(url.absoluteString)")
                    completion(image)
                }
            }).resume()
        }
    }
    
}
