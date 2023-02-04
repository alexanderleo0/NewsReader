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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.loadNews()
        //Тут настраиваем работу и вид таблички
        title = "NEWS"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        
        //Добавляем pulltorefresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateNews), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        //Настраиваем и запускаем сетевого менеджера, что бы получить новости и картинки
        networkManager.delegate = self
        networkManager.fetchNews()
//        print("Понеслась")
    }
    
    
    @objc func updateNews(sender: UIRefreshControl){
//        print("printSomewhting")
        networkManager.fetchNews()
        sender.endRefreshing()
    }
    
    func updateData() {
        tableView.reloadData()
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkManager.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! CellViewController
        cell.newsTitle.text = networkManager.news[indexPath.row].title
        cell.newsReadCounter.text = "\(networkManager.news[indexPath.row].readCounter)"
        cell.newsImage.image = networkManager.news[indexPath.row].image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = DetailViewController()
        detailVC.news = networkManager.news[indexPath.row]
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        networkManager.news[indexPath.row].readCounter += 1
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}
