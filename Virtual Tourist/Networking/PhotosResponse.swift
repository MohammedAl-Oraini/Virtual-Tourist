//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 14/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import Foundation

struct PhotosResponse:Codable {
    let photos: PhotosInfo
    let stat: String
}
