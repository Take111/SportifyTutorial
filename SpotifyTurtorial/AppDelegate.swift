//
//  AppDelegate.swift
//  SpotifyTurtorial
//
//  Created by 竹ノ内愛斗 on 2020/03/11.
//  Copyright © 2020 竹ノ内愛斗. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    
    
    
    
    let spotifyClientID = "ff04f43449bb427db274d376d5565cfd"
    let spotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    
    let playURI = "spotify:track:5Gbgx64AeuCcXIFys7ymqK"
    
    lazy var configuration = SPTConfiguration(clientID: spotifyClientID, redirectURL: spotifyRedirectURL)
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        
        return appRemote
    }()
    
    var accessToken: String?
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        self.appRemote.connectionParameters.accessToken = session.accessToken
        self.appRemote.connect()
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Appdelegate: sssionManager: error: \(error)")
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Appdelegate: didEstablish")
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Appdelegate: didFailConnectionAttemptWithError: \(error)")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Appdelegate: didDisconnectWithError: \(error)")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("Appdelegate: playerStateDidChange")
        
        debugPrint("Track name: %@", playerState.track.name)
    }
    
    func connect() {
        self.appRemote.authorizeAndPlayURI(self.playURI)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Appdelegate: ")
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        }
        else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("Appdelegate: application has error")
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("AppDelegate: didFinishLaunchingWithOptions")
        let requestedScopes: SPTScope = [.appRemoteControl]
        
        return true
    }
    
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

