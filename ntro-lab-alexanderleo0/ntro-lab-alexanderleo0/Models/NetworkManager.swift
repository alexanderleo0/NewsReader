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
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var managedContext : NSManagedObjectContext
    
    var newsPage = 1
    var searchString = "russia"
    
    var APIKEY = "4655c692109143a0a81ced3d538d5a95"
    
    private var news : [News] = []
    var fatchedNews : [News] {
        get {
            //            print("Считываем значения")
            return news
        }
        set {
            //            print("Присваиваем новые значения")
            news = newValue
            delegate?.updateData(isUpdate: true)
        }
    }
    
    private var fetchStatus = false
    var fetchIsStarting : Bool {
        get {
            return fetchStatus
        }
        set {
//            print("Поменяли табличку на \(newValue)")
            fetchStatus = newValue
        }
    }
    
    init() {
        self.managedContext = (appDelegate?.persistentContainer.viewContext)!
        //        fetchNews()
        loadFromCoreData()
    }
    
    func saveToCoreData(){
        dropObjectsFromCoreData(entityStr: "News_ent")
        dropObjectsFromCoreData(entityStr: "SearchString")
        let searchString = SearchString(context: self.managedContext)
        searchString.searchStr = self.searchString
        
        for oneNews in fatchedNews {
            let newsEnt = News_ent(context: self.managedContext)
            newsEnt.title = oneNews.title
            newsEnt.urlToImage = oneNews.urlToImage
            newsEnt.image = oneNews.imageData
            newsEnt.publishedAt = oneNews.publishedAt
            newsEnt.url = oneNews.url
            newsEnt.readCounter = Int32(News_counter.shared.counter[oneNews.title ?? ""] ?? 0)
            newsEnt.descript = oneNews.description
            newsEnt.sourceID = oneNews.source?.id ?? ""
            newsEnt.sourceName = oneNews.source?.name ?? ""
        }
        self.saveContext()
    }
    
    func loadFromCoreData() {
        let searchRequest = NSFetchRequest<SearchString>(entityName: "SearchString")
        
//        print("Пробуем загрузить данные из памяти")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News_ent")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        do{
            let newsFromCoreData = try managedContext.fetch(fetchRequest)
            let str = try managedContext.fetch(searchRequest).first?.searchStr
            self.searchString = str ?? "russia"
//            print(try managedContext.fetch(searchRequest).first as? String ?? "russia")
            var newsArray : [News] = []
            for oneNewsFromCoreData in newsFromCoreData {
                
                if let oneNewsFromCoreData = oneNewsFromCoreData as? News_ent {
                    let oneNews = News()
                    oneNews.title = oneNewsFromCoreData.title
                    oneNews.urlToImage = oneNewsFromCoreData.urlToImage
                    oneNews.imageData = oneNewsFromCoreData.image
                    oneNews.url = oneNewsFromCoreData.url
                    oneNews.publishedAt = oneNewsFromCoreData.publishedAt
                    oneNews.description = oneNewsFromCoreData.descript
                    oneNews.source = NewsSource(id: oneNewsFromCoreData.sourceID, name: oneNewsFromCoreData.sourceName)
                    News_counter.shared.counter[oneNews.title ?? ""] = Int(oneNewsFromCoreData.readCounter)
                    //                    fatchedNews.append(oneNews)
                    //                    print(oneNewsFromCoreData.image!)
                    newsArray.append(oneNews)
                }
            }
            fatchedNews.append(contentsOf: newsArray)
        }  catch {
            print("Cannot fetch News from CoreData \(error)")
        }
    }
    
    func dropObjectsFromCoreData(entityStr: String){
        let dropFetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityStr)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: dropFetch)
        do {
//            print("Удаляем данные из CoreData")
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            print("Не смог удалить все данные из CoreData: \(error)")
        }
    }
    
    private func saveContext() {
        do {
//            print("Пробуем сохранить контекст с новостями")
            try self.managedContext.save()
        } catch let error as NSError {
            print("У нас произошла ошибка \(error), вот с таким описанием: \(error.userInfo)")
        }
    }
    
    private func getImages(forNews fatchedNews: [News]) {
        //        if isPaging {
        //            self.fatchedNews = fatchedNews
        //        }
        for oneNews in fatchedNews {
            if oneNews.imageData == nil {
                if let urlToImg = oneNews.urlToImage, let url = URL(string: urlToImg) {
                    let session = URLSession(configuration: .default)
                    
                    let task = session.dataTask(with: url) {data, response, error in
                        if let data = data, error == nil {
                            oneNews.imageData = data
                            self.delegate?.updateData(isUpdate: true)
                        }
                    }
                    task.resume()
                }
            }
            delegate?.updateData(isUpdate: false)
        }
    }
    
    // Загружаем новости из сети и сразу сохраняем их в CoreData
    func fetchNews(isPaging: Bool = false) {
        if fetchIsStarting {
//            print("Уже запрашиваем новости, подожди немного!")
            delegate?.updateData(isUpdate: false)
            return
        }else {
            //Если пошли в работу, ставим "Занято"
//            print("Поставил табличку занято")
            fetchIsStarting = true
            if isPaging {
                newsPage += 1
            } else {
                newsPage = 1
            }
        }
//        print("\n\nЗапрашиваем данные с страницы №\(newsPage)\n\n")
        let srchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "r"
        let urlString = "https://newsapi.org/v2/everything?q=\(srchString)&pageSize=20&sortBy=publishedAt&page=\(newsPage)&apiKey=\(APIKEY)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let data = data {
                        do {
                            let tmpNews = try decoder.decode(ListOfNews.self, from: data).articles
                            if isPaging {
                                for oneNews in tmpNews {
                                    if !self.fatchedNews.contains(where: { new in
                                        new.title == oneNews.title
                                    }) {
                                        self.fatchedNews.append(oneNews)
                                    }
                                }
                            } else {
                                self.fatchedNews = tmpNews
                            }
                            self.getImages(forNews: tmpNews)
                            self.fetchIsStarting = false
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
}

protocol NetworkManagerDelegate {
    func updateData(isUpdate: Bool)
    func fetchError(title: String, text: String)
}
