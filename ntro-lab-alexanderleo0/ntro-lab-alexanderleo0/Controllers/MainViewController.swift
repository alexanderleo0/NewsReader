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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Тут настраиваем работу и вид таблички
        title = "NEWS"
        tableView.delegate = self
        tableView.dataSource = self
        // регистрируем новую ячейку с новостями
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        
        //Добавляем pulltorefresh
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        //Настраиваем и запускаем сетевого менеджера, что бы получить новости и картинки
        networkManager.delegate = self
        networkManager.fetchNews(isPagination: false)
//        networkManager.loadNews()
    }
    
    // просто пробуем еще раз запросить новости
    @objc func pullToRefresh(sender: UIRefreshControl){
        print("Потянули для обновления")
        networkManager.fetchNews(isPagination: false)
    }
    
    //Методы делегата нашего манагера
    func updateData() {
        tableView.reloadData()
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
    }

    func fetchError(title: String, text: String) {
        //Так как нам прилетают ошибки из замыкания, кидаем все в основной поток
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("Новостей к отображению: \(networkManager.news_CD.count)")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News_ent")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        return (try? networkManager.managedContext.count(for: fetchRequest)) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! CellViewController
        // для удобства написания длинного текста создадим укороченную версию
//        let fromNews = networkManager.news_CD[indexPath.row]
//        cell.newsTitle =
//
//        //Заполяем все данные по ячейке
//        cell.newsTitle.text = fromNews.entity
//        // Если данных о количестве прочтений нет, то значит еще не читали ее, ставим 0
//        if let title = fromNews.title, let counter = networkManager.newsReadCounter[title] {
//            cell.newsReadCounter.text = "\(counter)"
//        } else {
//            cell.newsReadCounter.text = "0"
//        }
//        // Если у нас нет картинки, то поставим заглушку
//        if let url = fromNews.urlToImage, let imgData = networkManager.imagesForNews[url] {
//            cell.newsImage.image = UIImage(data: imgData)
//        }else {
//            cell.newsImage.image = UIImage(named: "noImg")
//        }
//
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let detailVC = DetailViewController()
//        // Закидываем новость в контроллер, разбираться будем в нем
//        detailVC.news = networkManager.news[indexPath.row]
//
//        //Если картинки нет, то и не будем ее ставить, не хочу захломлять вид
//        if let imgData = networkManager.imagesForNews[detailVC.news!.urlToImage ?? ""] {
//            detailVC.image = UIImage(data: imgData)
//        }
//        //Если у нас есть уже счетчик, то прибавляем 1, если нет, то саписываем его
//        if let newsTitle = networkManager.news[indexPath.row].title {
//            if networkManager.newsReadCounter[newsTitle] != nil {
//                networkManager.newsReadCounter[newsTitle]! += 1
//            } else {
//                networkManager.newsReadCounter[newsTitle] = 1
//            }
//        }
//        networkManager.saveReadingCounter()
//        navigationController?.pushViewController(detailVC, animated: true)
//        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension MainViewController: UIScrollViewDelegate {
    // создаем футер для таблички
    func createSpinerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        let spiner = UIActivityIndicatorView()
        spiner.center = footerView.center
        footerView.addSubview(spiner)
        spiner.startAnimating()
        
        return footerView
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let position = scrollView.contentOffset.y
//        if position > tableView.contentSize.height + 100 - scrollView.frame.size.height  {
//            // если начинаем запрашивать данные, включаем спинер
//            self.tableView.tableFooterView = createSpinerFooter()
//            print("мы немного прокрутили список, нужно показать нижний футер")
//            networkManager.fetchNews(isPagination: true)
//            
//        }
//    }
}
