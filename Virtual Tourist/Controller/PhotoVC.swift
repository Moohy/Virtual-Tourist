//
//  PhotoVCCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Mohammed on 23/6/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pageNum = 1
    var isDeleting = false
    
    var context: NSManagedObjectContext {
        return DataController.sharedInstance.viewContext
    }
    
    //checking photo availability!
    var isNotNil: Bool {
        return (fetchedResultsController.fetchedObjects?.count ?? 0) != 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        label.isHidden = true
        setupFetchedResultsController()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController() {
        let fetchedReq: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchedReq.predicate = NSPredicate(format: "pin == %@", pin)
        fetchedReq.sortDescriptors = [NSSortDescriptor(key: "creationImage", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedReq, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if isNotNil {
                updateView(processing: false)
                print("there are pics")
            }else {
                reloadButtonTapped(self)
            }
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    @IBAction func reloadButtonTapped(_ sender: Any) {
        updateView(processing: true)
        
        if isNotNil{
            isDeleting = true
            for photo in fetchedResultsController.fetchedObjects! {
                context.delete(photo)
            }
            
            try? context.save()
            isDeleting = false
            
        }
        
        API.getPhotosUrl(with: pin.coordinate, pageNum: pageNum) {(urls, error, errorMsg) in DispatchQueue.main.async {
                self.updateView(processing: false)
                guard (error == nil) && (errorMsg == nil) else {
//                    self.alert(title: "Error", message: error?.localizedDescription ?? errorMsg)
                    return
                }
            
                guard let urls = urls, !urls.isEmpty else{
                    self.label.isHidden = false
                    return
                }
                for url in urls {
                    let photo = Photo(context: self.context)
                    photo.imageURL = url
                    photo.pin = self.pin
                }
                try? self.context.save()
            }
        }
        pageNum += 1
    }
    
    func updateView(processing: Bool){
        collectionView.isUserInteractionEnabled = !processing
        if processing{
            reloadButton.isEnabled = false
            reloadButton.tintColor = .clear
            activityInd.startAnimating()
            activityInd.isHidden = false
            
        }else {
            activityInd.stopAnimating()
            activityInd.isHidden = true
            reloadButton.isEnabled = true
            reloadButton.tintColor = .darkGray
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCVCell", for: indexPath) as! PhotoCVCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imgView.setPhoto(photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        context.delete(photo)
        try? context.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-20) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, type == .delete && !isDeleting {
            collectionView.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = indexPath, type == .insert{
            collectionView.insertItems(at: [indexPath])
            return
        }
        
        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move{
            collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }
        
        if type != .update{
            collectionView.reloadData()
        }
    }
    
    
}
