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
//    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //готовим вид ячейки
        if let news = news{
            newsTitle.text = news.title
            newsDescription.text = news.description
            
            if let publishDate = news.publishedAt {
                let dateFormatter = DateFormatter()
//                dateFormatter.dateStyle = .full
                dateFormatter.dateFormat = "yyyy-MM-dd'  'HH:mm:ss"
                publicationDate.text = dateFormatter.string(from: publishDate)
            }
            
            publicationSource.text = news.source?.name ?? ""
            urlButton.contentHorizontalAlignment = .left
            urlButton.setTitle(news.url, for: .normal)
            if let img = news.imageData {
                imageView.image = UIImage(data: img)
            }
        }
       
    }
    
    // Показываем ВебВью, если нажали на ссылку
    @IBAction func runWebView(_ sender: Any) {
        let webViewVC = WebViewVC()
        webViewVC.urlString = news?.url
        navigationController?.show(webViewVC, sender: nil)
    }
}

