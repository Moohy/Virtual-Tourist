//
//  File.swift
//  Virtual Tourist
//
//  Created by Mohammed on 3/7/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit

protocol CustomImageViewDelegate {
    func imageDidDownload()
}

let imagesCache = NSCache<NSString, AnyObject>()

class CustomImgView: UIImageView {
    var imageURL: URL!
    
    func setPhoto(_ newPhoto: Photo){
        if photo != nil{
            return
        }
        photo = newPhoto
    }
    
    private var photo: Photo!{
        didSet{
            if let image = photo.getImage() {
                hideActivityInd()
                self.image = image
                return
            }
            guard let url = photo.imageURL else{
                return
            }
            loadImageByCache(with: url)
        }
    }
    
    func loadImageByCache(with url: URL){
        
        imageURL = url
        image = nil
        showActivityInd()
        
        if let cachedImage = imagesCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            image = cachedImage
            hideActivityInd()
            return
        }
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                return
            }
            
            guard let LoadedImage = UIImage(data: data!) else {
                return
            }
            imagesCache.setObject(LoadedImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async{
    
                self.image = LoadedImage
                self.photo.set(image: LoadedImage)
                try? self.photo.managedObjectContext?.save()
                self.hideActivityInd()
    
            }
        }.resume()

    }
    
    lazy var activityInd: UIActivityIndicatorView = {
        let activityInd = UIActivityIndicatorView (style: .whiteLarge)
        self.addSubview(activityInd)
        activityInd.translatesAutoresizingMaskIntoConstraints = false
        activityInd.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityInd.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityInd.color = .black
        activityInd.hidesWhenStopped = true
        return activityInd
    }()
    
    func showActivityInd() {
        DispatchQueue.main.async {
            self.activityInd.startAnimating()
        }
    }
    
    func hideActivityInd() {
        DispatchQueue.main.async {
            self.activityInd.stopAnimating()
        }
    }
    
}
