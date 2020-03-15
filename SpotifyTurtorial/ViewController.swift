//
//  ViewController.swift
//  SpotifyTurtorial
//
//  Created by 竹ノ内愛斗 on 2020/03/11.
//  Copyright © 2020 竹ノ内愛斗. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    enum Status {
        case disconnected
        case connecting
        case connected
    }

    let buttonSize = CGSize(width: 20, height: 20)
    let imageSize = CGSize(width: 200, height: 200)
    let playerButtonSize = CGSize(width: 60, height: 60)
    
    private let playURI = "spotify:album:1htHMnxonxmyHdKE2uDFMR"
    private let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    
    var status: Status = .disconnected {
        didSet {
            DispatchQueue.main.async {
                self.authButtonUpdate()
            }
        }
    }
    
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var defaultCallBack: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print("ViewController: defaultCallBack has error: \(error)")
                }
            }
        }
    }
    
    var isPause = false {
        didSet {
            DispatchQueue.main.async {
                self.playButton.setImage(self.isPause ? UIImage(named: "play.png") : UIImage(named: "stop.png"), for: .normal)
            }
        }
    }
    
    // MARK: - ViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(authButton)
        view.addSubview(authTitle)
        view.addSubview(artistTitleLabel)
        view.addSubview(artistNameLabel)
        view.addSubview(songTitleLabel)
        view.addSubview(songNameLabel)
        view.addSubview(artworkImage)
        view.addSubview(playButton)
        view.addSubview(nextButton)
        view.addSubview(returnButton)

        authButtonUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subsripbePlayerState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubsribePlayerState()
    }

    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        
        let w = view.bounds.width
        let safeAreaTop = view.safeAreaInsets.top
        
        authButton.frame.size = buttonSize
        authButton.frame.origin.x = w - buttonSize.width - CGFloat(20)
        authButton.frame.origin.y = safeAreaTop
        
        authTitle.frame.size = authTitle.sizeThatFits(.zero)
        authTitle.frame.origin.x = authButton.frame.minX - authTitle.frame.size.width - CGFloat(10)
        authTitle.frame.origin.y = safeAreaTop
        
        artistTitleLabel.frame.size = artistTitleLabel.sizeThatFits(.zero)
        artistTitleLabel.frame.origin.x = (w - artistTitleLabel.frame.size.width) / 2
        artistTitleLabel.frame.origin.y = authButton.frame.maxY + CGFloat(50)
    
        artistNameLabel.frame.size = artistNameLabel.sizeThatFits(.zero)
        artistNameLabel.frame.origin.x = (w - artistNameLabel.frame.size.width) / 2
        artistNameLabel.frame.origin.y = artistTitleLabel.frame.maxY + CGFloat(10)

        songTitleLabel.frame.size = songTitleLabel.sizeThatFits(.zero)
        songTitleLabel.frame.origin.x = (w - songTitleLabel.frame.size.width) / 2
        songTitleLabel.frame.origin.y = artistNameLabel.frame.maxY + CGFloat(50)
        
        songNameLabel.frame.size = songNameLabel.sizeThatFits(.zero)
        songNameLabel.frame.origin.x = (w - songNameLabel.frame.size.width) / 2
        songNameLabel.frame.origin.y = songTitleLabel.frame.maxY + CGFloat(10)
        
        artworkImage.frame.size = imageSize
        artworkImage.frame.origin.x = (w - artworkImage.frame.size.width) / 2
        artworkImage.frame.origin.y = songNameLabel.frame.maxY + CGFloat(50)
        
        playButton.frame.size = playerButtonSize
        playButton.frame.origin.x = (w - playerButtonSize.width) / 2
        playButton.frame.origin.y = artworkImage.frame.maxY + CGFloat(50)
        
        nextButton.frame.size = playerButtonSize
        nextButton.frame.origin.x = playButton.frame.maxX + CGFloat(20)
        nextButton.frame.origin.y = playButton.frame.minY
        
        returnButton.frame.size = playerButtonSize
        returnButton.frame.origin.x = playButton.frame.minX - playerButtonSize.width - CGFloat(20)
        returnButton.frame.origin.y = playButton.frame.minY
    }

    // MARK: - Update
    
    func authButtonUpdate() {
        switch status {
        case .disconnected:
            authButton.backgroundColor = .red
        case .connecting:
            authButton.backgroundColor = .blue
        case .connected:
            authButton.backgroundColor = .green
        }
    }
    
    func updateUserInfo(with item: SPTAppRemotePlayerState) {
        songNameLabel.text = item.track.name
        artistNameLabel.text = item.track.artist.name
        fetchImage(track: item.track) { [weak self] (image) in
            guard let self = self else {
                return
            }
            self.artworkImage.image = image
        }
        isPause = item.isPaused
        view.setNeedsLayout()
    }
    
    // MARK: - Action
    
    func appRemoteConnected() {
        status = .connected
        appRemote?.playerAPI?.delegate = self
        
        subsripbePlayerState()
        fetchPlayerState()
    }
    
    func changeSongStatus() {
        if isPause {
            appRemote?.playerAPI?.pause(defaultCallBack)
        }
        else {
            appRemote?.playerAPI?.resume(defaultCallBack)
        }
    }
    
    @objc func didTappedNextButton() {
        appRemote?.playerAPI?.skip(toNext: defaultCallBack)
    }
    
    @objc func didTappedReturnButton() {
        appRemote?.playerAPI?.skip(toPrevious: defaultCallBack)
    }
    
    @objc func didTappedPlayButton() {
        isPause = !isPause
        changeSongStatus()
    }
    
    // MARK: - Action Spotify Fetch & Subsribe
    
    @objc func auth() {
        if appRemote?.isConnected == false  {
            print("ViewController: appRemote.is not Connected")
            if appRemote?.authorizeAndPlayURI(trackIdentifier, asRadio: true) == false {
                showAppStroreInstall()
                print("ViewController: appRemote?.authorizeAndPlayURI is false")
            }
            else {
                print("ViewController: appRemote?.authorizeAndPlayURI is true")
                print("ViewController: appRemote: \(appRemote?.isConnected)")
            }
        }
        else {
            print("ViewController: appRemote?.isConnected == false: \(appRemote?.isConnected) && appRemote?.playerAPI != nil: \(appRemote?.playerAPI)")
        }
    }
    
    func fetchPlayerState() {
        appRemote?.playerAPI?.getPlayerState({ (result, error) in
            if let error = error {
                print("ViewController: fetchPlayerState is failure: error: \(error)")
            }
            else {
                guard let state = result as? SPTAppRemotePlayerState else {
                    print("ViewController: fetchPlayerState: state is nil")
                    return
                }
                print("ViewController: fetchPlayerState: state: \(state)")
                DispatchQueue.main.async {
                    self.updateUserInfo(with: state)
                }
            }
        })
    }
    
    func fetchImage(track: SPTAppRemoteTrack, handler: @escaping (UIImage) -> Void) {
        appRemote?.imageAPI?.fetchImage(forItem: track, with: imageSize, callback: { (result, error) in
            if let error = error {
                print("ViewController: fetchImage is failure: error: \(error)")
            }
            else {
                guard let image = result as? UIImage else {
                    return
                }
                handler(image)
            }
        })
    }
    
    func subsripbePlayerState() {
        appRemote?.playerAPI?.subscribe(toPlayerState: defaultCallBack)
    }
    
    func unSubsribePlayerState() {
        appRemote?.playerAPI?.unsubscribe(toPlayerState: defaultCallBack)
    }
    
    
    // MARK: - Subviews
    
    lazy var authTitle: UILabel = {
        let v = UILabel()
        v.text = "Auth Status"
        v.textColor = .black
        return v
    }()
    
    lazy var authButton: UIButton = {
        let v = UIButton()
        v.addTarget(self, action: #selector(auth), for: .touchUpInside)
        v.backgroundColor = .black
        v.layer.masksToBounds = true
        v.layer.cornerRadius = buttonSize.width / 2
        return v
    }()
    
    lazy var songTitleLabel: UILabel = {
        let v = UILabel()
        v.textColor = .black
        v.text = "Song"
        v.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        return v
    }()
    
    lazy var songNameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        v.textColor = .black
        return v
    }()
    
    lazy var artistTitleLabel: UILabel = {
        let v = UILabel()
        v.textColor = .black
        v.text = "Artist"
        v.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        return v
    }()
    
    lazy var artistNameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        v.textColor = .black
        v.numberOfLines = 2
        return v
    }()
    
    lazy var artworkImage: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    lazy var nextButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "next.png"), for: .normal)
        v.tintColor = .black
        v.addTarget(self, action: #selector(didTappedNextButton), for: .touchUpInside)
        return v
    }()
    
    lazy var returnButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "return.png"), for: .normal)
        v.tintColor = .black
        v.addTarget(self, action: #selector(didTappedReturnButton), for: .touchUpInside)
        return v
    }()
    
    lazy var playButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "play.png"), for: .normal)
        v.tintColor = .black
        v.addTarget(self, action: #selector(didTappedPlayButton), for: .touchUpInside)
        return v
    }()
    
}

extension ViewController: SKStoreProductViewControllerDelegate {
    private func showAppStroreInstall() {
        let loadingView = UIActivityIndicatorView(frame: view.bounds)
        view.addSubview(loadingView)
        loadingView.startAnimating()
        loadingView.backgroundColor = UIColor.white
        let storeProductViewController = SKStoreProductViewController()
        storeProductViewController.delegate = self
        storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()]) { (success, error) in
            loadingView.removeFromSuperview()
            if let error = error {
                print("ViewController: extension: showAppStroreInstall loadProduct is error: \(error)")
            }
            else {
                print("ViewController: extension: showAppStroreInstall success")
                self.present(storeProductViewController, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        updateUserInfo(with: playerState)
    }
}
