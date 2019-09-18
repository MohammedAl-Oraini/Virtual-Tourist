//
//  PhotosInfo.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 14/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import Foundation

struct PhotosInfo: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickerPhoto]
}
