//
//  PhotoExtension.swift
//  Virtual Tourist
//
//  Created by Mohammed on 23/6/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit

extension Photo {
    func set(image: UIImage){
        self.image = image.pngData()
    }
    
    func getImage() -> UIImage?{
        return (image == nil) ? nil : UIImage(data: image!)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationImage = Date()
    }
}
