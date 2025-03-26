//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import UIKit


final class SingleImageViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    //MARK: - Internal Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImage()
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupImageView()
        rescaleAndCenterImage()
    }
    
    //MARK: - Private Methods
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    private func setupImageView() {
        if let image {
            imageView.frame.size = image.size
            imageView.image = image
        }
    }
    
    private func rescaleAndCenterImage() {
        guard let image else {
            assertionFailure("SingleImageViewController: Tried to center image before assigning it")
            return
        }
        guard image.size.height != 0, image.size.width != 0 else {
            assertionFailure("SingleImageViewController: Failed to scale image. Either side of image is zero")
            return
        }
        view.layoutIfNeeded()
        let vScale = scrollView.bounds.height/image.size.height
        let hScale = scrollView.bounds.width/image.size.width
        let zoomScale = min(vScale, hScale)
        let trueScale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, zoomScale))
        scrollView.setZoomScale(trueScale, animated: false)
        adjustInsets()
    }
    
    private func adjustInsets() {
        let dx = (scrollView.bounds.width - scrollView.contentSize.width)/2
        let dy = (scrollView.bounds.height - scrollView.contentSize.height)/2
        scrollView.contentInset = .init(top: max(dy, 0), left: max(dx, 0), bottom: max(scrollView.bounds.height - scrollView.contentSize.height - dy, 0), right: max(scrollView.bounds.width - scrollView.contentSize.width - dx, 0))
    }
    
    //MARK: - IBActions
    
    @IBAction private func shareButtonTapped() {
        guard let image else {
            assertionFailure("SingleImageViewController: Failed to unwrap image")
            return
        }
        let avc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(avc, animated: true, completion: nil)
    }
    
    @IBAction private func backwardButtonTapped() {
        dismiss(animated: true)
    }
    
}


//MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustInsets()
    }
 
}
