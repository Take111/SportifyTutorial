//
//  SceneDelegate.swift
//  SpotifyTurtorial
//
//  Created by 竹ノ内愛斗 on 2020/03/11.
//  Copyright © 2020 竹ノ内愛斗. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate{
    
    var window: UIWindow?
    
    static private let kAccessTokenKey = "access-token-key"
    private let clientID = "fb90177288a6425291fec90114e2fd0b"
    private let redirectURL = URL(string: "ChikatoTakenouchi.SpotifyTurtorial://SpotifyAuthentication")!
    
    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectURL)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
            print("SceneDelegate: accessToken: \(accessToken)")
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("SceneDelegate: openURLContexts is called")
        guard let url = URLContexts.first?.url else {
            return
        }
        // authoricationParameters()これがAccessTokenかエラーを返す
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
            print("SceneDelegate: openURLContexts: \(accessToken)")
        }
        else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("SceneDelegate: errorDescription has error: \(errorDescription)")
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("SceneDelegate: sceneDidBecomeActive")
        connect()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("SceneDelegate: connect disconect")
        appRemote.disconnect()
    }
    
    func connect() {
        print("SceneDelegate: connect called")
        appRemote.connect()
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        print("SceneDelegate: appRemote The transport that has connected.")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("SceneDelegate: didFailConnectionAttemptWithError")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("SceneDelegate: didDisconnectWithError")
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window =  UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = ViewController(nibName: nil, bundle: nil)
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

