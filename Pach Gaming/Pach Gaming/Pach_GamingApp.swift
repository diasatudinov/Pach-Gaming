//
//  Pach_GamingApp.swift
//  Pach Gaming
//
//

import SwiftUI

@main
struct Pach_GamingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
       
       var body: some Scene {
           WindowGroup {
               ASGRoot()
                   .preferredColorScheme(.light)
           }
       }
   }
