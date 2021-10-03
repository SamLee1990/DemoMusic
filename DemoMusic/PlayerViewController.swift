//
//  PlayerViewController.swift
//  DemoMusic
//
//  Created by 李世文 on 2021/9/23.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayerViewController: UIViewController {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var singerNameLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totleTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var songs: Array<Song>!
    var player: AVPlayer!
    var repeatStatus: Repeat!
    var shuffleStatus: Shuffle!
    
    var playList: Array<Song>!
    var playIndex: Int!
    
    var timeObserverToken: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        setProgressSliderEvent()
        setPlayEndNotification()
        registerChangeSongOrInfoNotification()
        addPeriodicTimeObserver()
        setViewWithSongInfo()
        setViewWithPlayStatus()
    }
    
    func setupView() {
        //設定漸層
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 112/255, green: 78/255, blue: 165/255, alpha: 0.8).cgColor,
            UIColor(red: 155/255, green: 190/255, blue: 87/255, alpha: 0.8).cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
        //設定陰影
        albumImageView.clipsToBounds = false
        albumImageView.layer.shadowOpacity = 0.6//深淺
        albumImageView.layer.shadowOffset = CGSize(width: 0, height: 0)//方向
        albumImageView.layer.shadowRadius = 10//範圍
    }
    
    func setViewWithSongInfo() {
        albumImageView.image = UIImage(named: playList[playIndex].albumImageName)
        songNameLabel.text = playList[playIndex].songName
        singerNameLabel.text = playList[playIndex].singerName
        currentTimeLabel.text = Song.songTimesFormat(timesWithSecond: Int(player.currentTime().seconds))
        totleTimeLabel.text = Song.songTimesFormat(timesWithSecond: playList[playIndex].totalTimesWithSecond)
        timeSlider.maximumValue = Float(playList[playIndex].totalTimesWithSecond)
        timeSlider.value = Float(player.currentTime().seconds)
    }
    
    func setViewWithPlayStatus() {
        if player.timeControlStatus == .playing {
            playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        } else {
            playAndPauseButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
        
        switch repeatStatus {
        case .Repeat:
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
            repeatButton.tintColor = UIColor.label
        case .UnRepeat:
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
            repeatButton.tintColor = UIColor.secondaryLabel
        case .RepeatOneSong:
            repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
            repeatButton.tintColor = UIColor.label
        default:
            break
        }
        
        if shuffleStatus == .Shuffle {
            shuffleButton.tintColor = UIColor.label
        } else {
            shuffleButton.tintColor = UIColor.secondaryLabel
        }
    }
    
    func changeSongAndPlay() {
        albumImageView.image = UIImage(named: playList[playIndex].albumImageName)
        songNameLabel.text = playList[playIndex].songName
        singerNameLabel.text = playList[playIndex].singerName
        totleTimeLabel.text = Song.songTimesFormat(timesWithSecond: playList[playIndex].totalTimesWithSecond)
        timeSlider.maximumValue = Float(playList[playIndex].totalTimesWithSecond)
        if player.timeControlStatus == .paused {
            playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            player.play()
        }
        
        postPreNextSongNotification()
    }
    
    @IBAction func doDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playAndPause(_ sender: UIButton) {
        var playing: Bool
        if player.timeControlStatus == .playing {
            playAndPauseButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            playing = false
        } else {
            playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            playing = true
        }
        
        postPlayAndPauseNotification(playing: playing)
    }
    
    @IBAction func preSong(_ sender: Any) {
        if playIndex != 0 {
            playIndex -= 1
        } else {
            playIndex = playList.count - 1
        }

        changeSongAndPlay()
    }
    
    @IBAction func nextSong(_ sender: Any) {
        if playIndex == playList.count - 1 {
            playIndex = 0
        } else {
            playIndex += 1
        }

        changeSongAndPlay()
    }
    
    @IBAction func setRepeatStatus(_ sender: UIButton) {
        switch repeatStatus {
        case .Repeat:
            repeatStatus = .RepeatOneSong
            sender.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        case .UnRepeat:
            repeatStatus = .Repeat
            sender.tintColor = UIColor.label
        case .RepeatOneSong:
            repeatStatus = .UnRepeat
            sender.setImage(UIImage(systemName: "repeat"), for: .normal)
            sender.tintColor = UIColor.secondaryLabel
        default:
            break
        }
        
        postChangePlayingStatusNotification()
    }
    
    @IBAction func setShuffleStatus(_ sender: UIButton) {
        if shuffleStatus == .Shuffle {
            playIndex = playList[playIndex].originIndex
            playList = songs
            sender.tintColor = UIColor.secondaryLabel
            shuffleStatus = .UnShuffle
        } else {
            let song = playList[playIndex]//取得播放歌曲
            playList.remove(at: playIndex)//移除 list 裡頭的播放歌曲
            playList.shuffle()// list 洗牌
            playList.insert(song, at: 0)//播放歌曲放回 list
            playIndex = 0
            sender.tintColor = UIColor.label
            shuffleStatus = .Shuffle
        }
        
        postChangePlayingStatusNotification()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let controller = segue.destination as? PlayListViewController else { return }
        
        controller.playList = playList
    }
    

}

//progress silder event
extension PlayerViewController {
    
    func setProgressSliderEvent() {
        timeSlider.addTarget(self, action: #selector(progressSliderTouchDown(sender:)), for: .touchDown)
        timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(sender:)), for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(progressSliderTouchUpInside(sender:)), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(progressSliderTouchUpOutside(sender:)), for: .touchUpOutside)
    }
    
    @objc func progressSliderTouchDown(sender: UISlider) {
        removePeriodicTimeObserver()
    }
    
    @objc func progressSliderValueChanged(sender: UISlider) {
        currentTimeLabel.text = Song.songTimesFormat(timesWithSecond: Int(sender.value))
    }
    
    @objc func progressSliderTouchUpInside(sender: UISlider) {
        sliderTouchUp(sender: sender)
    }
    
    @objc func progressSliderTouchUpOutside(sender: UISlider) {
        sliderTouchUp(sender: sender)
    }
    
    func sliderTouchUp(sender: UISlider) {
        let playTime = CMTime(value: CMTimeValue(sender.value), timescale: 1)
        player.seek(to: playTime)
        //延遲0.5秒加TimeObserver，讓秒數顯示正確
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.addPeriodicTimeObserver()
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = sender.value
    }
    
}

//Post Notification
extension PlayerViewController {
    
    func postPlayAndPauseNotification(playing: Bool) {
        let name = Notification.Name("PlayAndPauseNotification")
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["playing" : playing])
    }
    
    func postPreNextSongNotification() {
        let name = Notification.Name("PreNextSongNotification")
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["playIndex" : playIndex!])
    }
    
    func postChangePlayingStatusNotification() {
        let name = Notification.Name("ChangePlayingStatusNotification")
        let userInfo = [
            "playList" : playList!,
            "playIndex" : playIndex!,
            "repeatStatus" : repeatStatus!,
            "shuffleStatus" : shuffleStatus!
        ] as [String : Any]
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
}

//Register Notification
extension PlayerViewController {
    
    func registerChangeSongOrInfoNotification() {
        var name = Notification.Name("ChangeSongNatification")//更換歌曲
        NotificationCenter.default.addObserver(self, selector: #selector(changeSong(notification:)), name: name, object: nil)
        name = Notification.Name("PlayAndPauseNotification")//播放或暫停
        NotificationCenter.default.addObserver(self, selector: #selector(setPlayAndPause(notification:)), name: name, object: nil)
    }
    
    @objc func changeSong(notification: Notification) {
        guard let info = notification.userInfo,
              let playIndex = info["playIndex"] as? Int else { return }
        
        self.playIndex = playIndex
        changeSongAndPlay()
    }
    
    @objc func setPlayAndPause(notification: Notification) {
        guard let info = notification.userInfo,
              let playing = info["playing"] as? Bool else { return }
        
        if playing == true {
            playAndPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        } else {
            playAndPauseButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
    }
    
    func setPlayEndNotification() {
        NotificationCenter.default.addObserver(forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            print("歌曲播完")
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
            //更新 view
            setViewWithSongInfo()
        case .UnRepeat:
            if playIndex == playList.count - 1 {
                removePeriodicTimeObserver()
            } else {
                playIndex += 1
                //更新 view
                setViewWithSongInfo()
            }
        case .RepeatOneSong:
            break
        default:
            break
        }
    }
    
}

//timeObserverToken
extension PlayerViewController {
    
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.currentTimeLabel.text = Song.songTimesFormat(timesWithSecond: Int(time.seconds))
            self?.timeSlider.setValue(Float(time.seconds), animated: true)
        }
    }
    
    func removePeriodicTimeObserver() {
        if timeObserverToken != nil {
            player.removeTimeObserver(timeObserverToken!)
            timeObserverToken = nil
        }
    }
    
}
