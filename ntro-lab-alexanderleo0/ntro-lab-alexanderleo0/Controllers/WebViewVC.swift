//
//  WebViewVC.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 04.02.2023.
//

import UIKit
import WebKit

class WebViewVC: UIViewController {
    
    var webView : WKWebView!
    var urlString: String? 
    
    override func loadView() {
        // Подготавливаем наш ВебВью
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // заставлем его работать
        webView.frame = view.bounds
        if let urlString = self.urlString, let url = URL(string: urlString){
            let myRequest = URLRequest(url: url)
            self.webView.load(myRequest)
        }
        
    }
    
}
