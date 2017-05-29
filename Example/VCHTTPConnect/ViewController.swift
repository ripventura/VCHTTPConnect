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
    
    var httpConnector = VCHTTPConnect(url: "https://jsonplaceholder.typicode.com")
    
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var responseDataTextView: UITextView!
    @IBOutlet weak var mainActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
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
        httpConnector.get(path: "/posts/1", handler: {success, response in
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
    
    func startPOSTRequest() {
        // POST body
        httpConnector.parameters = ["title":"foo", "body":"bar", "userId":1];
        
        httpConnector.post(path: "/posts", handler: {success, response in
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
