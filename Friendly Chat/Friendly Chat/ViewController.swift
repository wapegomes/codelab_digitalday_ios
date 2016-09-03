//
//  ViewController.swift
//  Friendly Chat
//
//  Created by Jean Fellipe de Almeida Pimentel on 9/2/16.
//  Copyright © 2016 CI&T. All rights reserved.
//

import UIKit
import Photos

import Kingfisher

import Firebase

// MARK: - Life Cycle

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }

    @IBOutlet weak var inputField: UITextField! {
        didSet {
            self.inputField.delegate = self
            self.inputField.inputAccessoryView = UIView()
        }
    }

    @IBOutlet weak var imageButton: UIButton!


    var user: FIRUser?

    var databaseHandle: FIRDatabaseHandle!
    var databaseReference: FIRDatabaseReference!

    var storageReference: FIRStorageReference!


    var messages: [Message] = [] {
        didSet {
            self.tableView.reloadData()

            if self.messages.count > 0 {
                let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }

        self.user = user

        configureDatabase()
        configureStorage()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        guard user != nil else {
            performSegueWithIdentifier(Constants.Segues.ShowLogin, sender: nil)
            return
        }
    }

}

// MARK: - Firebase

extension ViewController {

    func configureDatabase() {

        databaseReference = FIRDatabase.database().reference()
        databaseHandle = databaseReference.child("messages").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in

            guard let dictionary = snapshot.value as? Dictionary<String, String> else {
                return
            }

            let message = Message.from(dictionary: dictionary)
            self.messages.append(message)
        })
    }

    func configureStorage() {
        storageReference = FIRStorage.storage().referenceForURL("gs://digitalday-aba51.appspot.com")
    }
}

// MARK: - Actions

extension ViewController {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: MessageCell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell

        let message: Message! = self.messages[indexPath.row]

        let photoUrl = NSURL(string: message.avatar ?? "")
        cell.myImageView.kf_setImageWithURL(photoUrl, placeholderImage: UIImage(named: "Avatar"))

        cell.labelName.text = message.name

        if message.type == "message" {
            cell.labelMessage.text = message.text
            cell.labelMessage.hidden = false
            cell.imageMessage.hidden = true
        } else {
            if let photo = message.photo, messageUrl = NSURL(string: photo) {
                cell.imageMessage.kf_setImageWithURL(messageUrl)
            } else {
                cell.imageMessage.image = UIImage(named: "Error")
            }
            cell.labelMessage.hidden = true
            cell.imageMessage.hidden = false
        }


        return cell
    }

}

// MARK: - Actions

extension ViewController {

    @IBAction func logout(sender: AnyObject) {
        do {
            try FIRAuth.auth()?.signOut()
            GIDSignIn.sharedInstance().signOut()

            self.user = nil

            performSegueWithIdentifier(Constants.Segues.ShowLogin, sender: nil)
        }
        catch {

        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == inputField {
            textField.resignFirstResponder()
            sendMessage(text: textField.text)
            textField.text = nil
            return false
        }
        return true
    }

    func sendMessage(text text: String?) {
        let message = Message(
            name: user?.displayName ?? "anonymous",
            avatar: user?.photoURL?.absoluteString,
            type: "message",
            text: text,
            photo: nil)

        self.databaseReference.child("messages").childByAutoId().setValue(message.toDictionary())
    }

    func sendMessage(image image: String?) {
        let message = Message(
            name: user?.displayName ?? "anonymous",
            avatar: user?.photoURL?.absoluteString,
            type: "photo",
            text: nil,
            photo: image)

        self.databaseReference.child("messages").childByAutoId().setValue(message.toDictionary())
    }

    @IBAction func openGallery(sender: AnyObject) {

        let picker = UIImagePickerController()
        picker.delegate = self

        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = .Camera
        } else {
            picker.sourceType = .PhotoLibrary
        }

        presentViewController(picker, animated: true, completion:nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion:nil)

        if let referenceUrl = info[UIImagePickerControllerReferenceURL] {
            let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl as! NSURL], options: nil)

            let asset = assets.firstObject
            asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
                let imageFile = contentEditingInput?.fullSizeImageURL
                let filePath = "\(FIRAuth.auth()?.currentUser?.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(referenceUrl.lastPathComponent!)"
                self.storageReference.child(filePath)
                    .putFile(imageFile!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading: \(error.description)")
                            return
                        }

                        let url = metadata?.downloadURL()?.absoluteString
                        self.sendMessage(image: url)
                }
            })
        } else {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let imagePath = FIRAuth.auth()!.currentUser!.uid +
                "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000)).jpg"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            self.storageReference.child(imagePath)
                .putData(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading: \(error)")
                        return
                    }

                    let url = metadata?.downloadURL()?.absoluteString
                    self.sendMessage(image: url)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }

}


// MARK: - Helpers

extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
}