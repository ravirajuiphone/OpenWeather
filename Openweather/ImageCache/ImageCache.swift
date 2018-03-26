//
//  ImageCache.swift
//  Openweather
//
//  Created by Raviraju Vysyaraju on 23/03/2018.
//  Copyright © 2018 Raviraju Vysyaraju. All rights reserved.
//

import UIKit
import CoreData
let BaseImageUri = "http://openweathermap.org/img/w/%@.png"
class ImageCache: NSObject {
    var session: URLSession!
    var task: URLSessionDataTask!
    init(shared urlSession: URLSession = URLSession.shared, sessionTask: URLSessionDataTask = URLSessionDataTask() ) {
        session = urlSession
        task = sessionTask
    }
    
    func imageFor(uriString: String?, completionHandler: @escaping (UIImage?, Error?) -> Swift.Void) {
        guard let imageUri = uriString,let url = URL(string: String(format: BaseImageUri,imageUri)) else {
            return
        }
        //self.cache.object(forKey: url.absoluteString as NSString)
        if let imageInCache: UIImage = getCacheData(url: url.absoluteString) {
            print("downloaded url : \(url)")
            completionHandler(imageInCache, nil)
            return
        }
        print("downloading url : \(url)")
        self.task = self.session.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            let image = UIImage(data: data!)
            
            self.save(url: url.absoluteString, image: image!)
            completionHandler(image, nil)
        }
        
        self.task.resume()
    }
    
    func save(url:String, image:UIImage)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let entity = NSEntityDescription.entity(forEntityName: "Images",
                                                in: managedContext)
        let options = NSManagedObject(entity: entity!,
                                      insertInto:managedContext)
        
        let newImageData = UIImageJPEGRepresentation(image,1)
        
        options.setValue(url, forKey: "url")
        options.setValue(newImageData, forKey: "image")
        try? managedContext.save()
    }
    func getCacheData(url: String) -> UIImage? {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let imagePredicate = NSPredicate(format: "(url == %@)",url)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = imagePredicate
        
        
        
        if let fetchedResults = try? managedContext.fetch(fetchRequest), let result = fetchedResults.first
        {
            if let img: Data = (result as! Images).value(forKey: "image") as? Data {
                return UIImage(data: img as Data)!
            }
            
        }
        return nil
    }
}
