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
        if let image {
            imageView.frame.size = image.size
            imageView.image = image
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
        adjustInsets()
    }
    
    private func adjustInsets() {
        let dx = (scrollView.bounds.width - scrollView.contentSize.width)/2
        let dy = (scrollView.bounds.height - scrollView.contentSize.height)/2
        scrollView.contentInset = .init(top: max(dy, 0), left: max(dx, 0), bottom: max(scrollView.bounds.height - scrollView.contentSize.height - dy, 0), right: max(scrollView.bounds.width - scrollView.contentSize.width - dx, 0))
    }
}


extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustInsets()
    }
 
}
