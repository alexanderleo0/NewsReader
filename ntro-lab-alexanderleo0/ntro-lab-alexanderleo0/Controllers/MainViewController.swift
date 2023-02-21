//
//  ViewController.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 03.02.2023.
//

import UIKit
import CoreData

class MainViewController: UIViewController, NetworkManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var networkManager = NetworkManager.shared
    let refreshControl = UIRefreshControl()
//    var newsPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = networkManager.searchString
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tableView.register(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        networkManager.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.magnifyingglass"), style: .plain, target: self, action:  #selector(changeSearchString))
//        UIBarButtonItem(title: "Drop", style: .plain, target: self, action: #selector(resetData))
    }
    
    @objc func changeSearchString(){
        let alertController = UIAlertController(title: "Ключевые слова", message: "По каким ключевым словам будем искать новости?", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Искать", style: .default) {_ in
            let searchText = alertController.textFields![0].text
            self.networkManager.searchString = searchText ?? "russia"
            self.networkManager.fetchNews()
            self.title = searchText ?? "russia"
        }
        alertController.addTextField()
        alertController.addAction(action)
        present(alertController, animated: true)
        

    }

    @objc func pullToRefresh(sender: UIRefreshControl){
        print("Потянули для обновления")
        networkManager.fetchNews()
    }
    

    func updateData(isUpdate: Bool) {
        DispatchQueue.main.async {
            if isUpdate {
                self.tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
            self.tableView.tableFooterView = nil
        }
    }
    
    func fetchError(title: String, text: String) {

        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            self.refreshControl.endRefreshing()
            self.tableView.tableFooterView = nil
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if networkManager.fatchedNews.count == 0 {
            return 1
        } else {
            return 2
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return networkManager.fatchedNews.count
        }
        else {
            return 1
        }
  
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! CellViewController
            let oneNews = networkManager.fatchedNews[indexPath.row]
            cell.newsTitle.text = oneNews.title
            if let imgData = oneNews.imageData {
                cell.newsImage.image = UIImage(data: imgData)
            } else {
                cell.newsImage.image = UIImage(named: "noImg")
            }
            cell.newsReadCounter.text = "\(News_counter.shared.counter[oneNews.title ?? ""] ?? 0)"
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            cell.activityContoller.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            networkManager.fetchNews(isPaging: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        // Закидываем новость в контроллер, разбираться будем в нем
        detailVC.news = networkManager.fatchedNews[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        if let title = networkManager.fatchedNews[indexPath.row].title {
            if News_counter.shared.counter[title] == nil {
                News_counter.shared.counter[title] = 1
            } else {
                News_counter.shared.counter[title]! += 1
            }
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.reloadData()
    }
}
