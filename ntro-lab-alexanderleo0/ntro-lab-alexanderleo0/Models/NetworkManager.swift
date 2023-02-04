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
    var newsReadCounter = [String:Int]()
    var imagesForNews = [String:Data]()
    
    var delegate: NetworkManagerDelegate?
    let defaults = UserDefaults.standard
    //
    func saveReadingCounter (){
        defaults.set(newsReadCounter, forKey: "newsReadCounter")
    }
    
    func saveImages(){
        print("SAVE IMAGES")
        defaults.set(imagesForNews, forKey: "imagesForNews")
    }
    
    func saveTextNews(){
        let encoder = JSONEncoder()
        defaults.set(newsReadCounter, forKey: "newsReadCounter")
        if let encoded = try? encoder.encode(news) {
            defaults.set(encoded, forKey: "news")
            print("SAVED")
        }
    }
    
    
    func loadNews(){
        print("START LOADING")
        news = []
        if let newsRC = defaults.object(forKey: "newsReadCounter") as? [String:Int] {
            self.newsReadCounter = newsRC
            print("LOAD newsReadCounter")
//            print(newsReadCounter)
        }
        if let imgsFN = defaults.object(forKey: "imagesForNews") as? [String:Data] {
            self.imagesForNews = imgsFN
            print("LOAD imagesForNews")
//            print(imagesForNews)
        }
        if let loadDataNews = defaults.object(forKey: "news") as? Data {
            let decoder = JSONDecoder()
            if let loadNews = try? decoder.decode([News].self, from: loadDataNews) {
                self.news = loadNews
                print("LOAD")
                delegate?.updateData()
                self.fetchNews(isPagination: false)
            }
        }

    }
    
    var fetchIsStarting = false
    func fetchNews(isPagination: Bool) {
       
        if fetchIsStarting {
            return
        }else {
            print("Start Fetch Data")
            fetchIsStarting = true
        }
        print("NEWS COUNT =>>>>>> \(news.count)")
        var urlString: String!
        if isPagination {
        
            urlString = "https://newsapi.org/v2/everything?q=us&pageSize=20&page=\(news.count/20+1)&apiKey=4655c692109143a0a81ced3d538d5a95"
            print(urlString)
        } else {
            urlString = "https://newsapi.org/v2/everything?q=us&pageSize=20&apiKey=4655c692109143a0a81ced3d538d5a95"
            print(urlString)
        }
        if let url = URL(string: urlString) {

            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {[weak self] data, response, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let data = data {
                        do {
                            let results = try decoder.decode(ListOfNews.self, from: data)
                            if isPagination {
                                self?.news.append(contentsOf: results.articles)
                            } else {
                                self?.news = results.articles
                                print(self?.news.count)
                            }
                            self?.saveTextNews()
                            self?.fetchImgs(news: results.articles)
                            
                            DispatchQueue.main.async {
                                self?.fetchIsStarting = false
                                self?.delegate?.updateData()
                            }
                        } catch {
                            // Написать красивый обработчик ошибки загрузки данных из сети
                            //                            print(error)
                        }
                    }
                } else {
                    print("Error with SESSION")
                    self?.fetchIsStarting = false
                    //                    print(error)
                }
            }
            task.resume()
        } else {
            print("Error with URL")
            self.fetchIsStarting = false
        }
        
    }
    
    private func fetchImgs(news: [News]){
        for oneNews in news {
            if let urlToImg = oneNews.urlToImage, let url = URL(string: urlToImg) {
                if !imagesForNews.keys.contains(urlToImg){
                    let session = URLSession(configuration: .default)
                    let task = session.dataTask(with: url) {[weak self]  data, response, error in
                        if let data = data, error == nil {
                            self?.imagesForNews[urlToImg] = data
                            self?.saveImages()
                            DispatchQueue.main.async {
                                self?.delegate?.updateData()
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
}

protocol NetworkManagerDelegate {
    func updateData()
}
