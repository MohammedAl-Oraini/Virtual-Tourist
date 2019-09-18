//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 15/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var highlightView: UIView!
    
    override var isHighlighted: Bool {
        didSet{
            highlightView.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet{
            highlightView.isHidden = !isSelected
        }
    }
    
}
