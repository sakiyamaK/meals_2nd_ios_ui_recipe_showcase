//
//  CurriculumViewController.swift
//  PasscodeLockLayout
//
//  Created by 酒井文也 on 2020/08/15.
//  Copyright © 2020 酒井文也. All rights reserved.
//

import UIKit
import PanModal

final class CurriculumViewController: UIViewController {

    // MARK: - Property

    private var curriculums: [CurriculumModel] = []

    // CurriculumPresenterProtocolに設定したプロトコルを適用するための変数
    private var presenter: CurriculumPresenter!

    // MARK: - @IBOutlet

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarTitle("カリキュラム一覧")
        removeBackButtonText()
        setupCurriculumTableView()
        setupCurriculumPresenter()
    }

    // MARK: - Private Function

    // 表示するUITableViewに関する設定を行う
    private func setupCurriculumTableView() {
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerCustomCell(CurriculumTableViewCell.self)
    }

    // Presenterとの接続に関する設定を行う
    private func setupCurriculumPresenter() {
        presenter = CurriculumPresenter(presenter: self)
        presenter.getCurriculumModels()
    }
}

// MARK: - UITableViewDataSource

extension CurriculumViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curriculums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCustomCell(with: CurriculumTableViewCell.self)
        cell.delegate = self
        cell.setCell(curriculums[indexPath.row])
        return cell
    }
}

// MARK: - CurriculumTableViewCellToggleDelegate

extension CurriculumViewController: CurriculumTableViewCellToggleDelegate {

    func showCourseButtonTappedHandler(curriculum: CurriculumModel?) {
        if let curriculum = curriculum {
            let courseViewController = UIStoryboard(name: "Course", bundle: nil).instantiateInitialViewController() as! CourseViewController
            courseViewController.setCurriculum(curriculum)

            // MEMO: ライブラリ「PanModal」を利用したセミモーダルを表示する
            presentPanModal(courseViewController)
        }
    }
}

// MARK: - CurriculumPresenterProtocol

extension CurriculumViewController: CurriculumPresenterProtocol {

    func bindCurriculumModels(_ curriculumModels: [CurriculumModel]) {
        curriculums = curriculumModels
        tableView.reloadData()
    }
}
