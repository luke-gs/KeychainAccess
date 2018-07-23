//
//  SignatureViewController.swift
//  MPOLKit
//
//  Created by QHMW64 on 21/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public protocol SignatureViewControllerDelegate: class {
    func controllerDidCancelIn(_ controller: SignatureViewController)
    func controller(_ controller: SignatureViewController, didFinishWithSignature signature: UIImage?)
}

open class SignatureViewController: UIViewController {

    public weak var delegate: SignatureViewControllerDelegate?
    private lazy var signatureView: SignatureView = SignatureView()

    private lazy var doneButton: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        doneButton.isEnabled = false
        return doneButton
    }()

    fileprivate lazy var clearButton: UIButton = {
        let clearButton = UIButton(type: .custom)
        clearButton.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        clearButton.setTitleColor(.lightGray, for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("CLEAR SIGNATURE", for: .normal)
        clearButton.isEnabled = false
        return clearButton
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)

        title = "Capture Signature"

//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = doneButton
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .gray

        signatureView.translatesAutoresizingMaskIntoConstraints = false
        signatureView.delegate = self
        signatureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(signatureView)



        // Placeholder icon for the clear button
        // Replace with actual Icon when ready
        clearButton.setImage(AssetManager.shared.image(forKey: .info), for: .normal)
        clearButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -10.0, bottom: 0.0, right: 10.0)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        
        view.addSubview(clearButton)

        NSLayoutConstraint.activate([
            signatureView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            signatureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signatureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            signatureView.bottomAnchor.constraint(equalTo: clearButton.topAnchor),

            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            clearButton.heightAnchor.constraint(equalToConstant: 60.0),
            clearButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func cancelTapped() {
        delegate?.controllerDidCancelIn(self)
//        dismiss(animated: true, completion: nil)
    }

    @objc private func doneTapped() {
        delegate?.controller(self, didFinishWithSignature: signatureView.renderedImage())
//        dismiss(animated: true, completion: nil)
    }

    @objc private func clearTapped() {
        signatureView.clear()
        updateButtonStates()
    }

    private func updateButtonStates() {
        let containsSignature = signatureView.containsSignature
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.doneButton.isEnabled = containsSignature
            self.clearButton.isEnabled = containsSignature
            self.clearButton.setTitleColor(containsSignature ? .darkGray : .lightGray, for: .normal)
        }

    }

}

extension SignatureViewController: SignatureViewResponder {
    public func didStartSigning() {
        updateButtonStates()
    }

    public func didEndSigning() {
        updateButtonStates()
    }


}
