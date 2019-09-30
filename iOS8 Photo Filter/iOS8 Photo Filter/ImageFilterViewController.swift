//
//  ImageFilterViewController.swift
//  iOS8 Photo Filter
//
//  Created by Michael Redig on 9/30/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class ImageFilterViewController: UIViewController {

	var inputImage: UIImage?

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var brightnessSlider: UISlider!
	@IBOutlet var contrastSlider: UISlider!
	@IBOutlet var saturationSlider: UISlider!

	private let context = CIContext(options: nil)
	private let filter: CIFilter = {
		guard let filter = CIFilter(name: "CIColorControls") else { fatalError("Filter doesn't exist")}
		return filter
	}()

	private var originalImage: UIImage? {
		didSet {
			guard let image = originalImage else { return }
			let scale = UIScreen.main.scale
			var maxSize = imageView.bounds.size
			maxSize = CGSize(width: maxSize.width * scale, height: maxSize.height * scale)
			scaledImage = image.imageByScaling(toSize: maxSize)
		}
	}

	private var scaledImage: UIImage? {
		didSet {
			updateImage()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		originalImage = imageView.image

		print("Screen: \(UIScreen.main.bounds) scale: \(UIScreen.main.scale)")
		// research scale vs nativeScale
		print("imageView: \(imageView.bounds)")
	}

	private func updateImage() {
		if let image = scaledImage {
			imageView.image = filterImage(image)
		}
	}

	// MARK: - Slider events
	@IBAction func brightnessChanged(_ sender: UISlider) {
		updateImage()
	}

	@IBAction func contrastChanged(_ sender: UISlider) {
		updateImage()
	}

	@IBAction func saturationChanged(_ sender: UISlider) {
		updateImage()
	}

	// MARK: - Button actions
	@IBAction func choosePhotoPressed(_ sender: UIBarButtonItem) {
	}

	@IBAction func savePhotoPressed(_ sender: UIButton) {
		saveFilteredPhoto()
	}

	@IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
		brightnessSlider.value = 0
		contrastSlider.value = 1
		saturationSlider.value = 1
		updateImage()
	}

	// MARK: - business logic
	func filterImage(_ image: UIImage) -> UIImage {
		guard let ciImage = CIImage(image: image) else { fatalError("No Image available") }
		print(image.size)

		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(brightnessSlider.value as NSNumber, forKey: kCIInputBrightnessKey)
		filter.setValue(contrastSlider.value as NSNumber, forKey: kCIInputContrastKey)
		filter.setValue(saturationSlider.value as NSNumber, forKey: kCIInputSaturationKey)

		guard let ciImageResult = filter.outputImage, let cgImageResult = context.createCGImage(ciImageResult, from: CGRect(origin: .zero, size: image.size)) else { fatalError("No output image") }

		return UIImage(cgImage: cgImageResult)
	}

	func saveFilteredPhoto() {
		guard let image = originalImage else { return }
		let filteredImage = filterImage(image)

		PHPhotoLibrary.requestAuthorization { (status) in
			guard status == .authorized else { fatalError("not authorized") }

			PHPhotoLibrary.shared().performChanges({
				PHAssetCreationRequest.creationRequestForAsset(from: filteredImage)
			}) { (success, error) in
				if let error = error {
					print("There was an error saving the image to photos: \(error)")
				}
				// TODO: present alert if applicable
				print("saved photo")
			}
		}
	}
}

