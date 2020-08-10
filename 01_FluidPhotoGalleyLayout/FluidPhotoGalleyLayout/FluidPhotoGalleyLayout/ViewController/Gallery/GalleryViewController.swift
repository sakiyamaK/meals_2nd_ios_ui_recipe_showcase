//
//  GalleryViewController.swift
//  FluidPhotoGalleyLayout
//
//  Created by 酒井文也 on 2020/08/10.
//  Copyright © 2020 酒井文也. All rights reserved.
//

import UIKit

final class GalleryViewController: UIViewController {

    // MARK: - Properties

    private var rectanglePhotos: [RectanglePhoto] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private var lastSelectedIndexPath: IndexPath? = nil
    
    // MARK: - @IBOutlet
    
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarTitle("フォトギャラリー")
        removeBackButtonText()
        setupCollectionView()
    }

    // MARK: - Private Function

    private func setupCollectionView() {

        // UICollectionViewに関する設定
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.bounces = false
        collectionView.registerCustomCell(GalleryCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self

        // UICollectionViewに付与するアニメーションに関する設定
        // MEMO: あらかじめMultipleScrollDirectionLayoutクラスをStoryboardで適用する
        if let multipleScrollDirectionLayout = collectionView.collectionViewLayout as? MultipleScrollDirectionLayout {
            multipleScrollDirectionLayout.delegate = self
        }

        // UICollectionViewに表示するデータを取得してUICollectionViewに反映する
        rectanglePhotos = getRectanglePhotos()
    }

    private func getRectanglePhotos() -> [RectanglePhoto] {

        // JSONファイルから表示用のデータを取得する
        guard let path = Bundle.main.path(forResource: "gallery", ofType: "json") else {
            fatalError()
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError()
        }
        guard let rectanglePhotos = try? JSONDecoder().decode([RectanglePhoto].self, from: data) else {
            fatalError()
        }
        return rectanglePhotos
    }
}

// MARK: - UICollectionViewDataSource

// MEMO: iOS13~利用可能なDiffableDataSourceを利用しても実装可能
// → このレイアウトに関しては、「横方向のセル数はnumberOfItemsInSectionで定義する ＆ 縦方向のセル数はnumberOfSectionsで定義する」という形をとっている点に注意すれば可能
// ※ この場合については特にセクション毎の表示データの更新を考える必要のない画面だから従来通りの方法で支障はない。

extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rectanglePhotos.isEmpty ? 0 : 4
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return rectanglePhotos.isEmpty ? 0 : 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: GalleryCollectionViewCell.self, indexPath: indexPath)
        let fixedIndex = indexPath.section * 4 + indexPath.row
        cell.setCell(rectanglePhotos[fixedIndex])
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fixedIndex = indexPath.section * 4 + indexPath.row
        let rectanglePhoto = rectanglePhotos[fixedIndex]
        self.lastSelectedIndexPath = indexPath

        if let photoDetailVC = UIStoryboard(name: "PhotoDetail", bundle: nil).instantiateInitialViewController() as? PhotoDetailViewController {
            photoDetailVC.setRectanglePhoto(rectanglePhoto: rectanglePhoto)
            self.navigationController?.pushViewController(photoDetailVC, animated: true)
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {

    // 配置するセルのサイズを決定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return GalleryCollectionViewCell.cellSize
    }

    // セルの垂直方向の余白(margin)を設定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    // セルの水平方向の余白(margin)を設定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    // セル内のアイテム間の余白(margin)調整を行う
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

extension GalleryViewController: PhotoDetailTransitionAnimatorDelegate {
    func transitionWillStart() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        collectionView.cellForItem(at: lastSelected)?.isHidden = true
    }

    func transitionDidEnd() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        collectionView.cellForItem(at: lastSelected)?.isHidden = false
    }

    func referenceImage() -> UIImage? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.collectionView.cellForItem(at: lastSelected) as? GalleryCollectionViewCell
        else {
            return nil
        }

        return cell.thumbnailImageView.image
    }

    func imageFrame() -> CGRect? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.collectionView.cellForItem(at: lastSelected)
        else {
            return nil
        }

        return self.collectionView.convert(cell.frame, to: self.view)
    }
}

