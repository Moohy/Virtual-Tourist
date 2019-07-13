//
//  API.swift
//  Virtual Tourist
//
//  Created by Mohammed on 4/7/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import Foundation
import MapKit

struct API {
    static func getPhotosUrl(with coordinate: CLLocationCoordinate2D, pageNum: Int, completion: @escaping ([URL]?, Error?, String?) -> ()){
        let params = [ Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                       Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                       Constants.FlickrParameterKeys.BondingBox: bboxString(for: coordinate),
                       Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                       Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                       Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                       Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
                    Constants.FlickrParameterKeys.Pages: pageNum,
                    Constants.FlickrParameterKeys.PerPage: 9
        ] as [String:Any]
        
        let request = URLRequest(url: getURL(from: params))
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil, error, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, nil, "Not 200 response")
                return
            }
            
            guard let data = data else {
                completion(nil, nil, "No data has been found")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] else{
                completion(nil, nil, "Data could not be parsed on json")
                return
            }
            
            guard let stat = result["stat"] as? String, stat == "ok" else{
                completion(nil,nil,"an error returned see the error message : \(result)")
                return
            }
            
            guard let photoDic = result["photos"] as? [String:Any] else {
                completion(nil,nil,"key photos not phound in \(result)")
                return
            }
            
            guard let photoArr = photoDic["photo"] as? [[String:Any]] else {
                completion(nil,nil, "key photo not found in \(photoDic)")
                return
            }
            
            let photoURLs = photoArr.compactMap { photoDic -> URL? in
                guard let url = photoDic["url_m"] as? String else{
                    return nil
                }
                return URL(string: url)
            }
            completion(photoURLs, nil,nil)
            
        }
        task.resume()
    }
    
    static func bboxString(for coordinate: CLLocationCoordinate2D) -> String {
        let lat = coordinate.latitude
        let long = coordinate.longitude
        
        let minLong = max(long - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLongRange.0)
        let minLat = max(lat - Constants.Flickr.SearchBBoxHalfHight, Constants.Flickr.SearchLatRange.0)
        
        let maxLong = min(long + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLongRange.1)
        let maxLat = min(lat + Constants.Flickr.SearchBBoxHalfHight, Constants.Flickr.SearchLatRange.1)
        
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
    
    static func getURL(from param: [String:Any]) -> URL {
        var componants = URLComponents()
        componants.scheme = Constants.Flickr.APISchema
        componants.host = Constants.Flickr.APIHost
        componants.path = Constants.Flickr.APIPath
        componants.queryItems = [URLQueryItem]()
        for (key, value) in param {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            componants.queryItems!.append(queryItem)
        }
        return componants.url!
    }
    
}
