//
//  MemoryUsageView.swift
//  KandjiSystemUtility
//
//  Created by Michael Dautermann on 2/22/24.
//

import Cocoa

class MemoryUsageView: NSView {
    /// Setup!
    let dataSource: MemoryUsageDataSource = MemoryUsageDataSource()
    var updateTimer: Timer!
    @IBOutlet var physicalMemoryUsedLabel: NSTextField!
    @IBOutlet var totalMemoryLabel: NSTextField!

    func configure() {
        updateTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
        totalMemoryLabel.stringValue = "Total Memory Used: \(dataSource.totalPhysicalMemoryString)"
    }

    @objc func updateInfo(_ timer: Timer) {
        /// if no valid result, should we just blank out those fields?  For now we'll show the last useful value
        if let result = dataSource.updateInfo() {
            physicalMemoryUsedLabel.stringValue = "Physical Memory Used: \(result.physicalMemoryUsed)"
        }
    }

}
