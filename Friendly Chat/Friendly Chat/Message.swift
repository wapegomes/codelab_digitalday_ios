//
//  Message.swift
//  Friendly Chat
//
//  Created by Jean Fellipe de Almeida Pimentel on 9/2/16.
//  Copyright © 2016 CI&T. All rights reserved.
//

import Foundation

struct Message {

    let name: String
    let avatar: String?

    let type: String

    let text: String?
    let photo: String?

    static func from(dictionary dictionary: Dictionary<String, String>) -> Message {
        return Message(
            name: dictionary[Constants.MessageFields.name] ?? "anonymous",
            avatar: dictionary[Constants.MessageFields.avatar],
            type: dictionary[Constants.MessageFields.typeMessage] ?? "message",
            text: dictionary[Constants.MessageFields.text],
            photo: dictionary[Constants.MessageFields.photo]
        )
    }

    func toDictionary() -> [String: String] {
        var dictionary = [String: String]()

        dictionary[Constants.MessageFields.name] = name
        dictionary[Constants.MessageFields.avatar] = avatar ?? ""
        dictionary[Constants.MessageFields.typeMessage] = type
        dictionary[Constants.MessageFields.text] = text ?? ""
        dictionary[Constants.MessageFields.photo] = photo ?? ""
        
        return dictionary
    }
}