//
//  ScaledHeightImageView.swift
//  ntro-lab-alexanderleo0
//
//  Created by Александр Никитин on 21.02.2023.
//

import UIKit

// Создаем новый класс, что бы было удобно работать с картинками
class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {

        if let myImage = image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        return CGSize(width: -1.0, height: -1.0)
    }

}
