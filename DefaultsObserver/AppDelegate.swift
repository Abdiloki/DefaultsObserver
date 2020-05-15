//
//  AppDelegate.swift
//  DefaultsObserver
//
//  Created by Kaunteya Suryawanshi on 15/05/20.
//  Copyright © 2020 Kaunteya Suryawanshi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        UserDefaults.standard.set("FOUND", forKey: "kaunteya")

        let def = UserDefaults(suiteName: "com.kaunteya.lexi")
        print(def?.dictionaryRepresentation())
    }
}
