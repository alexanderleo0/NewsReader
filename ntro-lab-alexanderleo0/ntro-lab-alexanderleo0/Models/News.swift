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

class News: Decodable {

    var title : String?
    var description : String?
    var url : String?
    var urlToImage: String?
    var publishedAt : Date?
    var source: NewsSource?
    var imageData: Data?
}

struct NewsSource: Decodable {
    let id : String?
    let name : String?
}

class News_counter: Codable {
    static let shared = News_counter()
    var counter : [String : Int] = [:]
}
