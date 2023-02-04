//
//  NetworkManager.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 04.02.2023.
//

import Foundation
import UIKit

class NetworkManager {
    
    var news : [News] = []
    
    var delegate: NetworkManagerDelegate?
    
    func fetchNews() {
        print("Start fetching news")
        if let url = URL(string: "https://newsapi.org/v2/everything?q=apple&pageSize=20&sortBy=popularity&apiKey=4655c692109143a0a81ced3d538d5a95") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let data = data {
                        do {
                            let results = try decoder.decode(ListOfNews.self, from: data)
                            self.news = results.articles
                            self.fetchImgs()
                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
                                self.delegate?.updateData()
                                print(self.news.count)
                            }
                        } catch {
                            // Написать красивый обработчик ошибки загрузки данных из сети
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    private func fetchImgs(){
        for (index, oneNews) in self.news.enumerated() {
            if let url = URL(string: oneNews.urlToImage) {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) {  data, response, error in
                    if error == nil {
                        if let data = data {
                            if let img = UIImage(data: data) {
                                self.news[index].image = img
                                DispatchQueue.main.async {
//                                    self.tableView.reloadData()
                                    self.delegate?.updateData()
                                }
                            }
                        }
                        
                    }
                }
                task.resume()
            }
        }
    }
}

protocol NetworkManagerDelegate {
    func updateData()
}
