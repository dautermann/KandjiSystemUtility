//
//  ViewController.swift
//  KandjiSystemUtility
//
//  Created by Michael Dautermann on 2/22/24.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var cpuUsageView: CPUUsageView!
    @IBOutlet var connectedVolumesView: ConnectedVolumesUsageView!
    @IBOutlet var memoryUsageView: MemoryUsageView!
    
    /// configure how the subviews will display (which will in turn get their data sources fired up)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cpuUsageView.configure()
        connectedVolumesView.configure()
        memoryUsageView.configure()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

