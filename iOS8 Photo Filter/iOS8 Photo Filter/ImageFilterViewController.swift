//
//  ImageFilterViewController.swift
//  iOS8 Photo Filter
//
//  Created by Michael Redig on 9/30/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import UIKit
import CoreImage

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
			updateImage()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		originalImage = imageView.image
	}

	private func updateImage() {
		if let image = originalImage {
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

	@IBAction func choosePhotoPressed(_ sender: UIBarButtonItem) {
	}

	@IBAction func savePhotoPressed(_ sender: UIButton) {
	}

	@IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
		brightnessSlider.value = 0
		contrastSlider.value = 1
		saturationSlider.value = 1
		updateImage()
	}

	func filterImage(_ image: UIImage) -> UIImage {
		guard let ciImage = CIImage(image: image) else { fatalError("No Image available") }

		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(brightnessSlider.value as NSNumber, forKey: kCIInputBrightnessKey)
		filter.setValue(contrastSlider.value as NSNumber, forKey: kCIInputContrastKey)
		filter.setValue(saturationSlider.value as NSNumber, forKey: kCIInputSaturationKey)

		guard let ciImageResult = filter.outputImage, let cgImageResult = context.createCGImage(ciImageResult, from: CGRect(origin: .zero, size: image.size)) else { fatalError("No output image") }

		return UIImage(cgImage: cgImageResult)
	}

}

