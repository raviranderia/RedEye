//
//  Extensions.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject> ()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()


extension UIImageView {
    
    
    

    func loadImageWithCache(urlString: String) {
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let url = NSURL (string: urlString)
        URLSession.shared.dataTask(with:url as! URL, completionHandler: {(data, response, error) in
            
            if error != nil {
                print("Error loading profile picture \(error?.localizedDescription)")
                return
            } else{
                DispatchQueue.main.async{
                    if let cachedImage = UIImage(data:data!){
                        imageCache.setObject(cachedImage, forKey: urlString as NSString)
                         self.image = cachedImage
                        
                    }
                   
                    
                    
                }}
        }).resume()

    }
}


