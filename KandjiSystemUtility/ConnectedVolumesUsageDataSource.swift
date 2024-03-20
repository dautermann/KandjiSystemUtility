//
//  ConnectedVolumesUsageDataSource.swift
//  KandjiSystemUtility
//
//  Created by Michael Dautermann on 2/23/24.
//

import Cocoa

class ConnectedVolumesUsageDataSource: NSObject {

    struct ConnectedVolumesUsage {
        let volumeName: String
        let available: Int
        let total: Int
    }

    var usageArray: [ConnectedVolumesUsage] = [ConnectedVolumesUsage]()
    let byteCountFormatter: ByteCountFormatter = ByteCountFormatter()

    func isThisASystemVolume(volumeName: String)->Bool {
        switch(volumeName) {
        // other System related volumes we can't write to...
        case "Recovery", "com.apple.TimeMachine.localsnapshots":
            return true
        default:
            return false
        }
    }
    
    func updateInfo() {
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey, .volumeIsEjectableKey]
        let paths = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [.skipHiddenVolumes])
        if let urls = paths {
            // shouldn't have to be thread safe because we refresh the table only after updateInfo completes
            var newUsageArray: [ConnectedVolumesUsage] = [ConnectedVolumesUsage]()
            for url in urls {
                guard let values = try? url.resourceValues(forKeys: [.volumeNameKey]) else { continue }
                let volumeName = values.allValues[.volumeNameKey] as? String ?? ""
                let components = url.pathComponents
                
                // first case is for currently mounted (local) volume, other case is for mounted volumes
                if (components.count == 1) || (components.count > 1 && components[1] == "Volumes" && !isThisASystemVolume(volumeName: components[2]))
                {
                    let fileURL = url
                    do {
                        let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
                        if let availableCapacity = values.volumeAvailableCapacity, let totalCapacity = values.volumeTotalCapacity {
                            // print("Available capacity for \(url): \(availableCapacity) out of \(totalCapacity)")
                            let connectedVolume = ConnectedVolumesUsage(volumeName: volumeName, available: availableCapacity, total: totalCapacity)
                            newUsageArray.append(connectedVolume)
                        } else {
                            print("Capacity is unavailable for \(url)")
                        }
                    } catch {
                        print("Error retrieving capacity from \(url): \(error.localizedDescription)")
                    }
                }
            }
            usageArray = newUsageArray
        }
    }
}

class ConnectedVolumesTableCellView : NSTableCellView {
    @IBOutlet var level: NSLevelIndicator!
    @IBOutlet var volumeNameLabel: NSTextField!
    @IBOutlet var availableLabel: NSTextField!
}

extension ConnectedVolumesUsageDataSource: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return usageArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let identifier = tableColumn?.identifier {
            let usage = usageArray[row]
            guard let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? ConnectedVolumesTableCellView else { return nil }
            cell.volumeNameLabel.stringValue = usage.volumeName
            cell.availableLabel.stringValue = String(format: "\(byteCountFormatter.string(fromByteCount: Int64(usage.available))) Avail.")

            // level indicator shows green for lots of free space, yellow for warning and red for critical (not much free space)
            let howMuchAvailable = Double(usage.available) / Double(usage.total) // a fraction between 0 and 1
            let howMuchAvailableInTermsOfSegments = (howMuchAvailable * 10 + 1)
            cell.level.intValue = Int32(howMuchAvailableInTermsOfSegments)
            return cell
        }
        return NSView()
    }
}
