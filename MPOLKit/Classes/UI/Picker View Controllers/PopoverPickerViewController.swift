//
//  PopoverPickerViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 15/4/17.
//
//

import UIKit

fileprivate let cellID = "CellID"

fileprivate let pickerHeightAdjustment: CGFloat = 20.0


/// A picker view controller designed to be presented modally as a popover.
///
/// You can either subclass this class, or set another class as the picker's data source
/// and delegate.
///
/// `PopoverPickerViewController` is designed to be presented standalone as a popover,
/// and internally manages embedding itself inside a navigation controller when adapting
/// to a compact trait environment. When your view controller may transition into a compact
/// environment, you should consider setting an appropriate title.
///
/// `PopoverPickerViewController` also adapts correctly to being pushed onto a navigation
/// stack.
open class PopoverPickerViewController: FormTableViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Public properties
    
    /// The date picker for the controller. This is lazily loaded.
    open private(set) lazy var pickerView: UIPickerView = UIPickerView(frame: .zero)
    
    
    /// The modal presentation style for the controller.
    ///
    /// `PopoverDatePickerViewController` restricts its own `modalPresentationStyle`
    /// to `.popover`.
    open override var modalPresentationStyle: UIModalPresentationStyle {
        get { return super.modalPresentationStyle }
        set { }
    }
    
    open override var cellBackgroundColor: UIColor? {
        get { return isInPopover ? .clear : super.cellBackgroundColor }
    }
    
    open override var separatorColor: UIColor? {
        get { return isInPopover ? .clear : super.separatorColor }
    }
    
    
    // MARK: - Private properties
    
    private var isInPopover = true {
        didSet {
            updateForPresentationStyle()
        }
    }
    
    private var isAdaptationChanging: Bool = false
    
    
    // MARK: - Initialzation
    
    public init() {
        super.init(style: .grouped)
        super.modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        wantsCalculatedContentSize = false
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        if let tableView = self.tableView {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
            tableView.rowHeight = pickerView.intrinsicContentSize.height - pickerHeightAdjustment
        }
        
        super.viewDidLoad()
        
        updateForPresentationStyle()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if parent == nil, let tableView = self.tableView {
            let cellRect = tableView.rectForRow(at: IndexPath(row: 0, section: 0))
            tableView.contentOffset = CGPoint(x: 0.0, y: cellRect.minY)
        }
    }
    
    
    // MARK: - UITableViewDataSource methods
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.selectionStyle = .none
        
        let contentView = cell.contentView
        if contentView != pickerView.superview {
            pickerView.frame = contentView.frame
            pickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(pickerView)
        }
        
        return cell
    }
    
    // MARK: - Containment changes
    
    open override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        isInPopover = parent != nil
    }
    
    
    // MARK - UIPopoverPresentationControllerDelegate methods
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.horizontalSizeClass == .compact { return .fullScreen }
        return .none
    }
    
    public func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        if style == .fullScreen {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonItemDidSelect))
            return UINavigationController(rootViewController: self)
        }
        
        return nil
    }
    
    public func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        isAdaptationChanging = true
        isInPopover = style == .none
        isAdaptationChanging = false
        
        if isInPopover {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateForPresentationStyle() {
        wantsTransparentBackground = isInPopover
        
        guard let tableView = self.tableView else { return }
        
        tableView.isScrollEnabled = isInPopover == false
        
        if isInPopover {
            navigationItem.rightBarButtonItem = nil
            
            let intrinsicPickerSize = pickerView.intrinsicContentSize
            let correctContentSize = CGSize(width: intrinsicPickerSize.width, height: intrinsicPickerSize.height - pickerHeightAdjustment)
            
            if isAdaptationChanging {
                // Workaround:
                // When transitioning back to a popover, updates to the content size during the
                //`presentationController(_:, willPresentWithAdaptiveStyle:, transitionCoordinator:)` are temporarily ignored.
                // Delay the call to update.
                DispatchQueue.main.async {
                    self.preferredContentSize = correctContentSize
                }
            } else {
                preferredContentSize = correctContentSize
            }
        } else {
            preferredContentSize = CGSize(width: 320.0, height: tableView.contentSize.height)
        }
        
        applyCurrentTheme()
    }
    
    @objc private func doneButtonItemDidSelect(_ item: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}
