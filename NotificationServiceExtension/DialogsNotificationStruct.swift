//
//  DialogsNotificationStruct.swift
//  NotificationServiceExtension
//
//  Created by cristian parra on 25-02-21.
//

import Foundation

struct GenericStringNotification: Codable{
    var type: String!
    var typeDialog: String?
    var notificationVideo: String?
    var notificationDialog: String?
}

struct GenericNotification: Codable {
    var type: String!
    var typeDialog: String?
    var notificationVideo: VideoNotification?
    var notificationDialog: NotificationDialog?

    enum CodingKeys: String, CodingKey {
        case type
        case notificationDialog
        case notificationVideo
        case typeDialog = "type_dialog"
    }
}

struct NotificationDialog: Codable {
    var textBody: String
    var imageUrl: String
    var isPersistent: Bool = true
    var isCancelable: Bool = true
    var buttons: [Button]?

    enum CodingKeys: String, CodingKey {
        case buttons
        case imageUrl = "image_url"
        case textBody = "text_body"
    }
}

struct VideoNotification: Codable {
    var videoUrl: String
    var minPlayTime: String
    var isPersistent: Bool? = true
    var isSound: Bool? = true
    var isPlaying: Bool? = true
    var buttons: [Button]

    enum CodingKeys: String, CodingKey {
        case buttons
        case videoUrl = "video_url"
        case minPlayTime = "min_play_time"
        case isSound
        case isPlaying
    }
}

struct Button: Codable {
    var type: String
    var text: String
    var color: String
    var action: String
}
