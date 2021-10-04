//
//  MyMusicTableViewController.swift
//  DemoMusic
//
//  Created by 李世文 on 2021/9/23.
//

import UIKit
import AVFoundation
import MediaPlayer

class MyMusicTableViewController: UITableViewController {
    
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var songsTotalTimes: UILabel!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    
    //topView 高度
    let topViewHeight: CGFloat = 220
    
    //元件
    var topPlayButtonView: UIView!
    let topPlayButtonViewHeight: CGFloat = 50
    var playBarView: UIView!
    
    //constraint for topPlayButtonView
    var leadingAnchorConstraint: NSLayoutConstraint!
    var trailingAnchorConstraint: NSLayoutConstraint!
    
    var songs = [Song]()
    let player = AVPlayer()
    var repeatStatus = Repeat.Repeat
    var shuffleStatus = Shuffle.UnShuffle
    
    lazy var playList = songs
    var playIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "\(SongsTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(SongsTableViewCell.self)")
        setupView()
        setupTopPlayButton()
        fetchSongs()
        registerForSetPlayBarViewNotification()
        registerForPlayToEndNotification()
        setupRemoteTransportControls()
        songsCountLabel.text = "\(songs.count) 首歌曲"
        songsTotalTimes.text = computeTotalTimes()
        
    }
    
    func setupView() {
        //topView 設定漸層
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = topView.bounds
        gradientLayer.colors = [
            UIColor(red: 112/255, green: 78/255, blue: 165/255, alpha: 1).cgColor,
            UIColor(red: 155/255, green: 190/255, blue: 87/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        topView.layer.insertSublayer(gradientLayer, at: 0)
        
        //topImageView 設定陰影
        topImageView.clipsToBounds = false
        topImageView.layer.shadowOpacity = 0.6
        topImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        topImageView.layer.shadowRadius = 10

    }
    
    func fetchSongs() {
        //設定歌單
        songs.append(Song(songName: "no song without you", singerName: "HONNE", albumName: "no song without you", fileName: "HONNE_no_song_without_you", totalTimesWithSecond: 179))
        songs.append(Song(songName: "la la la that’s how it goes", singerName: "HONNE", albumName: "no song without you", fileName: "HONNE_-_la_la_la_that's_how_it_goes", totalTimesWithSecond: 221))
        songs.append(Song(songName: "Warm on a Cold Night", singerName: "HONNE", albumName: "Warm on a Cold Night - Deluxe", fileName: "HONNE_-_Warm_On_A_Cold_Night", totalTimesWithSecond: 268))
        songs.append(Song(songName: "3am", singerName: "HONNE", albumName: "Warm on a Cold Night - Deluxe", fileName: "HONNE_-_3am", totalTimesWithSecond: 228))
        songs.append(Song(songName: "Me & You ◑", singerName: "HONNE", albumName: "Me & You ◑ | I Just Wanna Go Back ◐", fileName: "HONNE_-_Me_&_You_◑", totalTimesWithSecond: 244))
        songs.append(Song(songName: "Day 1 ◑", singerName: "HONNE", albumName: "Love Me | Love Me Not", fileName: "HONNE_-_Day_1_◑", totalTimesWithSecond: 234))
        songs.append(Song(songName: "NOW I'M ALONE (feat. Sofía Valdés)", singerName: "HONNE", albumName: "PART 1: WWYD?", fileName: "HONNE_-_NOW_I'M_ALONE_(Official_Lyric_Video)", totalTimesWithSecond: 225))
        songs.append(Song(songName: "Just Dance", singerName: "HONNE", albumName: "Just Dance", fileName: "HONNE_-_Just_Dance", totalTimesWithSecond: 213))
        songs.append(Song(songName: "I Can Give You Heaven", singerName: "HONNE", albumName: "Over Lover EP", fileName: "HONNE_-_I_Can_Give_You_Heaven", totalTimesWithSecond: 249))
        songs.append(Song(songName: "Loves the Jobs You Hate", singerName: "HONNE", albumName: "Over Lover EP", fileName: "HONNE_-_Loves_The_Jobs_You_Hate_(Official_Video)", totalTimesWithSecond: 225))
        
        //設定歌曲原始index
        for i in 0...songs.count - 1 {
            songs[i].originIndex = i
        }
    }
    
    //計算所有歌曲總時長
    func computeTotalTimes() -> String {
        var totalTimesStr = ""
        var totalTimesWithSeconds = 0
        for song in songs {
            totalTimesWithSeconds += song.totalTimesWithSecond
        }
        let hour = totalTimesWithSeconds / 3600
        let minutes = totalTimesWithSeconds % 3600 / 60
        let seconds = totalTimesWithSeconds % 3600 % 60
        if hour != 0 {
            totalTimesStr = "\(hour) 小時"
            if minutes != 0 || seconds != 0 {
                totalTimesStr += " "
            }
        }
        if minutes != 0 {
            totalTimesStr += "\(minutes) 分"
            if hour == 0 && seconds != 0 {
                totalTimesStr += " "
            }
        }
        if (seconds != 0 && hour == 0) || (seconds != 0 && minutes == 0) {
            totalTimesStr += "\(seconds) 秒"
        }
        return totalTimesStr
    }
    
    //播放歌曲
    func doPlaySong() {
        let fileUrl = Bundle.main.url(forResource: playList[playIndex].fileName, withExtension: "mp4")!
        let playerItem = AVPlayerItem(url: fileUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        setupNowPlaying()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SongsTableViewCell.self)", for: indexPath) as! SongsTableViewCell

        // Configure the cell...
        cell.setInfo(song: songs[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playIndex = indexPath.row
        if shuffleStatus == .Shuffle {
            playList = songs//重置 playList
            let song = playList[playIndex]//取得播放歌曲
            playList.remove(at: playIndex)//移除 list 裡頭的播放歌曲
            playList.shuffle()// list 洗牌
            playList.insert(song, at: 0)//播放歌曲放回 list
            playIndex = 0
        }
        //設定播放歌曲
        //播放
        doPlaySong()
        //添加 play bar 或更新 play bar
        setPlayBarView(playList[playIndex])
        //設定 play pause button image
        let playAndPauseButton = playBarView.subviews[4] as! UIButton
        playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        //取消選取狀態
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let navigationBarHeight = navigationController?.navigationBar.bounds.height ?? 0
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        if scrollView.contentOffset.y <= topViewHeight - (navigationBarHeight + statusBarHeight) {
            leadingAnchorConstraint.constant = 20
            trailingAnchorConstraint.constant = -20
            topPlayButtonView.layer.cornerRadius = topPlayButtonViewHeight / 2
        } else {
            leadingAnchorConstraint.constant = 0
            trailingAnchorConstraint.constant = 0
            topPlayButtonView.layer.cornerRadius = 0
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let controller = segue.destination as? PlayerViewController else { return }
        controller.songs = songs
        controller.repeatStatus = repeatStatus
        controller.shuffleStatus = shuffleStatus
        controller.playList = playList
        controller.playIndex = playIndex
        controller.player = player
    }
    

}

//畫面元件相關
extension MyMusicTableViewController {
    
    func setupTopPlayButton() {
        if let array = Bundle.main.loadNibNamed("PlayBarView", owner: nil, options: nil),
           let buttonView = array.last as? UIView {
            topPlayButtonView = buttonView
            //取消 autoresizeing
            topPlayButtonView.translatesAutoresizingMaskIntoConstraints = false
            //加入元件
            tableView.addSubview(topPlayButtonView)
            //設定圓角
            topPlayButtonView.clipsToBounds = true
            topPlayButtonView.layer.cornerRadius = topPlayButtonViewHeight / 2
            //constraints
            topPlayButtonView.heightAnchor.constraint(equalToConstant: topPlayButtonViewHeight).isActive = true
            leadingAnchorConstraint = topPlayButtonView.leadingAnchor.constraint(equalTo: tableView.frameLayoutGuide.leadingAnchor, constant: 20)
            leadingAnchorConstraint.isActive = true
            trailingAnchorConstraint = topPlayButtonView.trailingAnchor.constraint(equalTo: tableView.frameLayoutGuide.trailingAnchor, constant: -20)
            trailingAnchorConstraint.isActive = true
            topPlayButtonView.topAnchor.constraint(greaterThanOrEqualTo: tableView.frameLayoutGuide.owningView!.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            let topToAnchorContraint = topPlayButtonView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: topViewHeight - topPlayButtonViewHeight / 2)
            topToAnchorContraint.priority = UILayoutPriority(999)
            topToAnchorContraint.isActive = true
            //設定 event
            let topButton = topPlayButtonView.subviews.first as! UIButton
            topButton.addTarget(self, action: #selector(play(sender:)), for: .touchUpInside)
        }
    }
    
    func setPlayBarView(_ song: Song) {
        if playBarView == nil {
            //添加 play bar
            if let array = Bundle.main.loadNibNamed("PlayBarView", owner: nil, options: nil),
               let playBarViewFromXib = array.first as? UIView {
                playBarView = playBarViewFromXib
                //取消 Autoresizing
                playBarView.translatesAutoresizingMaskIntoConstraints = false
                tableView.addSubview(playBarView)
                //constraint
                var playButtonHeight:CGFloat = 56
                if let bottomPadding = view.window?.safeAreaInsets.bottom {
                    playButtonHeight += bottomPadding
                }
                playBarView.heightAnchor.constraint(equalToConstant: playButtonHeight).isActive = true
                playBarView.leadingAnchor.constraint(equalTo: tableView.frameLayoutGuide.leadingAnchor, constant: 0).isActive = true
                playBarView.trailingAnchor.constraint(equalTo: tableView.frameLayoutGuide.trailingAnchor, constant: 0).isActive = true
//                playBarView.bottomAnchor.constraint(equalTo: tableView.frameLayoutGuide.owningView!.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
                playBarView.bottomAnchor.constraint(equalTo: tableView.frameLayoutGuide.bottomAnchor, constant: 0).isActive = true
                //漸層
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = CGRect(x: 0, y: 0, width: playBarView.bounds.width, height: playButtonHeight)
                gradientLayer.colors = [
                    UIColor(red: 162/255, green: 128/255, blue: 215/255, alpha: 0.6).cgColor,
                    UIColor(red: 205/255, green: 240/255, blue: 137/255, alpha: 0.6).cgColor
                ]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
                playBarView.layer.insertSublayer(gradientLayer, at: 0)
                //畫面往上移
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0)
                //設定play bar資訊
                if let imageView = playBarView.subviews[0] as? UIImageView,
                   let songNameLabel = playBarView.subviews[1] as? UILabel,
                   let singerNameAndAlbumNameLabel = playBarView.subviews[2] as? UILabel,
                   let presentButton = playBarView.subviews[3] as? UIButton,
                   let playAndPauseButton = playBarView.subviews[4] as? UIButton {
                    imageView.image = UIImage(named: song.albumImageName)
                    songNameLabel.text = song.songName
                    let singerNameAndAlbumName = "\(song.singerName)-\(song.albumName)"
                    singerNameAndAlbumNameLabel.text = singerNameAndAlbumName
                    //設定button event
                    presentButton.addTarget(self, action: #selector(presentPlayerView(sender:)), for: .touchUpInside)
                    playAndPauseButton.addTarget(self, action: #selector(playAndPause(sender:)), for: .touchUpInside)
                }
            }
        } else {
            //更新play bar資訊
            if let imageView = playBarView.subviews[0] as? UIImageView,
               let songNameLabel = playBarView.subviews[1] as? UILabel,
               let singerNameAndAlbumNameLabel = playBarView.subviews[2] as? UILabel {
                imageView.image = UIImage(named: song.albumImageName)
                songNameLabel.text = song.songName
                let singerNameAndAlbumName = "\(song.singerName)-\(song.albumName)"
                singerNameAndAlbumNameLabel.text = singerNameAndAlbumName
            }
        }
    }
    
    @objc func presentPlayerView(sender: Any) {
        performSegue(withIdentifier: "PresentPlayerView", sender: nil)
    }
    
    @objc func playAndPause(sender: UIButton) {
        if player.timeControlStatus == .playing {
            sender.setImage(UIImage(systemName: "play.circle"), for: .normal)
            player.pause()
            setupNowPlaying()
        } else {
            sender.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            player.play()
            setupNowPlaying()
        }
    }
    
    @objc func play(sender: Any) {
        playIndex = 0
        if shuffleStatus == .Shuffle {
            playList.shuffle()
        } else {
            playList = songs
        }
//        doPlaySong()
        setPlayBarView(playList[0])
        let playAndPauseButton = playBarView.subviews[4] as! UIButton
        playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
    }
    
}

//Post Natification
extension MyMusicTableViewController {
    
    func postPlayAndPauseNotification(playing: Bool) {
        let name = Notification.Name("PlayAndPauseNotification")
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["playing" : playing])
    }
    
    func postChangeSongNotification(playIndex: Int) {
        let name = Notification.Name("ChangeSongNatification")
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["playIndex" : playIndex])
    }
    
    func postPreNextSongNotification() {
        let name = Notification.Name("PreNextSongNotification")
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["playIndex" : playIndex!])
    }
    
}

//Register Notification
extension MyMusicTableViewController {
    
    func registerForSetPlayBarViewNotification() {
        var name = NSNotification.Name("PreNextSongNotification")//更換歌曲
        NotificationCenter.default.addObserver(self, selector: #selector(preNextSong(_:)), name: name, object: nil)
        name = NSNotification.Name("PlayAndPauseNotification")//播放與暫停
        NotificationCenter.default.addObserver(self, selector: #selector(setPlayAndPause(_:)), name: name, object: nil)
        name = NSNotification.Name("ChangePlayingStatusNotification")//設定播放狀態（隨機、循環等）
        NotificationCenter.default.addObserver(self, selector: #selector(setPlayingStatus(_:)), name: name, object: nil)
    }
    
    //上一首、下一首
    @objc func preNextSong(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let playIndex = info["playIndex"] as? Int else { return }
        
        self.playIndex = playIndex
        setPlayBarView(playList[self.playIndex])
        let playAndPauseButton = playBarView.subviews[4] as! UIButton
        playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)

        doPlaySong()
    }
    
    //播放、暫停
    @objc func setPlayAndPause(_ notification: Notification) {
        guard let info = notification.userInfo,
              let playing = info["playing"] as? Bool,
              let playAndPauseButton = playBarView.subviews[4] as? UIButton else { return }
        
        if playing == true {
            playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            player.play()
        } else {
            playAndPauseButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            player.pause()
        }
        
        setupNowPlaying()
    }
    
    //設定播放狀態資訊
    @objc func setPlayingStatus(_ notification: Notification) {
        guard let info = notification.userInfo,
              let playList = info["playList"] as? Array<Song>,
              let playIndex = info["playIndex"] as? Int,
              let repeatStatus = info["repeatStatus"] as? Repeat,
              let shuffleStatus = info["shuffleStatus"] as? Shuffle else { return }
        
        self.playList = playList
        self.playIndex = playIndex
        self.repeatStatus = repeatStatus
        self.shuffleStatus = shuffleStatus
    }
    
    //歌曲播放完畢
    func registerForPlayToEndNotification() {
        NotificationCenter.default.addObserver(forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { notification in
            self.setPlayFinish()
        }
    }
    
    func setPlayFinish() {
        switch repeatStatus {
        case .Repeat:
            if playIndex == playList.count - 1 {
                playIndex = 0
            } else {
                playIndex += 1
            }
            //更新 play bar
            setPlayBarView(playList[playIndex])
            doPlaySong()
        case .UnRepeat:
            if playIndex == playList.count - 1 {
                playIndex = nil
                player.replaceCurrentItem(with: nil)
                playBarView.removeFromSuperview()
                playBarView = nil
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                if presentedViewController != nil {
                    dismiss(animated: true, completion: nil)
                }
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            } else {
                playIndex += 1
                //更新 play bar
                setPlayBarView(playList[playIndex])
                //設定播放歌曲
                //播放
                doPlaySong()
            }
        case .RepeatOneSong:
            player.seek(to: .zero)
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
            player.play()
        }
    }
    
}

//控制中心相關
extension MyMusicTableViewController {
    
    func setupRemoteTransportControls() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            if player.rate == 0.0 && playIndex != nil {
                postPlayAndPauseNotification(playing: true)
                setupNowPlaying()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if player.rate == 1.0 {
                postPlayAndPauseNotification(playing: false)
                setupNowPlaying()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            if playIndex != nil {
                if playIndex == playList.count - 1 {
                    playIndex = 0
                } else {
                    playIndex += 1
                }
                
                if presentedViewController != nil {
                    postChangeSongNotification(playIndex: playIndex)
                } else {
                    postPreNextSongNotification()
                }
                
                setupNowPlaying()
                return .success
            }
            
            return .commandFailed
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            if playIndex != nil {
                if playIndex != 0 {
                    playIndex -= 1
                } else {
                    playIndex = playList.count - 1
                }
                
                if presentedViewController != nil {
                    postChangeSongNotification(playIndex: playIndex)
                } else {
                    postPreNextSongNotification()
                }
                
                setupNowPlaying()
                return .success
            }
            
            return .commandFailed
        }
        
    }
    
    func setupNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = playList[playIndex].songName
        nowPlayingInfo[MPMediaItemPropertyArtist] = playList[playIndex].singerName
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = playList[playIndex].albumName
        
        if let image = UIImage(named: playList[playIndex].albumImageName) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size in
                return image
            })
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}

