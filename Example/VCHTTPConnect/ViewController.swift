//
//  ViewController.swift
//  VCHTTPConnect
//
//  Created by ripventura on 05/29/2017.
//  Copyright (c) 2017 ripventura. All rights reserved.
//

import UIKit
import VCHTTPConnect
import VCSwiftToolkit

class ViewController: UIViewController {
    
    var connector: VCHTTPConnect = VCHTTPConnect(url: "https://jsonplaceholder.typicode.com/posts")
    
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var responseDataTextView: UITextView!
    @IBOutlet weak var mainActivityIndicator: UIActivityIndicatorView!

    
    @IBAction func getButtonPressed(_ sender: Any) {
        self.updateInterface(loading: true)
        self.startGETRequest()
    }
    @IBAction func postButtonPressed(_ sender: Any) {
        self.updateInterface(loading: true)
        self.startPOSTRequest()
    }
    
    
    func updateInterface(loading : Bool) {
        if loading {
            self.mainActivityIndicator.startAnimating()
        } else {
            self.mainActivityIndicator.stopAnimating()
        }
        
        self.getButton.isEnabled = !loading
        self.postButton.isEnabled = !loading
    }
    
    func startGETRequest() {
        self.connector.parameters = [:]
        self.connector.get(path: "") { (success, response) in
            self.statusLabel.text = String(format: "%d", response.statusCode!)
            
            var text: String = "Nothing to show here..."
            
            if let modelsDict = response.data?.vcAnyFromJSON() as? [[String:Any]] {
                text = ""
                
                for modelDict in modelsDict {
                    if let demoModel = DemoModel(JSON: modelDict) {
                        text = text + "\n\n Title: " + demoModel.title! + "\nBody: " + demoModel.body!
                    }
                }
            }
            self.responseDataTextView.text = text
            self.updateInterface(loading: false)
        }
    }
    
    func startPOSTRequest() {
        let demoModel = DemoModel(JSON: [:])
        
        self.connector.parameters = demoModel!.toJSON()
        connector.post(path: "") { (success, response) in
            self.statusLabel.text = String(format: "%d", response.statusCode!)
            
            self.responseDataTextView.text = "Nothing to show here..."
            
            self.responseDataTextView.text = (response.data?.vcAnyFromJSON() as? [String:Any])?.description
            
            self.updateInterface(loading: false)
        }
    }
}
