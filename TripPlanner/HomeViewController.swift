//
//  HomeViewController.swift
//  TripPlanner
//
//  Created by Sonnet on 20/07/18.
//  Copyright © 2018 Sonnet. All rights reserved.
//

import UIKit
import fluid_slider
import TransitionButton
import GooglePlacesSearchController
import CoreLocation

//MARK:- Enums
enum SearchBox {
	case startFrom
	case whereTo
}

enum Filter: Int {
	case walking = 1
	case departsIn
}

//MARK:- Constants
struct HomeConstants {
	static let GoogleMapsAPIServerKey = "AIzaSyAw5egCQ9tIJFuqsEGxeaYOV4eVbrg2b-k"
}

class HomeViewController: UIViewController {

	//MARK:- Outlets
	@IBOutlet weak var whereTo: UIButton!
	@IBOutlet weak var busiImageView: UIImageView!
	@IBOutlet weak var startFrom: UIButton!
	@IBOutlet weak var dateAndTimePicker: UIDatePicker!
	@IBOutlet weak var walkingSlider: Slider!
	@IBOutlet weak var departureTimeSlider: Slider!
	@IBOutlet weak var searchButton: TransitionButton!
	@IBOutlet weak var filterButton: UIButton!
	@IBOutlet weak var filterView: UIView!
	@IBOutlet weak var filterViewHeight: NSLayoutConstraint!
	@IBOutlet weak var departsOrArriveSegmentControl: UISegmentedControl!
	@IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

	//MARK:- Variables
	var filterShown = true
	var selectedSearchBox = SearchBox.startFrom
	var fromCoordinate: CLLocationCoordinate2D?
	var toCoordinate: CLLocationCoordinate2D?
	var fromAddress: String?
	var toAddress: String?
	var time: String?
	var walkingDistance: String?
	var departsIn: String?

	lazy var placesSearchController: GooglePlacesSearchController = {
		let controller = GooglePlacesSearchController(delegate: self,
																									apiKey: HomeConstants.GoogleMapsAPIServerKey,
																									placeType: .address,
																									searchBarPlaceholder: "Start typing..."
		)
		controller.searchBar.isTranslucent = true
		controller.searchBar.backgroundColor = UIColor(red: 98/255.0, green: 102/255.0, blue: 111/255.0, alpha: 1)
		controller.searchBar.tintColor = UIColor(red: 211/255.0, green: 24/255.0, blue: 24/255.0, alpha: 1)
		controller.searchBar.barTintColor =  UIColor(red: 98/255.0, green: 102/255.0, blue: 111/255.0, alpha: 1)
		return controller
	}()

	//MARK:- Override methods
	override func viewDidLoad() {
		super.viewDidLoad()
		initialSetup()

	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if filterShown {
			imageViewTrailingConstraint.constant = 20
			UIView.animate(withDuration: 1) {
				self.view.layoutIfNeeded()
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()

	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	//MARK:- UI
	func initialSetup() {
		UIApplication.shared.statusBarStyle = .lightContent
		filterViewHeight.constant = 0
		self.filterView.setNeedsUpdateConstraints()
		view.layoutIfNeeded()
		//Date and Time picker
		dateAndTimePicker.setValue(UIColor.white, forKeyPath: "textColor")
		dateAndTimePicker.datePickerMode = .dateAndTime
		dateAndTimePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
		//Slider
		walkingSlider.tag =  Filter.walking.rawValue
		addCustomSlider(slider: walkingSlider)
		departureTimeSlider.tag = Filter.departsIn.rawValue
		addCustomSlider(slider: departureTimeSlider)
		walkingSlider.addTarget(self, action: #selector(HomeViewController.sliderValueChanged(_:)), for: .valueChanged)
		departureTimeSlider.addTarget(self, action: #selector(HomeViewController.sliderValueChanged(_:)), for: .valueChanged)
		//Search button
		customizeSearchButton()
	}

	func addCustomSlider(slider: Slider) {
		let labelTextAttributes: [NSAttributedStringKey : Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.white]
		if slider.tag == Filter.walking.rawValue {
			slider.attributedTextForFraction = { fraction in
				let formatter = NumberFormatter()
				formatter.maximumIntegerDigits = 2
				formatter.maximumFractionDigits = 0
				let string = formatter.string(from: (fraction * 30) as NSNumber) ?? ""
				self.walkingDistance = string
				return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.black])
			}
		} else {
			slider.attributedTextForFraction = { fraction in
				let formatter = NumberFormatter()
				formatter.maximumIntegerDigits = 2
				formatter.maximumFractionDigits = 0
				let string = formatter.string(from: (fraction * 30) as NSNumber) ?? ""
				self.departsIn = string
				return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.black])
			}
		}
		slider.setMinimumLabelAttributedText(NSAttributedString(string: "0", attributes: labelTextAttributes))
		slider.setMaximumLabelAttributedText(NSAttributedString(string: "30", attributes: labelTextAttributes))
		slider.fraction = 1
		slider.shadowOffset = CGSize(width: 0, height: 10)
		slider.shadowBlur = 5
		slider.shadowColor = UIColor(white: 0, alpha: 0.1)
		slider.contentViewColor = UIColor(red: 211/255.0, green: 24/255.0, blue: 24/255.0, alpha: 1)
		slider.valueViewColor = .white
	}

	func customizeSearchButton() {
		searchButton.setTitle("Search", for: .normal)
		searchButton.spinnerColor = .white
		searchButton.addTarget(self, action: #selector(HomeViewController.searchTrips), for: .touchUpInside)
	}
}

// MARK: - Utilities
extension HomeViewController {
	@objc func searchTrips() {
		searchButton.startAnimation() // Start animation
		let qualityOfServiceClass = DispatchQoS.QoSClass.background
		let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
		backgroundQueue.async(execute: {

			sleep(3) //  Do your networking task or background work here.

			DispatchQueue.main.async(execute: { () -> Void in
				//  Stop the animation, here you have three options for the `animationStyle` property:
				self.searchButton.stopAnimation(animationStyle: .expand, completion: {
					let storyboard = UIStoryboard(name: "Main", bundle: nil)
					let controller = storyboard.instantiateViewController(withIdentifier: "TripListingViewController") as? TripListingViewController
					controller?.startLoctionAddress =  self.fromAddress
					controller?.endLocationAddress = self.toAddress
					self.present(controller!, animated: true, completion: nil)
				})
			})
		})
	}
}

// MARK: - Google Places delegates
extension HomeViewController: GooglePlacesAutocompleteViewControllerDelegate {
	func viewController(didAutocompleteWith place: PlaceDetails) {
		print(place.formattedAddress)
		//placesSearchController.isActive = false
		dismiss(animated: true, completion: nil)
		if selectedSearchBox == SearchBox.startFrom {
			startFrom.setTitle(place.formattedAddress, for: .normal)
			fromCoordinate = place.coordinate
			fromAddress = place.formattedAddress

		} else {
			whereTo.setTitle(place.formattedAddress, for: .normal)
			toCoordinate = place.coordinate
			toAddress = place.formattedAddress
		}
	}

}

// MARK: - IBActions
extension HomeViewController {

	@IBAction func filterAction(_ sender: Any) {
		filterShown = !filterShown
		filterViewHeight.constant =  filterShown ? 0 : 130
		imageViewTrailingConstraint.constant = filterShown ? 20 : 600
		UIView.animate(withDuration: 0.8) {
			self.view.layoutIfNeeded()
			self.filterView.layoutIfNeeded()
			self.filterView.isHidden = self.filterShown ? true : false
		}
	}

	@IBAction func startFromAction(_ sender: Any) {
		selectedSearchBox = SearchBox.startFrom
		present(placesSearchController, animated: true, completion: nil)
	}

	@IBAction func whereToAction(_ sender: Any) {
		selectedSearchBox = SearchBox.whereTo
		present(placesSearchController, animated: true, completion: nil)
	}

}

// MARK: - Slider Delegates
extension HomeViewController {
	@objc func sliderValueChanged(_ sender: UIControl) {
		print("******\(walkingDistance!)")
	}
}

// MARK: - Time & Date picker Methods
extension HomeViewController {

	@objc func dateChanged(_ sender: UIDatePicker) {
		//let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: sender.date)
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
		time = formatter.string(from: sender.date)
		print("\(time ?? "")")
		self.view.endEditing(true)
	}

}
