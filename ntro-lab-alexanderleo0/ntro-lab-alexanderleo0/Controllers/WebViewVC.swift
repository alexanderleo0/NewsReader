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
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlString = self.urlString, let url = URL(string: urlString){
            let myRequest = URLRequest(url: url)
            self.webView.load(myRequest)
        }
        webView.frame = view.bounds
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
