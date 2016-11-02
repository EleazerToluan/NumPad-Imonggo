//
//  ViewController.swift
//  Example
//
//  Created by Lasha Efremidze on 5/27/16.
//  Copyright © 2016 Lasha Efremidze. All rights reserved.
//

import UIKit
import NumPad

class ViewController: UIViewController, FormattedNumPadDelegate
{
	@IBOutlet var numpadContainer: FormattedNumPad!
	@IBOutlet var externalTF: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.numpadContainer.externalTextField = self.externalTF
	}
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		self.numpadContainer.buttonTitles = [["7", "8", "9"],
														 ["4", "5", "6"],
														 ["1", "2", "3"],
		                                     ["0", "00", "10"],
														 ["20", "50", "100"],
														 ["200", "500", "1000"],
														 ["C", ".50", ".25"],
														 ["Cash", "Bread\nCert.", "Gift\nCert"]]
		self.numpadContainer.delegate = self
		// self.numpadContainer.autoDecimal = false
	}
	
	func numPad(numPad: FormattedNumPad, valueChanged value: Double)
	{
		// numPad.externalTextField?.text = "\(numPad.externalTextField!.text!)%"
		print("double value: '\(value)'")
	}
	
	func numPad(numPad: FormattedNumPad, buttonTapped title: String)
	{
		print("title: \(title)")
	}
}