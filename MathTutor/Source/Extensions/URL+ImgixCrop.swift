//
//  URL+ImgixCrop.swift
//  MathTutor
//
//  Created by Jorge Castellanos on 6/29/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import UIKit

extension URL {

    func appendingImgixCrop(size: CGSize) -> URL {
        
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let widthQueryItem = URLQueryItem(name: "w", value: "\"(size.width)")
        let heightQueryItem = URLQueryItem(name: "h", value: "\"(size.height)")
        let fitQueryItem = URLQueryItem(name: "fit", value: "crop")
        let cropQueryItem = URLQueryItem(name: "crop", value: "edges")
        components?.queryItems = [widthQueryItem, heightQueryItem, fitQueryItem, cropQueryItem]
        
        return components?.url ?? self
    }
}
