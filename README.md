# Code Together: Let's make iPhone app in an hour

  <div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/reminder-app.png" width="50%" height="50%"/></div>  

  Thank you for visiting our account. We are going to make a simple reminder app in an hour. If would you like to study yourself before hands-on, or review what you have learned in the session, please use the following material.

## Meetup
We are providing free hands-on on a monthly basis

https://www.meetup.com/iOS-Development-Meetup-for-Beginner/

## Development Environment
  Xcode 9 / Swift 4
  
  ・<a href="https://github.com/learn-co-students/reading-ios-intro-to-xcode-qa-public-001">What is Xcode?</a>

# Full procedure

## 0, Create your project

> Open Xcode  
> Select "Create a new Xcode project"  
> Select "Single View Application" and then tap "Next"  
> Fill "Product name" and then tap "Next"  
> Select the place for saving your project and then tap "Create"  

> <details><summary>Start a project</summary><div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid1.gif" /></div></details>

## 1, Design your app

#### 🗂 Main.storyboard

1-1. Add 5 labels to the main view controller
> <details><summary>How to add a label to the storyboard</summary><div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid2.gif" /></div></details>
> <details><summary>Customize label</summary><div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid3.gif" /></div></details>
> Add 5 more labels to this view for "HH", "MM", "00:00", "Reminder title" and "details". Just like in the app picture.

1-2. Add two sliders to the view.
> <details><summary>How to add a slider to the storyboad</summary><div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid4.gif" /></div></details>
> Add another slider for "MM" label. This time set maximum value to be 59
> <details><summary>How to add tags to sliders</summary><div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid5.gif" /></div></details>

1-3. Add two texfields to the view.
> <details><summary>How to add a textfield to the storyboad</summary><div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid6.gif" /></div></details>
> Add another textfield under "Details:" label


1-4. Add a "Set reminder" button.
> <details><summary>How to add a button to the storyboad</summary><div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid7.gif" /></div></details>

## 2, Connect to the ViewController

#### 🗂 Main.storyboard -> ViewController.swift

2-1. Connect outlets + actions

★ control + drag in storyboard to create a control segue

> <details><summary>How to connect outlet</summary><div style="text-align:center"><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid8.gif" /><img src ="https://github.com/iosClassForBeginner/reminder_en/blob/master/vids/vid9.gif" /></div></details>

## 4, Add code blocks in ViewController.swift

★ It's preferable to write following code yourself. It will help you to understand code more.

```Swift
//  Created by Sam on 2018-02-02.

// VERY IMPORTANT: DO NOT COPY/PASTE code to your app. Try following the lecture and writing the code yourself and look at available choices in each method you use. I have intentionally renamed a few things, so copy pasting will break your code.
import UIKit
import UserNotifications

class ViewController: UIViewController
{
    @IBOutlet weak var remindAbout: UITextField!
    @IBOutlet weak var details: UITextField!
    @IBOutlet weak var timeDisplay: UILabel!
    
    
    // We use global variables that can be accessed by all functions inside this class
    var hour: Int = 0
    var minute: Int = 0
    var center: UNUserNotificationCenter!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Assign UITextFieldDelegates to both UITetFields. We want them to dismiss keyboard when their return key is pressed.
        // It is required for our ViewController to adopt UITextFieldDelegate protocol. So we have done it in the extension section below.
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
                // We can use this to enabled a previously disabled "Set reminder" button so user can now set a notification. Otherwise they shouldn't be able to do it. We are not implementing it for this lecture.
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
    
    // We are going to assign this method to BOTH of our sliders and we will differentiate them by their tags.
    // Right click drag from BOTH sliders to this function.
    @IBAction func sliderMoved(_ sender: UISlider)
    {
        // In the storyboard we have set the tags for each slider. Now we want to check which slider is making the call.
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
        
        
        // We are setting up some criteria's to match with for triggering the notification.
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
```
