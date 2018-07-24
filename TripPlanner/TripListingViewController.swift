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

	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func cancelAction(_ sender: Any) {
		self.dismiss(animated: true) {
			
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
