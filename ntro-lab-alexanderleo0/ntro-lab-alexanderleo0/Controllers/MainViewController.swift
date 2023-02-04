//
//  ViewController.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 03.02.2023.
//

import UIKit

class MainViewController: UIViewController, NetworkManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var networkManager = NetworkManager()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Тут настраиваем работу и вид таблички
        title = "NEWS"
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        
        //Добавляем pulltorefresh
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        //Настраиваем и запускаем сетевого менеджера, что бы получить новости и картинки
        networkManager.delegate = self
        networkManager.loadNews()
 
    }
    
    @objc func pullToRefresh(sender: UIRefreshControl){
        networkManager.fetchNews(isPagination: false)
        
    }
    
    func updateData() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkManager.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! CellViewController
        let fromNews = networkManager.news[indexPath.row]
        cell.newsTitle.text = fromNews.title
        
        if let title = fromNews.title, let counter = networkManager.newsReadCounter[title] {
            cell.newsReadCounter.text = "\(counter)"
        } else {
            cell.newsReadCounter.text = "0"
        }
        
        if let url = fromNews.urlToImage, let imgData = networkManager.imagesForNews[url] {
            cell.newsImage.image = UIImage(data: imgData)
        }else {
            cell.newsImage.image = UIImage(named: "noImg")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = DetailViewController()
        detailVC.news = networkManager.news[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
        
        if let imgData = networkManager.imagesForNews[detailVC.news!.urlToImage ?? ""] {
            detailVC.image = UIImage(data: imgData)
        }
        
        if let _ = networkManager.newsReadCounter[networkManager.news[indexPath.row].title!] {
            networkManager.newsReadCounter[networkManager.news[indexPath.row].title!]! += 1
        } else {
            networkManager.newsReadCounter[networkManager.news[indexPath.row].title!] = 1
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        networkManager.saveReadingCounter()
        
        
    }
    
}

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height - 100 - scrollView.frame.size.height {
            // fetch more data
           
            networkManager.fetchNews(isPagination: true)
        }
    }
}
