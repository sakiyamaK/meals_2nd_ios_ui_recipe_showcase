//
//  ProfileViewController.swift
//  PasscodeLockLayout
//
//  Created by 酒井文也 on 2020/08/15.
//  Copyright © 2020 酒井文也. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarTitle("Profile")
        removeBackButtonText()
    }
}
