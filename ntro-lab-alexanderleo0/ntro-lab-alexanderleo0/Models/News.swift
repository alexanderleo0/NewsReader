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

struct News : Decodable {
    let author : String
    let title : String
    let description : String
    let url : String
    let urlToImage: String
    var readCounter : Int = 0
    var image = UIImage(systemName: "phone")
    
    private enum CodingKeys: String, CodingKey {
           case author, title, description, url, urlToImage
       }
}
