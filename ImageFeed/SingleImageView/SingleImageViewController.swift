//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    //MARK: - Internal Properties
    
    var imageURL: URL?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        loadImage()
    }
    
    //MARK: - Private Methods
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = 0.05
        scrollView.maximumZoomScale = 1.25
    }
    
    private func loadImage() {
        UIBlockingHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self else { return }
            UIBlockingHUD.dismiss()
            switch result {
            case .success(let imageResult):
                self.imageView.frame.size = imageResult.image.size
                rescaleAndCenterImage()
            case .failure(let error):
                print("SingleImageViewController.loadImage: Kingfisher error\n\(error)")
                break
            }
        }
    }
    
    private func showError() {
        let ac = UIAlertController(title: "Что-то пошло не так", message: "Не удалось загрузить изображение", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "", style: .cancel) { [weak self] _ in
            self?.backwardButtonTapped()
        }
        let reloadAction = UIAlertAction(title: "", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        ac.addAction(cancelAction)
        ac.addAction(reloadAction)
        ac.preferredAction = reloadAction
        present(ac, animated: true)
    }
    
    private func rescaleAndCenterImage() {
        guard let image = imageView.image else {
            assertionFailure("SingleImageViewController.rescaleAndCenterImage: Tried to center non existing image")
            return
        }
        guard image.size.height != 0, image.size.width != 0 else {
            assertionFailure("SingleImageViewController.rescaleAndCenterImage: Failed to scale image. Either side of image is zero")
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
        guard let image = imageView.image else {
            assertionFailure("SingleImageViewController.shareButtonTapped: Failed to unwrap image")
            return
        }
        let aVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(aVC, animated: true, completion: nil)
    }
    
    @IBAction private func backwardButtonTapped() {
        imageView.kf.cancelDownloadTask()
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
