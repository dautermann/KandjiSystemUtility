//
//  ConnectedVolumesUsageView.swift
//  KandjiSystemUtility
//
//  Created by Michael Dautermann on 2/23/24.
//

import Cocoa

class ConnectedVolumesUsageView: NSView {
    /// Setup!
    let dataSource: ConnectedVolumesUsageDataSource = ConnectedVolumesUsageDataSource()
    var updateTimer: Timer!
    @IBOutlet var tableView: NSTableView?

    func configure() {
        tableView?.dataSource = dataSource
        tableView?.delegate = dataSource
        updateTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
    }

    @objc func updateInfo(_ timer: Timer) {
        dataSource.updateInfo()
        tableView?.reloadData()
    }
}
