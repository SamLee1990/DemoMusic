//
//  Song.swift
//  DemoMusic
//
//  Created by 李世文 on 2021/9/23.
//

import Foundation

struct Song {
    var originIndex: Int?
    var songName: String
    var singerName: String
    var albumName: String
    var fileName: String
    var totalTimesWithSecond: Int
    var albumImageName: String {
        "\(albumName)-\(singerName)"
    }
    
    static func songTimesFormat(timesWithSecond: Int) -> String {
        var timeStr: String
        let minutes = timesWithSecond / 60
        let seconds = timesWithSecond % 60
        if minutes < 10{
            timeStr = "0\(minutes):"
        }else{
            timeStr = "\(minutes):"
        }
        if seconds < 10{
            timeStr += "0\(seconds)"
        }else{
            timeStr += "\(seconds)"
        }
        return timeStr
    }
}
