//
//  TripListingViewController.swift
//  TripPlanner
//
//  Created by Sonnet on 23/07/18.
//  Copyright © 2018 Sonnet. All rights reserved.
//

import UIKit
import TransitionButton

class TripListingViewController: CustomTransitionViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var startLabel: UILabel!
	@IBOutlet weak var endLabel: UILabel!
	var startLoctionAddress: String?
	var endLocationAddress: String?
	let cellReuseIdentifier = "resultCell"

	override func viewDidLoad() {
		super.viewDidLoad()
		UIApplication.shared.statusBarStyle = .lightContent
		initialSetup()
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	
	}

	func initialSetup() {
		if let startAddress = startLoctionAddress ,
			 let endAddress = endLocationAddress {
			startLabel.text = startAddress
			endLabel.text = endAddress
		}
		tableView.reloadData()
	}

	@IBAction func cancelAction(_ sender: Any) {
		self.dismiss(animated: true) {
			
		}
	}
}

extension TripListingViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResultListingCell

		// set the text from the data model
	//	cell.textLabel?.text = self.animals[indexPath.row]

		return cell

	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 160
	}

}
