//
//  CheckboxDialogViewController.swift
//  Pods
//
//  Created by Kristijan Kontus on 16/12/2016.
//
//

import UIKit
import Foundation

//define global typealias-es
public typealias TranslationTuple = (name: String, translated: String)
public typealias TranslationDictionary = [String : String]

public enum DialogCheckboxViewEnum {
    case countries
}

public protocol CheckboxDialogViewDelegate : class {
    func onCheckboxPickerValueChange(_ component: DialogCheckboxViewEnum, values: TranslationDictionary)
}

open class CheckboxDialogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate let dialogViewWidth: CGFloat = 300.0
    fileprivate var dialogViewHeight: CGFloat = 462.0
    
    fileprivate var dialogView: UIView!
    fileprivate let titleView = UIView()
    fileprivate let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    fileprivate let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    fileprivate let cancelButton = UIButton()
    fileprivate let okButton = UIButton()
    fileprivate let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    fileprivate var dialogHeightConstraint: NSLayoutConstraint?
    
    fileprivate var selectedValues: [String : String] = [:] // property that stores selected values (will be stored to user defaults on OK, or restored to default values on Cancel)
    fileprivate var temporarySelectedValues: [(name: String, translated: String)]? // property that stores values from user defaults and shouldn't be change after is set on viewDidLoad
    
    //properties exposed to developer/user
    open var titleDialog: String = ""
    open var tableData: [(name: String, translated: String)] = [] // all values in the table
    open var defaultValues: [(name: String, translated: String)] = [] // values loaded from user defaults and shouldn't be change in this class (used on cancel selection and restoring preselected values)
    open var componentName: DialogCheckboxViewEnum?
    open weak var delegateDialogTableView: CheckboxDialogViewDelegate?
    
    deinit {
        print("\(type(of: self)) was deallocated")
    }
    
    override open func viewDidLoad() {
        print("\(type(of: self)) did load")
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // color to represent dialog as modal view
        
        temporarySelectedValues = defaultValues // this is important because we need initial data if we select Cancel after rotation (rotation causes issues because of reusing cells)
        selectedValues.removeAll(keepingCapacity: false) //empty selected values
        selectedValues = tuplesToDictionary(tuples: temporarySelectedValues!) //preselect columns that we loaded from user defaults
        
        showDialogView()
    }
    
    @objc func okButtonAction(_ sender: UIButton!) {
        // on OK pressed we need to set selectedValues
        self.delegateDialogTableView?.onCheckboxPickerValueChange(self.componentName!, values: self.selectedValues)
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func cancelButtonAction(_ sender: UIButton!) {
        // on Cancel pressed we need to restore to default values (values that we loaded from user defaults, no matter what we selected in meantime)
        selectedValues = tuplesToDictionary(tuples: defaultValues) //preselect columns that we loaded from user defaults
        
        self.delegateDialogTableView?.onCheckboxPickerValueChange(self.componentName!, values: self.selectedValues)
        self.dismiss(animated: false, completion: nil)
    }
    
    func showDialogView() {
        createDialogView()
        createTitleView()
        createTitleLabel()
        createTableView()
        createCancelButton()
        createOkButton()
        createStackView()
        self.view.layoutIfNeeded()
    }
    
    func createDialogView() {
        dialogView = UIView()
        dialogView.layer.borderWidth = 1
        dialogView.layer.borderColor = UIColor.defaultDialogBorderColor().cgColor
        dialogView.layer.cornerRadius = 8.0
        dialogView.clipsToBounds = true
        dialogView.backgroundColor = UIColor.white
        
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dialogView)
        
        dialogView.widthAnchor.constraint(equalToConstant: dialogViewWidth).isActive = true
        dialogView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dialogView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func createTitleView() {
        titleView.backgroundColor = UIColor.white
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        self.dialogView.addSubview(titleView)
        
        titleView.widthAnchor.constraint(equalToConstant: dialogViewWidth).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        titleView.centerXAnchor.constraint(equalTo: self.dialogView.centerXAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: self.dialogView.topAnchor).isActive = true
    }
    
    func createTitleLabel() {
        let title = titleDialog
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel.text = title
        titleLabel.textColor = UIColor.defaultDialogTextColor()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.addSubview(titleLabel)
        
        titleLabel.widthAnchor.constraint(equalToConstant: dialogViewWidth-10).isActive = true // 10 is for padding, 5 on each side since we have centerX
        titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    }
    
    func createTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
        //tableView.allowsMultipleSelection = true //swipable with delete
        tableView.setEditing(true, animated: false)
        tableView.bounces = false
        tableView.backgroundColor = UIColor.white
        
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 21))
        tableView.tableHeaderView?.backgroundColor = UIColor.white
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 21))
        tableView.tableFooterView?.backgroundColor = UIColor.white
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.dialogView.addSubview(tableView)
        
        tableView.widthAnchor.constraint(equalToConstant: 270.0).isActive = true
        tableView.centerXAnchor.constraint(equalTo: self.dialogView.centerXAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.titleView.bottomAnchor).isActive = true
        // vertical spacing to stackview (bottom anchor) is added on stackview since here stackview doesn't exist yet
    }
    
    func createCancelButton() {
        cancelButton.backgroundColor   = UIColor.white
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.defaultDialogBorderColor().cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        cancelButton.setTitle("Cancel", for: UIControl.State.normal)
        cancelButton.setTitleColor(UIColor.defaultButtonTextColor(), for: UIControl.State())
        cancelButton.widthAnchor.constraint(equalToConstant: dialogViewWidth / 2).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    }
    
    func createOkButton() {
        okButton.backgroundColor   = UIColor.white
        okButton.layer.borderWidth = 1
        okButton.layer.borderColor = UIColor.defaultDialogBorderColor().cgColor
        okButton.setTitle("OK", for: UIControl.State.normal)
        okButton.addTarget(self, action: #selector(okButtonAction), for: .touchUpInside)
        okButton.setTitleColor(UIColor.defaultButtonTextColor(), for: UIControl.State())
        okButton.widthAnchor.constraint(equalToConstant: dialogViewWidth / 2).isActive = true
        okButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    }
    
    func createStackView() {
        stackView.backgroundColor = UIColor.white
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 0.0
        
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(okButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.dialogView.addSubview(stackView)
        
        stackView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.dialogView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.dialogView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.dialogView.bottomAnchor).isActive = true
        
        // vartical spacing to tableView
        stackView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor).isActive = true
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        resizeDialogView()
        tableView.reloadData()
    }
    
    func resizeDialogView() {
        // remove constraints before applying new one
        removeDialogViewHeightConstraint()
        
        dialogViewHeight = calculateDialogViewHeight()
        let height = UIScreen.main.bounds.height
        if height < dialogViewHeight {
            dialogViewHeight = height - 40 // device screen height - arbitrary value so dialog doesn't take full screen height
        }
        
        // apply new constraints
        addDialogViewHeightConstraint()
    }
    
    func addDialogViewHeightConstraint() {
        dialogHeightConstraint = dialogView.heightAnchor.constraint(equalToConstant: dialogViewHeight)
        dialogHeightConstraint?.isActive = true
    }
    
    func removeDialogViewHeightConstraint() {
        if dialogHeightConstraint != nil {
            dialogHeightConstraint?.isActive = false
            dialogView.removeConstraint(dialogHeightConstraint!)
        }
    }
    
    func calculateDialogViewHeight() -> CGFloat {
        // cell height * number of cells + 3 more cell heights so we have enough space for title and buttons
        return CheckboxViewCell.height() * CGFloat(tableData.count) + (CheckboxViewCell.height() * 3)
    }
    
    func tuplesToDictionary(tuples: [TranslationTuple]) -> TranslationDictionary {
        var dictionary: TranslationDictionary = [:]
        for tuple in tuples {
            dictionary[tuple.name] = tuple.translated
        }
        return dictionary
    }
    
    func dictionaryToTuples(dictionary: TranslationDictionary) -> [TranslationTuple] {
        var tuple: [TranslationTuple] = []
        for (name, translated) in dictionary {
            tuple.append((name: name, translated: translated))
        }
        return tuple
    }
    
    func tupleContainsByTuple(_ haystack: [TranslationTuple], needle: TranslationTuple) -> Bool {
        return haystack.contains { $0.name == needle.name && $0.translated == needle.translated }
    }
    
    // UITableView Delegates and DataSource
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CheckboxViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: CheckboxViewCell.identifier)
        
        let object = tableData[indexPath.row]
        cell.setData(object)
        
        // used for showing correct data on orientation change (in landscape mode since it reuses cells)
        temporarySelectedValues = dictionaryToTuples(dictionary: selectedValues)
        
        //preselect values from user defaults
        if (temporarySelectedValues?.count)! > 0 && tupleContainsByTuple(temporarySelectedValues!, needle: (name: object.name, translated: object.translated)) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = tableData[indexPath.row]
        
        selectedValues[object.name] = object.translated
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let object = tableData[indexPath.row]
        
        selectedValues.removeValue(forKey: object.name)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CheckboxViewCell.height()
    }
    
}


