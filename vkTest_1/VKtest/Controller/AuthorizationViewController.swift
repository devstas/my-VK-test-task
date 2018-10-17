//
//  AuthorizationViewController.swift
//  VKtest
//
//  Created by Станислав Серов on 28.09.18.
//  Copyright © 2018 Станислав Серов. All rights reserved.
//

import UIKit
import WebKit

class AuthorizationViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    weak var vk: VkAPI!
    
    private let urlVkAuthorize = "https://oauth.vk.com/authorize"
    private let paramAuthorize = [
        "client_id"     : "6489122",
        "redirect_uri"  : "https://oauth.vk.com/blank.html",
        "display"       : "mobile",
        "scope"         : "friends",
        "response_type" : "token",
        "lang"          : "0",
        "v"             : "5.78"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Получаем token ...")
        webView.navigationDelegate = self
        let url = getUrlRequest(url: urlVkAuthorize, parameters: paramAuthorize)
        webView.load(URLRequest(url: url))
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    private func getUrlRequest(url: String, parameters: [String: String]) -> URL {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        return components.url!
    }
}

extension AuthorizationViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url, url.path == "/blank.html" else {
            decisionHandler(.allow)
            return
        }
        guard let token = url.getValue(for: "access_token") else {
            decisionHandler(.cancel)
            return
        }
        
        print("Получен token: \(String(describing: token))")
        vk.saveToken(token)
        decisionHandler(.cancel)
        dismiss(animated: true, completion: nil)

    }
}
