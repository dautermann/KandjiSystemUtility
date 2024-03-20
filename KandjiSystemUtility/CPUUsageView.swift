//
//  CPUUsageView.swift
//  KandjiSystemUtility
//
//  Created by Michael Dautermann on 2/22/24.
//

import Cocoa

class CPUUsageView: NSView {
    /// Setup!
    let dataSource: CpuUsage = CpuUsage()
    var updateTimer: Timer!
    @IBOutlet var tableView: NSTableView?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
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

