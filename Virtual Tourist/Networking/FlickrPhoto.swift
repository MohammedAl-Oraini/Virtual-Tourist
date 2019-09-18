//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 14/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import Foundation

struct FlickerPhoto:Codable {
    let id: String
    let owner: String
    let secret: String
    let imageUrl: String
    
    enum CodingKeys:String,CodingKey {
        case id
        case owner
        case secret
        case imageUrl = "url_q"
    }
}
