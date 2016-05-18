//
//  HelloVC.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/12/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit

class HelloVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    let NUMBER_PHOTO: CGFloat = 5
    var PHOTO_WIDTH: CGFloat = 320
    var PHOTO_HEIGHT: CGFloat = 569
    
    var once = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.pagingEnabled = true
//        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * NUMBER_PHOTO, scrollView.bounds.height)
//        
//        for i in 0..<6 {
//            let imageView = UIImageView(image: UIImage(named: "photo-\(i)"))
//            imageView.frame = CGRectMake(scrollView.bounds.size.width * CGFloat(i), 0, scrollView.bounds.size.width, scrollView.bounds.size.height)
//            self.scrollView.addSubview(imageView)
//        }
        
        pageControl.numberOfPages = Int(NUMBER_PHOTO) + 1
        
//        self.view.backgroundColor = UIColor.blackColor()
        self.view.backgroundColor = UIColor(red: 0, green: 150/255, blue: 1, alpha: 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.delegate = self
        self.scrollView.contentOffset = CGPointMake(CGFloat(PHOTO_WIDTH), 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        PHOTO_WIDTH = self.view.bounds.size.width - 40
        PHOTO_HEIGHT = self.view.bounds.size.height - 71        
        
        scrollView.frame = CGRectMake(0, 0, PHOTO_WIDTH, PHOTO_HEIGHT)
        scrollView.contentSize = CGSizeMake(PHOTO_WIDTH * NUMBER_PHOTO, scrollView.bounds.size.height)
        scrollView.center = self.view.center
        
        for i in 0...Int(NUMBER_PHOTO) {
            let imageView = UIImageView(image: UIImage(named: "photoo\(i)"))
            imageView.frame = CGRectMake(PHOTO_WIDTH * CGFloat(i), 0, PHOTO_WIDTH, PHOTO_HEIGHT)
            scrollView.addSubview(imageView)
            
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / PHOTO_WIDTH)
        if pageControl.currentPage == Int(NUMBER_PHOTO - 1) {
            showAlert("Are you sure?", message: "If you ready, tap YES")
        }
    }
    
    @IBAction func pageControlValueChange(sender: UIPageControl) {
        scrollView.contentOffset = CGPointMake(PHOTO_WIDTH * CGFloat(pageControl.currentPage), 0)
    }
    
    func showAlert(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "No", style: .Cancel, handler: {action in 
            self.pageControl.currentPage = 1
            self.scrollView.setContentOffset(CGPointMake(CGFloat(self.PHOTO_WIDTH), 0), animated: true)
        })
        let action = UIAlertAction(title: "Yes", style: .Default) { (action) in
            self.performSegueWithIdentifier("showLogin", sender: nil)
            self.scrollView.delegate = nil
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
}
