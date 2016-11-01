//
//  NumPad.swift
//  NumPad
//
//  Created by Lasha Efremidze on 1/9/16.
//  Copyright © 2016 Lasha Efremidze. All rights reserved.
//

import UIKit

public typealias Row = Int
public typealias Column = Int

// MARK: - Position
public typealias Position = (row: Row, column: Column)

// MARK: - Item
public struct Item {
	public var backgroundColor: UIColor? = .whiteColor()
	public var selectedBackgroundColor: UIColor? = .clearColor()
	public var image: UIImage?
	public var title: String?
	public var titleColor: UIColor? = .blackColor()
	public var font: UIFont? = .systemFontOfSize(17)
	
	public init() {}
	public init(title: String?) {
		self.title = title
	}
	public init(image: UIImage?) {
		self.image = image
	}
}

// MARK: - NumPadDataSource
public protocol NumPadDataSource: class {
	
	
	//    func buttonTitlesInNumpad(numPad: NumPad) -> [[String]]
	//
	//    /// The number of rows.
	//    func numberOfRowsInNumPad(numPad: NumPad) -> Int
	//
	//    /// The number of columns.
	//    func numPad(numPad: NumPad, numberOfColumnsInRow row: Row) -> Int
	
	/// The item at position.
	func numPad(numPad: NumPad, itemAtPosition position: Position) -> Item
}

// MARK: - NumPadDelegate
public protocol NumPadDelegate: class {
	
	/// The item was tapped handler.
	func numPad(numPad: NumPad, itemTapped item: Item, atPosition position: Position)
	
	/// The size of an item at position.
	func numPad(numPad: NumPad, sizeForItemAtPosition position: Position) -> CGSize
	
}

public extension NumPadDelegate {
	func numPad(numPad: NumPad, itemTapped item: Item, atPosition position: Position) {}
	func numPad(numPad: NumPad, sizeForItemAtPosition position: Position) -> CGSize { return CGSize() }
}

// MARK: - NumPad
public class NumPad: UIView {
	
	var  rowCount: Int { return self.buttonTitles.count }
	var  coloumCount: Int { return self.buttonTitles.first?.count ?? 0}
	//
	//    /// The number of columns.
	//    func numPad(numPad: NumPad, numberOfColumnsInRow row: Row) -> Int
	
	// default numbers
	var buttonTitles: [[String]] = [[  "7", "8", "9" ],
	                                [  "4", "5", "6" ],
	                                [  "1", "2", "3" ],
	                                [  "C", "0", "00"]]
	{
		didSet
		{
			self.collectionView.reloadData()
		}
	}
	
	lazy var collectionView: UICollectionView = { [unowned self] in
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		let collectionView = CollectionView(frame: CGRect(), collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .clearColor()
		collectionView.allowsSelection = false
		collectionView.scrollEnabled = false
		collectionView.numPad = self
		collectionView.dataSource = collectionView
		collectionView.delegate = collectionView
		collectionView.registerClass(Cell.self, forCellWithReuseIdentifier: String(Cell))
		self.addSubview(collectionView)
		let views = ["collectionView": collectionView]
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views))
		return collectionView
		}()
	
	/// Data source for the number pad.
	public weak var dataSource: NumPadDataSource?
	
	/// Delegate for the number pad.
	public weak var delegate: NumPadDelegate?
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		
		collectionView.collectionViewLayout.invalidateLayout()
	}
	
}

// MARK: - Public Helpers
public extension NumPad {
	
	/// Returns the item at the specified position.
	func item(forPosition position: Position) -> Item? {
		let indexPath = self.indexPath(forPosition: position)
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		return (cell as? Cell)?.item
	}
	
}

// MARK: - Private Helpers
extension NumPad {
	
	/// Returns the index path at the specified position.
	func indexPath(forPosition position: Position) -> NSIndexPath {
		return NSIndexPath(forItem: position.column, inSection: position.row)
	}
	
	/// Returns the position at the specified index path.
	func position(forIndexPath indexPath: NSIndexPath) -> Position {
		return Position(row: indexPath.section, column: indexPath.item)
	}
	
}

// MARK: - CollectionView
class CollectionView: UICollectionView {
	
	weak var numPad: NumPad!
	
}

// MARK: - UICollectionViewDataSource
extension CollectionView: UICollectionViewDataSource {
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return numPad.rowCount
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return numPad.coloumCount
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let position = numPad.position(forIndexPath: indexPath)
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(Cell), forIndexPath: indexPath) as! Cell
		let item = numPad.dataSource?.numPad(numPad, itemAtPosition: position) ?? Item()
		cell.item = item
		
		cell.buttonTapped = { [unowned self] _ in
			self.numPad.delegate?.numPad(self.numPad, itemTapped: item, atPosition: position)
		}
		return cell
	}
	
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionView: UICollectionViewDelegateFlowLayout {
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let position = numPad.position(forIndexPath: indexPath)
		let size = numPad.delegate?.numPad(numPad, sizeForItemAtPosition: position) ?? CGSize()
		
		return !size.isZero() ? size : {
			let indexPath = numPad.indexPath(forPosition: position)
			var size = collectionView.frame.size
			
			let sectionCount = CGFloat(self.numberOfSectionsInCollectionView(self))
			let rowCount = CGFloat(self.collectionView(self, numberOfItemsInSection: indexPath.section))
			
			size.width = size.width / rowCount
			size.height = size.height / sectionCount
			return size
			}()
	}
	
}

// MARK: - Cell
class Cell: UICollectionViewCell {
	
	lazy var button: UIButton = { [unowned self] in
		let button = UIButton(type: .Custom)
		button.titleLabel?.textAlignment = .Center
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(_buttonTapped), forControlEvents: .TouchUpInside)
		self.contentView.addSubview(button)
		let views = ["button": button]
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-1-[button]|", options: [], metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-1-[button]|", options: [], metrics: nil, views: views))
		return button
		}()
	
	var item: Item! {
		didSet
		{
			button.setTitle(item.title, forState: .Normal)
			
			button.setTitleColor(item.titleColor, forState: .Normal)
			
			button.titleLabel?.font = item.font
			
			button.setImage(item.image, forState: .Normal)
			
			var image = item.backgroundColor.map { UIImage(color: $0) }
			button.setBackgroundImage(image, forState: .Normal)
			image = item.selectedBackgroundColor.map { UIImage(color: $0) }
			button.setBackgroundImage(image, forState: .Highlighted)
			button.setBackgroundImage(image, forState: .Selected)
			button.tintColor = item.titleColor
		}
	}
	
	var buttonTapped: (UIButton -> Void)?
	
	@IBAction func _buttonTapped(button: UIButton) {
		buttonTapped?(button)
	}
	
}

// MARK: - UIImage
extension UIImage {
	
	convenience init(color: UIColor) {
		let size = CGSize(width: 1, height: 1)
		let rect = CGRect(origin: CGPoint(), size: size)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.init(CGImage: image.CGImage!)
	}
	
}

// MARK: - CGSize
extension CGSize {
	
	func isZero() -> Bool {
		return CGSizeEqualToSize(self, CGSize())
	}
	
}

// custom
// MARK: - NumPadDelegate
public protocol FormattedNumPadDelegate: class {
	
	/// The item was tapped handler.
	func numPad(numPad: FormattedNumPad, valueChanged value: Double)
}


public class FormattedNumPad: UIView,  NumPadDelegate, NumPadDataSource
{
	public var delegate: FormattedNumPadDelegate? = nil
	public var numberFormatter: NSNumberFormatter!
	public var autoDecimal: Bool = true
	
	public var buttonTitles: [[String]]
	{
		set
		{
			numPad.buttonTitles = newValue
		}
		
		get
		{
			return numPad.buttonTitles
		}
	}
	
	public var externalTextField: UITextField? = nil
	{
		didSet
		{
			// remove internal Text field
			self.textField.removeFromSuperview()
			
			if self.textField.tag == 1 { return }
			self.textField.tag = 1
			
			let views = ["containerView": containerView, "numPad": numPad]
			self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView]|", options: [], metrics: nil, views: views))
			containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[numPad]|", options: [], metrics: nil, views: views))
		}
	}
	
	private var editingTextField: UITextField
	{
		return self.externalTextField ?? self.textField
	}
	
	private let borderColor = UIColor(white: 0.9, alpha: 1)
	
	private lazy var containerView: UIView = { [unowned self] in
		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.layer.borderColor = self.borderColor.CGColor
		containerView.layer.borderWidth = 1
		self.addSubview(containerView)
		return containerView
		}()
	
	private lazy var textField: UITextField = { [unowned self] in
		let textField = UITextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.textAlignment = .Right
		textField.textColor = UIColor(white: 0.3, alpha: 1)
		textField.font = .systemFontOfSize(40)
		textField.placeholder = self.numberFormatter.stringFromNumber(0.0)
		textField.enabled = false
		self.containerView.addSubview(textField)
		return textField
		}()
	
	private lazy var numPad: NumPad = { [unowned self] in
		
		let numPad = NumPad()
		numPad.delegate = self
		numPad.dataSource = self
		numPad.translatesAutoresizingMaskIntoConstraints = false
		numPad.backgroundColor = self.borderColor
		self.containerView.addSubview(numPad)
		return numPad
		
		}()
	
	override internal init(frame: CGRect)
	{
		super.init(frame: frame)
		self.commonInit()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}
	
	private func commonInit()
	{
		self.numberFormatter = NSNumberFormatter()
		self.numberFormatter?.numberStyle = .DecimalStyle
		self.numberFormatter?.maximumFractionDigits = 2
		self.numberFormatter?.minimumFractionDigits = 2
		self.numberFormatter?.decimalSeparator = ","
		self.numberFormatter?.groupingSeparator = "."
		self.numberFormatter?.currencySymbol = "P"
		
		let views = ["containerView": containerView, "textField": textField, "numPad": numPad]
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[containerView]|", options: [], metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView]|", options: [], metrics: nil, views: views))
		containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[textField]-20-|", options: [], metrics: nil, views: views))
		containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[numPad]|", options: [], metrics: nil, views: views))
		containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[textField(==60)][numPad]|", options: [], metrics: nil, views: views))
	}
	
	public var doubleValue: Double
	{
		set
		{
			if newValue == 0
			{
				self.editingTextField.text = nil
			}
			else
			{
				self.editingTextField.text = self.numberFormatter.stringFromNumber(newValue)
			}
		}
		get
		{
			let rawString = self.editingTextField.text!.isEmpty ? "0" : self.editingTextField.text!
			let sanitizedString = self.autoDecimal ? self.sanitizedString(rawString) : rawString
			let digits = NSDecimalNumber(string: sanitizedString)
			
			if self.autoDecimal
			{
				let decimalPlace = NSDecimalNumber(double: pow(10.0, Double(self.numberFormatter.minimumFractionDigits)))
				return digits.decimalNumberByDividingBy(decimalPlace).doubleValue
			}
			
			print("Sanitized String: \(sanitizedString)")
			return self.numberFormatter.numberFromString(sanitizedString)!.doubleValue
		}
	}
	
	private func sanitizedString(string: String) -> String
	{
		let set = NSCharacterSet.decimalDigitCharacterSet().invertedSet
		return string.componentsSeparatedByCharactersInSet(set).joinWithSeparator("")
	}
	
	public func numPad(numPad: NumPad, itemTapped item: Item, atPosition position: Position)
	{
		let title = numPad.buttonTitles[position.row][position.column]
		
		switch title
		{
		case "C":
			self.editingTextField.text = nil
			break
			
		default:
			
			if self.autoDecimal
			{
				let item = numPad.item(forPosition: position)!
				let rawString = "\(self.doubleValue)" + item.title!
				
				if Int(rawString) == 0
				{
					self.editingTextField.text = nil
				}
				else
				{
					self.editingTextField.text = rawString
					self.editingTextField.text = self.numberFormatter.stringFromNumber(self.doubleValue)
				}
			}
			
			// raw
			else
			{
				let item = numPad.item(forPosition: position)!
				var rawString = self.editingTextField.text! + item.title!
			
				if item.title! == self.numberFormatter.decimalSeparator &&
				   self.editingTextField.text!.containsString(self.numberFormatter.decimalSeparator)
				{
					return
				}
				
				if rawString == self.numberFormatter.decimalSeparator
				{
					rawString = "0" + item.title!
				}
			
				if Int(rawString) == 0
				{
					self.editingTextField.text = nil
				}
				else
				{
					self.editingTextField.text = rawString
				}
			}
		}
		
		self.delegate?.numPad(self, valueChanged: self.doubleValue)
	}
	
	public func numPad(numPad: NumPad, itemAtPosition position: Position) -> Item {
		var item = Item()
		item.title = numPad.buttonTitles[position.row][position.column]
		item.titleColor =  item.title == "C" ? .orangeColor() : UIColor(white: 0.3, alpha: 1)
		item.font = .systemFontOfSize(20)
		
		// item.backgroundColor = colors[position.column]
		return item
	}
}