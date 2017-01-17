//
//  ViewController.swift
//  OpenTweet
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        let theTweetData = NSData(contentsOfFile:"timeline.json");
        var json: [String: AnyObject]
        do {
          //  json = try JSONSerialization.JSONObjectWithData(theTweetData as! Data, options: []) as? [String:Any]
            json = try JSONSerialization.jsonObject(with:theTweetData! as Data, options: []) as! [String: AnyObject]
            NSLog("theTweetDict = %@", json);
        } catch {
            print(error)
        }

        
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

