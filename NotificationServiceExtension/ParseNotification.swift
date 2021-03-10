//
//  ParseNotification.swift
//  NotificationServiceExtension
//
//  Created by cristian parra on 25-02-21.
//

import UIKit
import Foundation

func parseStringNotification(content: [AnyHashable: Any]) -> GenericStringNotification {

    //take the notification content and convert it to data
    guard let jsonData = try? JSONSerialization.data(withJSONObject: content["data"], options: .prettyPrinted)
        else {
            print("Parsing notification error: Review your JSON structure")
            return GenericStringNotification()
    }

    //decode the notification with the structure of a generic notification
    let jsonDecoder = JSONDecoder()
    guard let notDialog = try? jsonDecoder.decode(GenericStringNotification.self, from: jsonData) else {
        print("Parsing notification error: Review your JSON structure")
        return GenericStringNotification() }

    return notDialog
}



func parseDialog(content: GenericStringNotification) -> NotificationDialog {

    let contentAsString = content.notificationDialog?.replacingOccurrences(of: "\'", with: "\"", options: .literal, range: nil)
    //let replacingApos = contentAsString?.replacingOccurrences(of: "&apos;", with: "'", options: .literal, range: nil)

    let jsonDecoder = JSONDecoder()
    let dialogNotification = try? jsonDecoder.decode(NotificationDialog.self, from: contentAsString!.data(using: .utf8)!)

    return dialogNotification ?? NotificationDialog(textBody: "", imageUrl: "", isPersistent: false, isCancelable: true, buttons: [])
}

func parseVideo(content: GenericStringNotification) -> VideoNotification {

    let contentAsString = content.notificationVideo?.replacingOccurrences(of: "\'", with: "\"", options: .literal, range: nil)
    //let replacingApos = contentAsString?.replacingOccurrences(of: "&apos;", with: "'", options: .literal, range: nil)

    let jsonDecoder = JSONDecoder()
    guard let videoNotification = try? jsonDecoder.decode(VideoNotification.self, from: contentAsString!.data(using: .utf8)!) else {
        return VideoNotification(videoUrl: "", minPlayTime: "0.0", isPersistent: false, buttons: [])
    }
    return videoNotification
}
