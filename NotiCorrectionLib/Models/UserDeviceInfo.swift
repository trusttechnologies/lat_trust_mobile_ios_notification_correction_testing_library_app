//
//  UserDeviceInfo.swift
//  NotiCorrectionLib
//
//  Created by cristian parra on 01-03-21.
//

import TrustDeviceInfo

struct UserDeviceInfo: IdentityInfoDataSource {
    var dni: String
    var name: String?
    var lastname: String?
    var email: String?
    var phone: String?
    var appleUserId: String?
}
