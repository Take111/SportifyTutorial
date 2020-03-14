//
//  ViewController.swift
//  SpotifyTurtorial
//
//  Created by 竹ノ内愛斗 on 2020/03/11.
//  Copyright © 2020 竹ノ内愛斗. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let buttonSize = CGSize(width: 100, height: 20)
    
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    // MARK: - ViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        view.addSubview(authButton)
    }

    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        
        let w = view.bounds.width
        
        authButton.layout { f in
            f.size = buttonSize
            f.origin.x = (w - f.width) / 2
            f.origin.y = CGFloat(100)
        }
    }

    // MARK: - Action
    
    @objc func auth() {
        
    }
    
    
    // MARK: - Subviews
    
    lazy var authButton: UIButton = {
        let v = UIButton()
        v.setTitle("Auth", for: .normal)
        v.addTarget(self, action: #selector(auth), for: .touchUpInside)
        v.backgroundColor = .black
        return v
    }()
}

