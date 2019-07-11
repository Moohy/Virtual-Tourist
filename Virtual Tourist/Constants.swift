//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Mohammed on 4/7/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import Foundation
import MapKit

struct Constants{
    struct Flicker{
        static let APISchema = "https"
        static let APIHost = "api.flicker.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHight = 1.0
        
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLongRange = (-180.0, 180.0)
    }
    
    struct FlickerParameterKeys {
        static let Method       = "method"
        static let APIKey       = "api_key"
        static let Extras       = "extras"
        static let Format        = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch   = "safe_search"
        static let Text         = "text"
        static let BondingBox   = "bbox"
        static let Pages         = "page"
        static let PerPage      = "per_page"
    }
    
    struct FlickerParameterValues {
        static let SearchMethod         = "flicker.photos.search"
        static let APIKey               = "1e5cb27bfbaea87df9516459ac4e53a"
        static let ResponseFormat       = "json"
        static let DisableJSONCallback  = "1"
        static let GallaryPhotosMethod  = "flicker.galleries.getPhotos"
        static let MediumURL            = "url_m"
        static let UseSafeSearch        = "1"
    }
}
