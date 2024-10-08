//
//  UICollectionView+Hi.swift
//  HiUIKit
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public extension UICollectionView {

    func sectionWidth(at section: Int) -> CGFloat {
        var width = self.width
        width -= self.contentInset.left
        width -= self.contentInset.right

        if let delegate = self.delegate as? UICollectionViewDelegateFlowLayout,
            let inset = delegate.collectionView?(self, layout: self.collectionViewLayout, insetForSectionAt: section) {
            width -= inset.left
            width -= inset.right
        } else if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            width -= layout.sectionInset.left
            width -= layout.sectionInset.right
        }

        return width
    }
    
    func sectionHeight(at section: Int) -> CGFloat {
        var height = self.height
        height -= self.contentInset.top
        height -= self.contentInset.bottom
        
        if let delegate = self.delegate as? UICollectionViewDelegateFlowLayout,
            let inset = delegate.collectionView?(self, layout: self.collectionViewLayout, insetForSectionAt: section) {
            height -= inset.top
            height -= inset.bottom
        } else if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            height -= layout.sectionInset.top
            height -= layout.sectionInset.bottom
        }
        
        return height
    }
    
    func emptyCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionView.emptyCell"
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        cell.isHidden = true
        return cell
    }

    func emptyView(for indexPath: IndexPath, kind: String) -> UICollectionReusableView {
        let identifier = "UICollectionView.emptyView"
        self.register(UICollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        view.isHidden = true
        return view
    }

}

