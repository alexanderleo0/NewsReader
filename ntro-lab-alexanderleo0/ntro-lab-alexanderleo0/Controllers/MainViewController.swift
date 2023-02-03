//
//  ViewController.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 03.02.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var news : [News] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        title = "MainVC"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
//        tableView.rowHeight = UITableView.automaticDimension
        
        fetchData()
    }
    
    func fetchData() {
        if let url = URL(string: "https://newsapi.org/v2/everything?q=apple&pageSize=20&sortBy=popularity&apiKey=4655c692109143a0a81ced3d538d5a95") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let data = data {
                        do {
                            let results = try decoder.decode(ListOfNews.self, from: data)
                            self.news = results.articles
                            self.addImgs()
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            //                            print(self.news)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }

    }
    
    func addImgs(){
        for (index, oneNews) in self.news.enumerated() {
            print("Start download img")
            if let url = URL(string: oneNews.urlToImage) {
                let imgSession = URLSession(configuration: .default)
                let dataTask = imgSession.dataTask(with: url) {  data, response, error in
                    if let data = data {
//                        print(data)
                        print(response?.suggestedFilename ?? url.lastPathComponent)
                        print("Download Finished")
                        if let img = UIImage(data: data) {
                            self.news[index].image = img
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                dataTask.resume()
            }
        }
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! CellViewController
        cell.newsTitle.text = news[indexPath.row].title
        cell.newsReadCounter.text = "\(news[indexPath.row].readCounter)"
//        cell.newsImage.sizeToFit()
//        cell.newsImage.layoutIfNeeded()
      
        cell.newsImage.image = news[indexPath.row].image
    
        
        return cell
    }
    
    
    
    
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
