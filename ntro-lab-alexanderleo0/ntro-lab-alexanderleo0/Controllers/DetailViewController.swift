//
//  DetailViewController.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 04.02.2023.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: ScaledHeightImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var publicationDate: UILabel!
    @IBOutlet weak var publicationSource: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    
    var news : News?
    let webView = WKWebView()
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let news = news{
            newsTitle.text = news.title
            newsDescription.text = news.description
            publicationDate.text = news.publishedAt?.components(separatedBy: "T")[0]
            publicationSource.text = news.source.name
            urlButton.contentHorizontalAlignment = .left
            urlButton.setTitle(news.url, for: .normal)
           
        }
        imageView.image = image
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func runWebView(_ sender: Any) {
        
        let webViewVC = WebViewVC()
        webViewVC.urlString = news?.url
        navigationController?.show(webViewVC, sender: nil)
//        navigationController?.pushViewController(webViewVC, animated: true)
//        present(webViewVC, animated: true)
        
    }
    
}

class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {

        if let myImage = image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
 
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }

        return CGSize(width: -1.0, height: -1.0)
    }

}
