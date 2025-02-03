//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import UIKit

class SingleImageViewController: UIViewController {
    
    //MARK: - vars
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImage()
        }
    }
    
    //MARK: - @IBOutlet vars
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    //MARK: - @IBOutlet actions
    
    @IBAction func shareButtonTapped() {
        guard let image else {
            assertionFailure("Failed to unwrap image")
            return
        }
        let avc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(avc, animated: true, completion: nil)
    }
    
    @IBAction func backwardButtonTapped() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.image = image
        if let image {
            imageView.frame.size = image.size
        }
        rescaleAndCenterImage()
    }
    
    func rescaleAndCenterImage() {
        guard let image else {
            assertionFailure("Tried to center image before assigning it")
            return
        }
        //TODO: locate in center
        view.layoutIfNeeded()
        let vScale = scrollView.bounds.height/image.size.height
        let hScale = scrollView.bounds.width/image.size.width
        let zoomScale = min(vScale, hScale)
        let trueScale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, zoomScale))
        scrollView.setZoomScale(trueScale, animated: false)
        view.layoutIfNeeded()
        let dx = (scrollView.bounds.width - scrollView.contentSize.width)/2
        let dy = (scrollView.bounds.height - scrollView.contentSize.height)/2
        print(scrollView.contentOffset)
        scrollView.setContentOffset(CGPoint(x: dx, y: dy), animated: false)
        print(scrollView.contentOffset)
    }
}


extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
