//
//  ExpandedFileBinderCollectionViewLayout.swift
//  FluidPhotoGalleyLayout
//
//  Created by 酒井文也 on 2020/08/10.
//  Copyright © 2020 酒井文也. All rights reserved.
//

import Foundation
import UIKit

// Safari風な表示において展開状態時におけるUICollectionViewLayoutを継承したクラス
// MEMO: 下記リポジトリで紹介されているコードを参考に再実装をしてみました。
// https://github.com/AfrozZaheer/AZSafariCollectionViewLayout

final class ExpandedFileBinderCollectionViewLayout: UICollectionViewLayout {

    // MARK: - Properties

    private let initialAngleOfLotationLimit: Float = 0.0

    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var contentSize: CGSize = CGSize.zero

    // MARK: - Override (Computed Property)

    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }

    // MARK: - Override (Function)

    // セルのレイアウト属性の計算処理を実行する前に実行する
    override func prepare() {
        super.prepare()

        guard let targetCollectionView = self.collectionView else {
            fatalError("対象のUICollectionViewが配置されていません。")
        }

        guard targetCollectionView.numberOfSections == 1 else {
            fatalError("対象のUICollectionViewでのセクションは1つだけです。")
        }

        // セルを配置するY軸方向の位置
        var yOffset: CGFloat = 0.0

        // 該当するUICollectionViewの内部サイズを設定する
        let width = targetCollectionView.frame.size.width
        let height = targetCollectionView.frame.size.height
        contentSize = CGSize(width: width, height: height)

        let limit = targetCollectionView.numberOfItems(inSection: 0)
        for item in 0..<limit {

            // セル要素から必要な値を算出する
            let indexPath = IndexPath(item: item, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(x: 0, y: yOffset, width: width, height: height)

            // MEMO: Frame値とZ軸方向インデックス値を設定する
            attribute.frame = frame
            attribute.zIndex = item

            // MEMO: 一度変数の値を初期値にリセットする
            let angleOfRotation = CGFloat(initialAngleOfLotationLimit)

            // MEMO: 3DカメラのX軸方向回転を実現する
            let rotation = CATransform3DMakeRotation((CGFloat.pi * angleOfRotation / 180.0), 1.0, 0.0, 0.0)

            // MEMO: 3DカメラのY軸方向回転を実現する
            let depth: CGFloat = 0.0
            let translateDown = CATransform3DMakeTranslation(0.0, 0.0, -depth)
            let translateUp = CATransform3DMakeTranslation(0.0, 0.0, depth)
            var scale = CATransform3DIdentity
            scale.m34 = -1.0/1000.0
            let perspective =  CATransform3DConcat(CATransform3DConcat(translateDown, scale), translateUp)
            let transform = CATransform3DConcat(rotation, perspective)

            // MEMO: 3D回転を利用した変形を適用したUICollectionViewLayoutAttributesを変数に格納する
            attribute.transform3D = transform
            attributes.append(attribute)

            // MEMO: セルを重ねて表示するように見せるためにY軸方向の位置の間隔値を加算する（ただしスクロールを無効にすればこの処理はあまり意味がない）
            yOffset += height
        }

        // MEMO: UICollectionViewLayoutAttributesを加味したUICollectionViewの内部サイズを設定する
        if attributes.count > 0 {
            if let lastItemAttributes = attributes.last {
                let newHeight = lastItemAttributes.frame.origin.y + lastItemAttributes.frame.size.height
                let newWidth = width
                contentSize = CGSize(width: newWidth, height: newHeight)
            }
        }
    }

    // 表示領域が変わる場合に実行され、現在表示されている範囲内のセルにおけるUICollectionViewLayoutAttributesを配列で返す
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)

        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        for targetAttributes in attributes {
            // 現在計算されているUICollectionViewLayoutAttributesと表示されているUICollectionViewLayoutAttributesの重なりを判定する
            // → 重なっている部分を適用する
            if targetAttributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(targetAttributes)
            }
        }
        return visibleLayoutAttributes
    }

    // IndexPathに該当するセルのUICollectionViewLayoutAttributesを再度計算して返す
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }

    // セルの要素の追加や削除がされた場合に実行され、影響を受けるセルのvを再度計算して返す
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[itemIndexPath.item]
    }

    // 常にレイアウトの再計算を実行するか(※常に再計算を実行する場合はtrueを返す)
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
