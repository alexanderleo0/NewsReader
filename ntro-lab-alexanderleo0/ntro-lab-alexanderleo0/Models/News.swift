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
//    let id: UUID = UUID()
    let author : String?
    let title : String?
    let description : String?
    let url : String?
    let urlToImage: String?
    let publishedAt : String?
    let source: NewsSource
//    var image : Data?
    
//    private enum CodingKeys: String, CodingKey {
//           case author, title, description, url, urlToImage, publishedAt, source
//       }
}

struct NewsSource: Codable {
    let id : String?
    let name : String?
}
