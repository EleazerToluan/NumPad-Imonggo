//
//  ViewController.swift
//  Example
//
//  Created by Lasha Efremidze on 5/27/16.
//  Copyright © 2016 Lasha Efremidze. All rights reserved.
//

import UIKit
import NumPad

class ViewController: UIViewController
{
	@IBOutlet var numpadContainer: FormattedNumPad!
	@IBOutlet var externalTF: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.numpadContainer.externalTextField = self.externalTF
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.numpadContainer.doubleValue = 7.00
	}
}