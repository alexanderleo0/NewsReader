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
    let defaults = UserDefaults.standard
    
    
    func saveNews(){
        print("START SAVING")
        let encoder = JSONEncoder()
        defaults.set(news.count, forKey: "count")
        for (index, oneNews) in news.enumerated() {
            if let encoded = try? encoder.encode(oneNews) {
                defaults.set(encoded, forKey: "\(index)")
            }
        }
    }
    
    func loadNews(){
        print("START LOADING")
        news = []
        let count = defaults.object(forKey: "count") as? Int
        if let count = count {
            for index in 0...count {
                if let oneNews = defaults.object(forKey: "\(index)") as? Data {
                    let decoder = JSONDecoder()
                    if let loadingNews = try? decoder.decode(News.self, from: oneNews) {
                        print(loadingNews.image.hashValue)
                        news.append(loadingNews)
                    }
                }
            }
            delegate?.updateData()
        }
    }
    
    func fetchNews() {
        
        //        print("Start fetching news")
        if let url = URL(string: "https://newsapi.org/v2/top-headlines?country=gb&apiKey=4655c692109143a0a81ced3d538d5a95") {
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
                                self.saveNews()
                            }
                        } catch {
                            // Написать красивый обработчик ошибки загрузки данных из сети
                            //                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    private func fetchImgs(){
        for (index, oneNews) in self.news.enumerated() {
            if let urlToImg = oneNews.urlToImage, let url = URL(string: urlToImg) {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) {  data, response, error in
                    if error == nil {
                        if let data = data {
                            if let img = UIImage(data: data) {
                                self.news[index].image = img
                                DispatchQueue.main.async {
                                    self.delegate?.updateData()
                                    self.saveNews()
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
