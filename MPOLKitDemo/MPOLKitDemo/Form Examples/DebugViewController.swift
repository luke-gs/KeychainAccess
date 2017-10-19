//
//  DebugViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 4/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class DebugViewController: UIViewController {

    public let json: Data

    public init(json: Data) {
        self.json = json
        super.init(nibName: nil, bundle: nil)

        title = "JSON"

        let item = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(DebugViewController.dismissAction(_:)))
        navigationItem.leftBarButtonItem = item
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let webview = UIWebView()
        self.view = webview

        let url = URL(string: "http://localhost")!
        webview.load(json, mimeType: "application/json", textEncodingName: "utf-8", baseURL: url)
    }

    @objc private func dismissAction(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }

}
