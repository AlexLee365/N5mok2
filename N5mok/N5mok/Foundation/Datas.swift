//
//  Datas.swift
//  N5mok
//
//  Created by hyeoktae kwon on 22/05/2019.
//  Copyright © 2019 hyeoktae kwon. All rights reserved.
//

import Foundation
import Firebase
import UIKit

let notiCenter = NotificationCenter.default

let findFameVC = FindGameVC()

let dbRef = Database.database().reference()

let popUpVC = PopUpVC()

let challengerVC = ChallengerVC()

var userNames = [String] ()

// MARK: - User
struct User {
    let name: String
    let loginState: Bool
    let playerImg: UIImage
    let turn: Bool
    let vs: String
    let winCount: Int
    let loseCount: Int
}

var usersInfo = [User]()

struct Time {
    static let short = 0.3
    static let middle = 0.65
    static let long = 1.0
}

struct UI {
    static let menuCount = 3
    static let menuSize: CGFloat = 40
    static let distance: CGFloat = 45
    static let minScale: CGFloat = 0.3
}

var playerID: String = ""
var playerVS: String = ""

var amIChallenger = false {
    willSet(newValue) {
        let name = Notification.Name("SendTurn1")
        notiCenter.post(name: name, object: nil, userInfo: ["turn" : newValue])
        let name2 = Notification.Name("SendTurn2")
        notiCenter.post(name: name2, object: nil, userInfo: ["turn" : newValue])
    }
}

var firstAmI = false

var playerProfileImg = UIImage()

func uploadUserInfo(completion: @escaping ()->()) {
    let data = playerProfileImg.toString()
        
    dbRef.child("Users").child(playerID).updateChildValues(["playerImg":data ?? ""])
    dbRef.child("Users").child(playerID).updateChildValues(["turn":false])
    dbRef.child("Users").child(playerID).updateChildValues(["vs":""])
    dbRef.child("Users").child(playerID).updateChildValues(["loginState":true])
    dbRef.child("Users").child(playerID).child("winCount").observeSingleEvent(of: .value) { (snap) in
        if (snap.value as? Int) == nil {
            dbRef.child("Users").child(playerID).updateChildValues(["winCount":0])
        }
    }
    dbRef.child("Users").child(playerID).child("loseCount").observeSingleEvent(of: .value) { (snap) in
        if (snap.value as? Int) == nil {
            dbRef.child("Users").child(playerID).updateChildValues(["loseCount":0])
        }
    }
    
    completion()
    
}

func toFalseLoginState(completion: @escaping ()->()) {
    dbRef.child("Users").child(playerID).updateChildValues(["loginState":false])
    completion()
}

func downloadUsersInfo(completion: @escaping (Bool)->()) {
    dbRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as! [String: Any]
        var updateUsersInfo = [User]()
        userNames = value.keys.sorted()
        
        for idx in  userNames {
            let data = value[idx]
            let detailData = data as! [String:Any]
            let state = detailData["loginState"] as! Bool
            let img = (detailData["playerImg"] as! String).toImage()
            let myTurn = detailData["turn"] as! Bool
            let enemy = detailData["vs"] as! String
            let winCount = detailData["winCount"] as! Int
            let loseCount = detailData["loseCount"] as! Int
            
            updateUsersInfo.append(User(name: idx, loginState: state, playerImg: img!, turn: myTurn, vs: enemy, winCount: winCount, loseCount: loseCount))
        }
        usersInfo = updateUsersInfo
        completion(true)
    }) { (error) in
        completion(false)
        print("error: ", error.localizedDescription)
    }
}

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
}

extension UIImage {
    func toString() -> String? {
    return self.pngData()?.base64EncodedString(options: .endLineWithLineFeed)
    }
}
