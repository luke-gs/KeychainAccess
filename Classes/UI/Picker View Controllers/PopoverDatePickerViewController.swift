//
//  PopoverDatePickerViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 9/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate let cellID = "CellID"

fileprivate let datePickerHeightAdjustment: CGFloat = 20.0


/// A date picker view controller designed to be presented modally as a popover.
///
/// `PopoverDatePickerViewController` is designed to be presented standalone as a popover,
/// and internally manages embedding itself inside a navigation controller when adapting
/// to a compact trait environment. When your view controller may transition into a compact
/// environment, you should consider setting an appropriate title.
///
/// `PopoverDatePickerViewController` also adapts correctly to being pushed onto a navigation
/// stack.
open class PopoverDatePickerViewController: FormTableViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Public properties
    
    /// The date picker for the controller. This is lazily loaded.
    open private(set) lazy var datePicker: UIDatePicker = { [unowned self] in
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.addTarget(self, action: #selector(datePickerDateDidChange), for: .valueChanged)
        return datePicker
    }()
    
    
    open override var preferredContentSize: CGSize {
        get {
            return super.preferredContentSize
        }
        set {
            super.preferredContentSize = newValue
        }
    }
    
    /// The date update handler.
    /// 
    /// This closure is called every time the date picker's date changes.
    ///
    /// You should avoid setting target action directly, and instead use either
    /// this method, or it's companion `finishUpdateHandler`.
    open var dateUpdateHandler: ((Date) -> Void)?
    
    
    /// The finish update handler.
    ///
    /// This closure is called when the view controller is dismissed or popped off a
    /// navigation stack.
    ///
    /// You should avoid setting target action directly, and instead use either
    /// this method, or it's companion `dateUpdateHandler`.
    open var finishUpdateHandler: ((Date) -> Void)?
    
    
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
    
    open override var wantsTransparentBackground: Bool {
        get {
            return isInPopover || super.wantsTransparentBackground
        }
        set {
            super.wantsTransparentBackground = newValue
        }
    }
    
    
    // MARK: - Private properties
    
    private var isInPopover = false {
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
        calculatesContentHeight = false
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        if let tableView = self.tableView {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
            tableView.rowHeight = datePicker.intrinsicContentSize.height - datePickerHeightAdjustment
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
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed || isMovingFromParentViewController {
            finishUpdateHandler?(datePicker.date)
        }
    }
    
    open override func apply(_ theme: Theme) {
        
        // WORKAROUND: Cannot change the color of text, especially in dark mode.
        // This is PRIVATE API and should be checked on each iOS version.
        // Has been consistent since iOS 7.
        datePicker.setValue(primaryTextColor ?? secondaryTextColor, forKey: "textColor")
        
        let selector = Selector(("setHighlightsToday:"))
        if datePicker.responds(to: selector) {
            datePicker.perform(selector, with: false)
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
        if contentView != datePicker.superview {
            datePicker.frame = contentView.frame
            datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(datePicker)
        }
        
        return cell
    }
    
    
    // MARK: - Containment changes
    
    open override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        isInPopover = parent == nil
    }
    
    
    // MARK - UIPopoverPresentationControllerDelegate methods
    
    public func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        isInPopover = self.parent == nil
    }
    
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
        guard let tableView = self.tableView else { return }
        
        tableView.isScrollEnabled = isInPopover == false
        
        if isInPopover {
            navigationItem.rightBarButtonItem = nil
            
            let intrinsicPickerSize = datePicker.intrinsicContentSize
            let correctContentSize = CGSize(width: intrinsicPickerSize.width, height: intrinsicPickerSize.height - datePickerHeightAdjustment)
            
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
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
            preferredContentSize = CGSize(width: preferredContentSize.width, height: tableView.contentSize.height)
        }
        
        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }
    
    @objc private func datePickerDateDidChange() {
        dateUpdateHandler?(datePicker.date)
    }
    
    @objc private func doneButtonItemDidSelect(_ item: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}
