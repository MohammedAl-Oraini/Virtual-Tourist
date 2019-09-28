//
//  VirtualTouristClient.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 14/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import Foundation

class VirtualTouristClient {
    
    //MARK: - api key
    
    static let apiKey = "ENTER FLICKR API KEY HERE"
    
    //MARK: - network methods
    
    class func getPhotosInfo (longitude:Double,latitude:Double,page:Int,completion: @escaping ([FlickerPhoto],Int?, Error?) -> Void) {
        
        let request = URLRequest(url: URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(VirtualTouristClient.apiKey)&bbox=\(longitude)%2C\(latitude)%2C\(longitude + 0.1)%2C\(latitude + 0.1)&content_type=1&media=photos&extras=url_z&per_page=21&page=\(page)&format=json&nojsoncallback=1")!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion([] ,nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(PhotosResponse.self, from: data!)
                print("There are \(responseObject.photos.pages) pages")
                completion(responseObject.photos.photo,responseObject.photos.pages,nil)
            } catch {
                print(error.localizedDescription)
                completion([],nil,error)
            }
        }
        task.resume()
    }
}
