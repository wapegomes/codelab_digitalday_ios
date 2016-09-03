//
//  MessageCell.swift
//  Friendly Chat
//
//  Created by Jean Fellipe de Almeida Pimentel on 9/3/16.
//  Copyright © 2016 CI&T. All rights reserved.
//

import Foundation

class MessageCell: UITableViewCell {

    @IBOutlet weak var myImageView: UIImageView! {
        didSet {
            self.myImageView.layer.cornerRadius = 50/2;
            self.myImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var imageMessage: UIImageView! {
        didSet {
            self.imageMessage.clipsToBounds = true
            self.imageMessage.contentMode = .ScaleAspectFit
        }
    }
}