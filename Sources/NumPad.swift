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
    public var backgroundColor: UIColor? = .white
    public var selectedBackgroundColor: UIColor? = .clear
    public var image: UIImage?
    public var title: String?
    public var titleColor: UIColor? = .black
    public var font: UIFont? = .systemFont(ofSize: 17)
    
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
    func numPad(_ numPad: NumPad, itemAtPosition position: Position) -> Item
}

// MARK: - NumPadDelegate
public protocol NumPadDelegate: class {
    
    /// The item was tapped handler.
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position)
    
    /// The size of an item at position.
    func numPad(_ numPad: NumPad, sizeForItemAtPosition position: Position) -> CGSize
    
}

public extension NumPadDelegate {
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position) {}
    func numPad(_ numPad: NumPad, sizeForItemAtPosition position: Position) -> CGSize
    {
        let width = round((numPad.frame.size.width) / CGFloat(numPad.coloumCount))
        let height = round((numPad.frame.size.height) / CGFloat(numPad.rowCount))
        return CGSize(width, height)
    }
}

extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}

// MARK: - NumPad
open class NumPad: UIView {
    
    var  rowCount: Int { return self.buttonTitles.count }
    var  coloumCount: Int { return self.buttonTitles.first?.count ?? 0}
    //
    //    /// The number of columns.
    //    func numPad(numPad: NumPad, numberOfColumnsInRow row: Row) -> Int
    
    // default numbers
    var buttonTitles: [[String]] = [[""]]
    {
        didSet
        {
            self.collectionView.reloadData()
        }
    }
    
    open override var tintColor: UIColor!
        {
        didSet
        {
            self.collectionView.reloadData()
        }
    }
    
    open func reloadButtonTitles()
    {
        self.collectionView.reloadData()
    }
    
    lazy var collectionView: UICollectionView = { [unowned self] in
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = CollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        collectionView.numPad = self
        collectionView.dataSource = collectionView
        collectionView.delegate = collectionView
        collectionView.register(Cell.self, forCellWithReuseIdentifier: String(describing: Cell.self))
        self.addSubview(collectionView)
        let views = ["collectionView": collectionView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views))
        return collectionView
        }()
    
    /// Data source for the number pad.
    open weak var dataSource: NumPadDataSource?
    
    /// Delegate for the number pad.
    open weak var delegate: NumPadDelegate?
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

// MARK: - Public Helpers
public extension NumPad {
    
    /// Returns the item at the specified position.
    func item(forPosition position: Position) -> Item? {
        let indexPath = self.indexPath(forPosition: position)
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        return (cell as? Cell)?.item
    }
    
}

// MARK: - Private Helpers
extension NumPad {
    
    /// Returns the index path at the specified position.
    func indexPath(forPosition position: Position) -> IndexPath {
        return IndexPath(item: position.column, section: position.row)
    }
    
    /// Returns the position at the specified index path.
    func position(forIndexPath indexPath: IndexPath) -> Position {
        return Position(row: indexPath.section, column: indexPath.item)
    }
}

// MARK: - CollectionView
class CollectionView: UICollectionView {
    
    weak var numPad: NumPad!
    
}

// MARK: - UICollectionViewDataSource
extension CollectionView: UICollectionViewDataSource {
    @available(iOS 6.0, *)
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numPad.rowCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numPad.coloumCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
        
        let position = numPad.position(forIndexPath: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Cell.self), for: indexPath as IndexPath) as! Cell
        let item = numPad.dataSource?.numPad(numPad, itemAtPosition: position) ?? Item()
        cell.item = item
        cell.clipsToBounds = true
        cell.contentView.clipsToBounds = true
        
        cell.buttonTapped = { [weak self] _ in
            if let s = self
            {
                s.numPad.delegate?.numPad(s.numPad, itemTapped: item, atPosition: position)
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let position = numPad.position(forIndexPath: indexPath)
        let size = numPad.delegate?.numPad(numPad, sizeForItemAtPosition: position) ?? CGSize()
        
        return !size.isZero() ? size : {
            _ = numPad.indexPath(forPosition: position)
            var size = collectionView.frame.size
            
            size.width = (collectionView.frame.size.width) / CGFloat(numPad.coloumCount)
            size.height = (collectionView.frame.size.height) / CGFloat(numPad.rowCount)
            return size
            }()
    }
}

// MARK: - Cell
class Cell: UICollectionViewCell {
    
    lazy var button: UIButton = { [unowned self] in
        
        let button = UIButton(type: .custom)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 2
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(_buttonTapped), for: .touchUpInside)
        self.contentView.addSubview(button)
        let views = ["button": button]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-1-[button]|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-1-[button]|", options: [], metrics: nil, views: views))
        return button
        }()
    
    var item: Item!
    {
        didSet
        {
            button.setTitle(item.title, for: .normal)
            button.setTitleColor(item.titleColor, for: .normal)
            button.titleLabel?.font = item.font
            button.setImage(item.image, for: .normal)
            
            var image = item.backgroundColor.map { UIImage(color: $0) }
            button.setBackgroundImage(image, for: .normal)
            image = item.selectedBackgroundColor.map { UIImage(color: $0) }
            button.setBackgroundImage(image, for: .highlighted)
            button.setBackgroundImage(image, for: .selected)
            button.tintColor = item.titleColor
            
            if item.title!.isEmpty
            {
                button.isEnabled = false
            }
        }
    }
    
    var buttonTapped: ((UIButton) -> Void)?
    
    @IBAction func _buttonTapped(_ button: UIButton) {
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
        self.init(cgImage: (image?.cgImage!)!)
    }
    
}

// MARK: - CGSize
extension CGSize {
    
    func isZero() -> Bool {
        return self.equalTo(CGSize())
    }
}

// custom
// MARK: - NumPadDelegate
@objc public protocol FormattedNumPadDelegate: class {
    
    /// The item was tapped handler.
    @objc optional func numPad(_ numPad: FormattedNumPad, valueChanged value: Double)
    @objc optional func numPad(_ numPad: FormattedNumPad, numericButtonTapped title: String)
    @objc optional func numPad(_ numPad: FormattedNumPad, nonNumericButtonTapped title: String)
}


open class FormattedNumPad: UIView,  NumPadDelegate, NumPadDataSource
{
    open class func createDecimalTypePad(usingDecimalSeparator separator: String) -> [[String]]
    {
        return [["7", "8", "9"],
                ["4", "5", "6"],
                ["1", "2", "3"],
                ["C", separator, "0"]]
    }
    
    open class var nonDecimalTypePad: [[String]]
    {
        return [["7", "8", "9"],
                ["4", "5", "6"],
                ["1", "2", "3"],
                ["C", "0", "00"]]
    }
    
    open weak var delegate: FormattedNumPadDelegate? = nil
    open var numberFormatter: NumberFormatter!
    open var autoDecimal: Bool = true
    
    open var buttonFont: UIFont? = nil
        {
        didSet
        {
            if let font = buttonFont
            {
                self.nonNumericButtonFont = UIFont(name: font.fontName, size: font.pointSize - 3)
                return
            }
            
            self.numPad.reloadButtonTitles()
        }
    }
    
    fileprivate var nonNumericButtonFont: UIFont?
    {
        didSet
        {
            self.numPad.reloadButtonTitles()
        }
    }
    
    open var buttonTitles: [[String]]
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
    
    open var clear: Bool = true
    open var externalTextField: UITextField? = nil
        {
        didSet
        {
            for constraint in self.containerView.constraints
            {
                if constraint.firstAttribute == .height ||
                    constraint.firstAttribute == .top ||
                    constraint.firstAttribute == .bottom
                {
                    constraint.constant = 0.0
                }
            }
            
            for constraint in self.textField.constraints
            {
                if constraint.firstAttribute == .height ||
                    constraint.firstAttribute == .top ||
                    constraint.firstAttribute == .bottom
                {
                    constraint.constant = 0.0
                }
            }
            
            self.clear = true
        }
    }
    
    open var editingTextField: UITextField
    {
        return self.externalTextField ?? self.textField
    }
    
    fileprivate let borderColor = UIColor(white: 0.9, alpha: 1)
    
    fileprivate lazy var containerView: UIView = { [unowned self] in
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderColor = self.borderColor.cgColor
        containerView.layer.borderWidth = 1
        self.addSubview(containerView)
        return containerView
        }()
    
    fileprivate lazy var textField: UITextField = { [unowned self] in
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .right
        textField.adjustsFontSizeToFitWidth = true
        textField.textColor = UIColor(white: 0.3, alpha: 1)
        textField.font = .boldSystemFont(ofSize: 40)
        textField.placeholder = self.numberFormatter.string(from: 0.0)
        textField.isEnabled = false
        self.containerView.addSubview(textField)
        return textField
        }()
    
    fileprivate lazy var numPad: NumPad = { [unowned self] in
        
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
    
    fileprivate func commonInit()
    {
        self.numberFormatter = NumberFormatter()
        self.numberFormatter?.numberStyle = .decimal
        self.numberFormatter?.maximumFractionDigits = 2
        self.numberFormatter?.minimumFractionDigits = 2
        self.numberFormatter?.decimalSeparator = "."
        self.numberFormatter?.groupingSeparator = ","
        self.numberFormatter?.currencySymbol = "P"
        
        let views = ["containerView": containerView, "textField": textField, "numPad": numPad]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: views))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[textField]-20-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[textField(60)][numPad]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[numPad]|", options: [], metrics: nil, views: views))
    }
    
    open var doubleValue: Double
        {
        set
        {
            if newValue == 0.0
            {
                self.editingTextField.text = nil
            }
            else
            {
                self.editingTextField.text = self.numberFormatter.string(from: newValue as NSNumber)
            }
        }
        
        get
        {
            let rawString = self.editingTextField.text!.isEmpty ? "0" : self.editingTextField.text!
            let sanitizedString = self.autoDecimal ? self.sanitizedString(rawString) :  self.removeNonDigitCharacter(rawString)
            let digits = NSDecimalNumber(string: sanitizedString)
            
            print("raw sTring:", rawString, "Sanitized String: \(sanitizedString)")
            
            if self.autoDecimal
            {
                let decimalPlace = NSDecimalNumber(decimal: pow(10.0, self.numberFormatter.minimumFractionDigits))
                return digits.dividing(by: decimalPlace).doubleValue
            }
            
            return self.numberFormatter.number(from: sanitizedString)!.doubleValue
        }
    }
    
    fileprivate func removeNonDigitCharacter(_ string: String) -> String
    {
        let set = CharacterSet(charactersIn: "1234567890.").inverted
        return string.components(separatedBy: set).joined(separator: "")
    }
    
    fileprivate func sanitizedString(_ string: String) -> String
    {
        let set = CharacterSet.decimalDigits.inverted
        return string.components(separatedBy: set).joined(separator: "")
    }
    
    open func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position)
    {
        let title = numPad.buttonTitles[position.row][position.column]
        
        switch title
        {
        case "C":
            self.editingTextField.text = nil
            self.delegate?.numPad?(self, nonNumericButtonTapped: item.title!)
            return
            
        default:
            
            // non numeric
            if Double(item.title!) == nil && item.title! != self.numberFormatter.decimalSeparator
            {
                self.delegate?.numPad?(self, nonNumericButtonTapped: item.title!)
                return
            }
            
            if clear
            {
                self.editingTextField.text = nil
                self.clear = false
            }
            
            let item = numPad.item(forPosition: position)!
            var rawString = self.editingTextField.text! + item.title!
            
            if self.autoDecimal
            {
                if Double(rawString) == 0.0
                {
                    self.editingTextField.text = nil
                }
                else
                {
                    // denominatin
                    if let number = Double(item.title!), (number < 1.0 || number > 9.0) && (number != 0)
                    {
                        let sum = self.doubleValue + number
                        rawString = self.numberFormatter.string(from: sum as NSNumber)!
                    }
                    
                    self.editingTextField.text = rawString
                    self.editingTextField.text = self.numberFormatter.string(from: self.doubleValue as NSNumber)
                }
            }
                
                // raw
            else
            {
                if item.title! == self.numberFormatter.decimalSeparator &&
                    self.editingTextField.text!.contains(self.numberFormatter.decimalSeparator)
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
        
        self.delegate?.numPad?(self, numericButtonTapped: item.title!)
        self.delegate?.numPad?(self, valueChanged: self.doubleValue)
    }
    
    open func numPad(_ numPad: NumPad, itemAtPosition position: Position) -> Item
    {
        var item = Item()
        item.title = numPad.buttonTitles[position.row][position.column]
        
        // non numeric
        if Double(item.title!) == nil && item.title! != self.numberFormatter.decimalSeparator
        {
            item.font = self.nonNumericButtonFont ?? self.buttonFont
        }
        else
        {
            item.font = self.buttonFont
        }
        
        if let _ = Double(item.title!)
        {
            item.titleColor = UIColor(white: 0.3, alpha: 1)
        }
            
        else if item.title! == self.numberFormatter.decimalSeparator
        {
            item.titleColor = UIColor(white: 0.3, alpha: 1)
        }
            
        else
        {
            print("title:", item.title as Any)
            item.titleColor = numPad.tintColor
            item.backgroundColor = .white
        }
        
        // item.font = .systemFontOfSize(20)
        return item
    }
}
