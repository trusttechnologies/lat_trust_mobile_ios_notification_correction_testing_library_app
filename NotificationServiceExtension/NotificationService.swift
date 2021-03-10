//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by cristian parra on 08-03-21.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    var downloadTask: URLSessionDownloadTask?
    var url:String?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let genericStringNotification = parseStringNotification(content: request.content.userInfo)
        switch genericStringNotification.type {
        case "dialog":
            let dialogNotification = parseDialog(content: genericStringNotification)
            url = dialogNotification.imageUrl
        case "banner":
            let dialogNotification = parseDialog(content: genericStringNotification)
            url = dialogNotification.imageUrl
        case "video":
            let videoNotification = parseVideo(content: genericStringNotification)
            url = videoNotification.videoUrl
        default:
            print("error: must specify a notification type")
        }
        
        if let urlString = url, let fileUrl = URL(string: urlString) {
            // Download the attachment
            URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
                if let location = location {
                    // Move temporary file to remove .tmp extension
                    let tmpDirectory = NSTemporaryDirectory()
                    let tmpFile = "file://".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
                    let tmpUrl = URL(string: tmpFile)!
                    try! FileManager.default.moveItem(at: location, to: tmpUrl)
                    
                    // Add the attachment to the notification content
                    if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl) {
                        self.bestAttemptContent?.attachments = [attachment]
                    }
                }
                // Serve the notification content
                self.contentHandler!(self.bestAttemptContent!)
            }.resume()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
