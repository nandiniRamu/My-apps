//
//  videoCollectionViewCell.swift
//  demoApp
//
//  Created by avinash on 10/10/17.
//  Copyright © 2017 abc. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class videoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var videoPlayer: YTPlayerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
