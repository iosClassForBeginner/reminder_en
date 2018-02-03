//
//  ViewController.swift
//  alarm
//
//  Created by Sam on 2018-02-02.
//  Copyright © 2018 Sam Kheirandish. All rights reserved.
//



// VERY IMPORTANT: DO NOT COPY/PASTE code to your app. Try following the lecture and writing the code yourself and look at available choises in each method you use. I have intentionally renamed a few things, so copy pasting will break your code.
import UIKit
import UserNotifications

class ViewController: UIViewController
{
    @IBOutlet weak var remindAbout: UITextField!
    @IBOutlet weak var details: UITextField!
    @IBOutlet weak var timeDisplay: UILabel!
    var hour: Int = 0
    var minute: Int = 0
    var center: UNUserNotificationCenter!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Assign UITextFieldDelegates to both UITetFields. We want them to dismiss keyboard when their return key is pressed
        remindAbout.delegate = self
        details.delegate = self
        
        // Get an instance of our device notification center
        center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Each time the app opens and is directed to this view we want to check if the application has permissions to send notifications
        center.requestAuthorization(options: [.alert, .badge, .sound])
        { (granted, error) in
            if granted
            {
                print("We have access to notifications.")
                // We can use this to enabled a previously disabled "Set reminder" button so user can now set a notification. Otherwise they shouldnt be able to do it. We are not implementing it for this lecture.
                // You can do it as a challenge.
                // Hint: connect the "set reminder" button to this view controller and on viewDidLoad disable the button
            }
            else
            {
                print("No permission to send notifications.")
                // Show a msg or an alert that user needs to grant access to the app to send notifications.
                // We wont cover it in this lecture. As a challenge try to implement it yourself.
                // Hint: use UIAlertController: https://developer.apple.com/documentation/uikit/uialertcontroller
                // Example: https://medium.com/ios-os-x-development/how-to-use-uialertcontroller-in-swift-70143d7fbede
            }
        }
    }
    
    // We are going to assign this method to BOTH of our sliders and we will differenciate them by their tags.
    // Right click drag from BOTH sliders to this function.
    @IBAction func sliderMoved(_ sender: UISlider)
    {
        // In the storyboard we have set the tags for each slider. Now we want to check which slider is making the request.
        switch sender.tag
        {
        case 1:
            self.hour = Int(sender.value)
        default:
            self.minute = Int(sender.value)
        }
        timeDisplay.text = "\(self.hour):\(self.minute)"
    }
    
    @IBAction func setReminder(_ sender: Any)
    {
        // Create the content thats going to be displayed to the user through the notification
        let content = UNMutableNotificationContent()
        content.title = "Reminder:"
        content.body = "\(remindAbout.text ?? "")"
        content.userInfo = ["details": "\(details.text ?? "")"]
        content.sound = UNNotificationSound.default()
        // We need this identifier tag to later add actions to this notification
        content.categoryIdentifier = "Reminder"
        
        
        // We are setting up some criterias to match with for triggering the notification.
        // Things you can look for include but not limited to year, month, day, hour, minute, second, nanosecond, weekday, weekOfMonth, weekOfYear, yearForWeekOfYear
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add buttons (actions) to the notification.
        let show = UNNotificationAction(identifier: "details", title: "Tell me more…", options: .foreground)
        let goAway = UNNotificationAction(identifier: "fine", title: "Dismiss", options: .destructive)
        
        // Now add these actions to the notification. The identifier should match the content's "categoryIdentifier"
        let category = UNNotificationCategory(identifier: "Reminder", actions: [show, goAway], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
        center.add(request)
    }
}

extension ViewController: UNUserNotificationCenterDelegate
{
    // Notification Center Delegate will handle responses. Following function will tell us what the user's response was so we can react to it accordingly.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        // Response has the user info which we created previously. There we can find our message and we can properly handle it.
        let userInfo = response.notification.request.content.userInfo
        
        if let details = userInfo["details"] as? String
        {
            print("Notification data received")
            
            switch response.actionIdentifier
            {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
                
            case "details":
                // the action that user took was that he/she pressed on the "Tell me more..." button
                print("Here are the details: \(details)")
                break
                
            default:
                break
            }
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
}

extension ViewController: UITextFieldDelegate {
    
    // Text Field Delegate handles actions associated with the UITextFields.
    // Following method handles when the return button is clicked.
    // In this case we just want the keyboard to dismiss.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

