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
        
        //Тут настраиваем работу и вид таблички
        title = "Apple NEWS"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        
        //Настраиваем и запускаем сетевого менеджера, что бы получить новости и картинки
        networkManager.delegate = self
        networkManager.fetchNews()
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
}

//extension UIColor {
//    static var random: UIColor {
//        return UIColor(
//            red: .random(in: 0...1),
//            green: .random(in: 0...1),
//            blue: .random(in: 0...1),
//            alpha: 1.0
//        )
//    }
//}
