//
//  News.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 03.02.2023.
//

import Foundation
import UIKit

struct ListOfNews : Decodable{
    
    let articles : [News]
}

struct News : Codable {
    let author : String?
    let title : String?
    let description : String?
    let url : String?
    let urlToImage: String?
    private let publishedAt : String?
    var publishDate:String {
        get{
            publishedAt?.components(separatedBy: "T")[0] ?? "Дата не установлена"
        }
    }
    let source: NewsSource
        
    
    var readCounter : Int = 0
    var image = UIImage(named: "noImg")
    
    private enum CodingKeys: String, CodingKey {
           case author, title, description, url, urlToImage, publishedAt, source
       }
}

struct NewsSource: Codable {
    let id : String?
    let name : String?
}
