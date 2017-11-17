//
//  PhotoMediaViewController.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class PhotoMediaViewController: UIViewController, UIScrollViewDelegate {

    public let photoMedia: PhotoMedia

    public init(photoMedia: PhotoMedia) {
        self.photoMedia = photoMedia

        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let scalingImageView = ScalingImageView(frame: .zero)

    lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PhotoMediaViewController.handleDoubleTapWithGestureRecognizer(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        scalingImageView.delegate = self
        scalingImageView.frame = view.bounds
        scalingImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scalingImageView)

        photoMedia.image?.requestImage(completion: { [weak self] (image) in
            self?.scalingImageView.image = image.sizing().image
        })

        view.addGestureRecognizer(doubleTapGestureRecognizer)
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scalingImageView.frame = view.bounds
    }

    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scalingImageView.imageView
    }

    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = true
    }

    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.isEnabled = false;
        }
    }

    // MARK: - Private

    @objc private func handleDoubleTapWithGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: scalingImageView.imageView)
        var newZoomScale = scalingImageView.maximumZoomScale

        if scalingImageView.zoomScale >= scalingImageView.maximumZoomScale || abs(scalingImageView.zoomScale - scalingImageView.maximumZoomScale) <= 0.01 {
            newZoomScale = scalingImageView.minimumZoomScale
        }

        let scrollViewSize = scalingImageView.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)

        let rectToZoom = CGRect(x: originX, y: originY, width: width, height: height)
        scalingImageView.zoom(to: rectToZoom, animated: true)
    }

}


class ScalingImageView: UIScrollView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        return imageView
    }()

    var image: UIImage? {
        didSet {
            updateImage(image)
        }
    }

    override var frame: CGRect {
        didSet {
            updateZoomScale()
            centerScrollViewContents()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageScrollView()
        updateZoomScale()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageScrollView()
        updateZoomScale()
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        centerScrollViewContents()
    }

    private func setupImageScrollView() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false;
        bouncesZoom = true;
        decelerationRate = UIScrollViewDecelerationRateFast;
    }

    func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0;
        var verticalInset: CGFloat = 0;

        if (contentSize.width < bounds.width) {
            horizontalInset = (bounds.width - contentSize.width) * 0.5;
        }

        if (self.contentSize.height < bounds.height) {
            verticalInset = (bounds.height - contentSize.height) * 0.5;
        }

        let minimum: CGFloat = 2.0
        if ((window?.screen.scale ?? 0) < minimum) {
            horizontalInset = floor(horizontalInset);
            verticalInset = floor(verticalInset);
        }

        self.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    }

    private func updateImage(_ image: UIImage?) {
        let size = image?.size ?? CGSize.zero

        imageView.transform = CGAffineTransform.identity
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: size)
        self.contentSize = size

        updateZoomScale()
        centerScrollViewContents()
    }

    private func updateZoomScale() {
        if let image = imageView.image {
            let scrollViewFrame = self.bounds
            let scaleWidth = scrollViewFrame.size.width / image.size.width
            let scaleHeight = scrollViewFrame.size.height / image.size.height
            let minimumScale = min(scaleWidth, scaleHeight)

            self.minimumZoomScale = minimumScale
            self.maximumZoomScale = max(minimumScale, self.maximumZoomScale) + 3.0

            self.zoomScale = minimumZoomScale

            self.panGestureRecognizer.isEnabled = false
        }
    }
}

