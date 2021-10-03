//
//  PlayListViewController.swift
//  DemoMusic
//
//  Created by 李世文 on 2021/9/29.
//

import UIKit

class PlayListViewController: UIViewController {

    @IBOutlet weak var playListTableView: UITableView!
    
    var playList = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playListTableView.register(UINib(nibName: "\(SongsTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(SongsTableViewCell.self)")
        playListTableView.delegate = self
        playListTableView.dataSource = self
        
    }
    
    @IBAction func doDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlayListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(SongsTableViewCell.self)", for: indexPath) as? SongsTableViewCell else { return UITableViewCell() }
        
        cell.setInfo(song: playList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playIndex = indexPath.row
        postChangeSongNotification(playIndex: playIndex)
        dismiss(animated: true, completion: nil)
    }
    
    
}

//Post Notification
extension PlayListViewController {
    
    func postChangeSongNotification(playIndex: Int) {
        let name = Notification.Name("ChangeSongNatification")
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["playIndex" : playIndex])
    }
    
}
