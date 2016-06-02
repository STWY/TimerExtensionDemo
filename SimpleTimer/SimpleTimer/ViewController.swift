//
//  ViewController.swift
//  SimpleTimer
//
//  Created by 王 巍 on 14-8-1.
//  Copyright (c) 2014年 OneV's Den. All rights reserved.
//

import UIKit
import SimpleTimerKit

let defaultTimeInterval: NSTimeInterval = 10
let taskDidFinishedInWidgetNotification: String = "com.onevcat.simpleTimer.TaskDidFinishedInWidgetNotification"

class ViewController: UIViewController {
                            
    @IBOutlet weak var lblTimer: UILabel!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(ViewController.applicationWillResignActive),name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(ViewController.taskFinishedInWidget), name: taskDidFinishedInWidgetNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateLabel() {
        lblTimer.text = timer.leftTimeString
    }
    
    private func showFinishAlert(finished: Bool) {
        let ac = UIAlertController(title: nil , message: finished ? "Finished" : "Stopped", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: {[weak ac] action in ac!.dismissViewControllerAnimated(true, completion: nil)}))
            
        presentViewController(ac, animated: true, completion: nil)
    }
    
    dynamic private func applicationWillResignActive() {
        if timer == nil {
            clearDefaults()
        } else {
            if timer.running {
                saveDefaults()
            } else {
                clearDefaults()
            }
        }
    }
    
    dynamic private func taskFinishedInWidget() {
        if let realTimer = timer {
            let (stopped, error) = realTimer.stop(false)
            if !stopped {
                if let realError = error {
                    print("error: \(realError.code)")
                }
            }
        }
    }
    
    private func saveDefaults() {
        if let userDefault = NSUserDefaults(suiteName: "group.simpleTimerSharedDefaults") {
            userDefault.setInteger(Int(timer.leftTime), forKey: keyLeftTime)
            userDefault.setInteger(Int(NSDate().timeIntervalSince1970), forKey: keyQuitDate)
            
            userDefault.synchronize()
        }
    }
    
    private func clearDefaults() {
        if let userDefault = NSUserDefaults(suiteName: "group.simpleTimerSharedDefaults") {
            userDefault.removeObjectForKey(keyLeftTime)
            userDefault.removeObjectForKey(keyQuitDate)
            
            userDefault.synchronize()
        }
    }

    @IBAction func btnStartPressed(sender: AnyObject) {
        if timer == nil {
            timer = Timer(timeInteral: defaultTimeInterval)
        }
        
        let (started, error) = timer.start({
                [weak self] leftTick in self!.updateLabel()
            }, stopHandler: {
                [weak self] finished in
                self!.showFinishAlert(finished)
                self!.timer = nil
            })
        
        if started {
            updateLabel()
        } else {
            if let realError = error {
                print("error: \(realError.code)")
            }
        }
    }
    
    @IBAction func btnStopPressed(sender: AnyObject) {
        if let realTimer = timer {
            let (stopped, error) = realTimer.stop(true)
            if !stopped {
                if let realError = error {
                    print("error: \(realError.code)")
                }
            }
        }
    }

}

