//
//  SongsTableViewCell.swift
//  DemoMusic
//
//  Created by 李世文 on 2021/9/30.
//

import UIKit

class SongsTableViewCell: UITableViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInfo(song: Song) {
        albumImageView.image = UIImage(named: song.albumImageName)
        songNameLabel.text = song.songName
        songInfoLabel.text = "\(song.singerName)-\(song.albumName)"
    }
    
}
