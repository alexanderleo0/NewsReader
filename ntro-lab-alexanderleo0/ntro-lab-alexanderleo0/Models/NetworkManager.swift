//
//  NetworkManager.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 04.02.2023.
//

import Foundation
import UIKit
import CoreData

class NetworkManager {
    
    static let shared = NetworkManager()
    var delegate: NetworkManagerDelegate?
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var managedContext : NSManagedObjectContext
    
    var curentNews : [News_ent] = []
    
    init() {
        self.managedContext = (appDelegate?.persistentContainer.viewContext)!
        fetchNewsFromCoreData(newsPage: 1)
    }
    
    func dropObjectsFromCoreData(){
        let dropFetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "News_ent")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: dropFetch)
        do {
            print("Удаляем данные из CoreData")
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Не смог удалить все данные из CoreData: \(error)")
        }
        delegate?.updateData()
    }
    
    func fetchNewsFromCoreData(newsPage: Int) {
        let fetchRequest = NSFetchRequest<News_ent>(entityName: "News_ent")
        let sort = NSSortDescriptor(key: #keyPath(News_ent.publishedAt), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchOffset = newsPage - 1
        fetchRequest.fetchLimit = 20
        do {
            let news = try managedContext.fetch(fetchRequest)
            return curentNews = news
        } catch {
            print("Cannot fetch News from CoreData")
        }
    }
    
    func saveContext() {
        do {
            print("Пробуем сохранить контекст с новостями")
            try self.managedContext.save()
        } catch let error as NSError {
            print("У нас произошла ошибка \(error), вот с таким описанием: \(error.userInfo)")
        }
    }
    
    private func parseJSONtoEntity(fetchNews: [News]) {
        for oneNews in fetchNews {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News_ent")
            let predicate = NSPredicate(format: "title = %@", oneNews.title ?? "no title")
            fetchRequest.predicate = predicate
            do {
                let results = try managedContext.fetch(fetchRequest) as! [News_ent]
                if results.count == 0 {
                    let newsEnt = News_ent(context: self.managedContext)
                    newsEnt.title = oneNews.title
                    newsEnt.descript = fetchNews.description
                    let formatter = ISO8601DateFormatter()
                    
                    newsEnt.publishedAt = formatter.date(from: oneNews.publishedAt!)!
                    print(formatter.date(from: oneNews.publishedAt!)!)
                    newsEnt.url = oneNews.url
                    newsEnt.urlToImage = oneNews.urlToImage
                    
                    if let urlToImg = oneNews.urlToImage, let url = URL(string: urlToImg) {
                        let session = URLSession(configuration: .default)
                        
                        let task = session.dataTask(with: url) {data, response, error in
                            if let data = data, error == nil {
                                //Добавляем в наш словарик с картинкам данные и сразу сохраняем его
                                newsEnt.image = data
                                print(data)
                                self.delegate?.updateData()
                                self.saveContext()
                            }
                        }
                        task.resume()
                    }
                    saveContext()
                }
            } catch let error as NSError {
                print("Ошибочка вышла при запросе новости в архиве с параметрами. Код ошибки \(error), \(error.userInfo)")
                return
            }
        }
    }
    
    // Загружаем новости из сети и сразу сохраняем их в CoreData
    var fetchIsStarting = false
    
    func fetchNews(newsPage: Int = 1) {
        if fetchIsStarting {
            //Если уже чего то загружаем, то просто выходим
            print("Уже запрашиваем новости, подожди немного!")
            return
        }else {
            //Если пошли в работу, ставим "Занято"
            print("Поставил табличку занято")
            fetchIsStarting = true
        }
        var urlString: String!

        urlString = "https://newsapi.org/v2/everything?q=russia&pageSize=20&sortBy=publishedAt&page=\(newsPage)&apiKey=4655c692109143a0a81ced3d538d5a95"
   
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let data = data {
                        do {
                            let results = try decoder.decode(ListOfNews.self, from: data)
                            self.parseJSONtoEntity(fetchNews: results.articles)
                        } catch {
                            // У нас проблемы с парсингом, прилетела какая то фигня
                            self.delegate?.fetchError(title: "Ошибка", text: "Данные полученные с сервера содержат ошибки")
                            print(error)
                            self.fetchIsStarting = false
                        }
                    }
                } else {
                    self.fetchIsStarting = false
                    self.delegate?.fetchError(title: "Ошибка сети", text: "Невозможно получить новости от сервера")
                }
            }
            task.resume()
        } else {
            self.delegate?.fetchError(title: "Ошибка", text: "Ошибка в написании URL сайта")
            self.fetchIsStarting = false
        }
    }
    //
    //
    //
    
    
    //    // Сохраняем данные о количестве прочтений
    //    func saveReadingCounter (){
    //        defaults.set(newsReadCounter, forKey: "newsReadCounter")
    //    }
    //
    //    // Сохраняем изображения от новостей
    //    func saveImages(){
    //        defaults.set(imagesForNews, forKey: "imagesForNews")
    //    }
    //
    //    // Сохраняем новости
    //    func saveTextNews(){
    //        let encoder = JSONEncoder()
    ////        defaults.set(newsReadCounter, forKey: "newsReadCounter")
    //        if let encoded = try? encoder.encode(news) {
    //            defaults.set(encoded, forKey: "news")
    //        }
    //    }
    //
    //    // Загружаем новости по порядку: счетчик прочтений / изображения / новости / запускаем загрузку новых новостей
    //    func loadNews(){
    //        news = []
    //        if let newsRC = defaults.object(forKey: "newsReadCounter") as? [String:Int] {
    //            self.newsReadCounter = newsRC
    //        }
    //        if let imgsFN = defaults.object(forKey: "imagesForNews") as? [String:Data] {
    //            self.imagesForNews = imgsFN
    //        }
    //        if let loadDataNews = defaults.object(forKey: "news") as? Data {
    //            let decoder = JSONDecoder()
    //            if let loadNews = try? decoder.decode([News].self, from: loadDataNews) {
    //                self.news = loadNews
    //                delegate?.updateData()
    //                self.fetchNews(isPagination: false)
    //            }
    //        }
    //    }
    
    //    // переменная, которая хранит в себе информацию, что работа по загрузке уже началась
    //    // TODO: - написать управление сессиями
    //    var fetchIsStarting = false
    //    func fetchNews(isPagination: Bool) {
    //        if fetchIsStarting {
    //            //Если уже чего то загружаем, то просто выходим
    //            return
    //        }else {
    //            //Если пошли в работу, ставим "Занято"
    //            fetchIsStarting = true
    //        }
    //        var urlString: String!
    //        if isPagination {
    ////            print("Запрашиваем новости со страницы =======================>\(news.count/20+1)" )
    //
    //            urlString = "https://newsapi.org/v2/everything?q=russia&pageSize=20&sortBy=publishedAt&page=\(news.count/20+1)&apiKey=4655c692109143a0a81ced3d538d5a95"
    //        } else {
    //            urlString = "https://newsapi.org/v2/everything?q=russia&pageSize=20&sortBy=publishedAt&apiKey=4655c692109143a0a81ced3d538d5a95"
    //        }
    //        if let url = URL(string: urlString) {
    //            let session = URLSession(configuration: .default)
    //            let task = session.dataTask(with: url) {[weak self] data, response, error in
    //                if error == nil {
    //                    let decoder = JSONDecoder()
    //                    if let data = data {
    //                        do {
    //                            let results = try decoder.decode(ListOfNews.self, from: data)
    //                            if isPagination {
    //                                //Если у нас идет пегинация, то добавляем список новостей
    //                                self?.news.append(contentsOf: results.articles)
    //                            } else {
    //                                //Если это обновление, то новости заменяем
    //                                self?.news = results.articles
    //                            }
    //                            // Сохраняем новости и запрашиваем для них изображения, снимаем табличку Занято
    //                            self?.saveTextNews()
    //                            self?.fetchImgs(news: results.articles)
    //                            self?.fetchIsStarting = false
    //                            DispatchQueue.main.async {
    //                                self?.delegate?.updateData()
    //                            }
    //                        } catch {
    //                            // У нас проблемы с парсингом, прилетела какая то фигня
    //                            self?.delegate?.fetchError(title: "Ошибка", text: "Данные полученные с сервера содержат ошибки")
    //                            print(error)
    //                            self?.fetchIsStarting = false
    //                        }
    //                    }
    //                } else {
    //                    self?.fetchIsStarting = false
    //                    self?.delegate?.fetchError(title: "Ошибка сети", text: "Невозможно получить новости от сервера")
    //                }
    //            }
    //            task.resume()
    //        } else {
    //            self.delegate?.fetchError(title: "Ошибка", text: "Ошибка в написании URL сайта")
    //            self.fetchIsStarting = false
    //        }
    //    }
    //
    //    //в этом методе показывать пользователю ошибки не будем, что бы не портить пользовательский опыт
    //    private func fetchImgs(news: [News]){
    //        for oneNews in news {
    //            if let urlToImg = oneNews.urlToImage, let url = URL(string: urlToImg) {
    //                // Если мы уже загружали эту картинку, то ничего делать не будем
    //                if !imagesForNews.keys.contains(urlToImg){
    //                    let session = URLSession(configuration: .default)
    //                    let task = session.dataTask(with: url) {[weak self]  data, response, error in
    //                        if let data = data, error == nil {
    //                            //Добавляем в наш словарик с картинкам данные и сразу сохраняем его
    //                            self?.imagesForNews[urlToImg] = data
    //                            self?.saveImages()
    //                            DispatchQueue.main.async {
    //                                self?.delegate?.updateData()
    //                            }
    //                        } else{
    //                            // Пришла какая-то фигня вместо картинки
    //                        }
    //                    }
    //                    task.resume()
    //                }
    //            } else {
    //                //Ошибка в URL картинки
    //            }
    //        }
    //    }
}

protocol NetworkManagerDelegate {
    func updateData()
    func fetchError(title: String, text: String)
}
