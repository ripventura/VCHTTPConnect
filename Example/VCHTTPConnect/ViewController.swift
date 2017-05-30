//
//  ViewController.swift
//  VCHTTPConnect
//
//  Created by ripventura on 05/29/2017.
//  Copyright (c) 2017 ripventura. All rights reserved.
//

import UIKit
import VCHTTPConnect

class ViewController: UIViewController {
    
    var datastore: DemoDatastore = DemoDatastore()
    
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
        datastore.find(filter: [:], completionHandler: {response, models in
            self.statusLabel.text = String(format: "%d", response.statusCode!)
            
            var text: String = "Nothing to show here..."
            
            if let models = models {
                text = ""
                
                for model in models {
                    let demoModel: DemoModel = model as! DemoModel
                    
                    text = text + "\n\n Title: " + demoModel.title! + "\nBody: " + demoModel.body!
                }
            }
            self.responseDataTextView.text = text
            self.updateInterface(loading: false)
        })
    }
    
    func startPOSTRequest() {
        let demoModel = DemoModel(JSON: [:])
        
        demoModel?.create(completionHandler: {success, response in
            self.statusLabel.text = String(format: "%d", response.statusCode!)
            
            self.responseDataTextView.text = "Nothing to show here..."
            
            if response.data != nil {
                do {
                    let jsonObject : Any = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    self.responseDataTextView.text = (jsonObject as? [String : Any])?.description
                }
                catch {
                }
            }
            
            self.updateInterface(loading: false)
        })
    }
}
