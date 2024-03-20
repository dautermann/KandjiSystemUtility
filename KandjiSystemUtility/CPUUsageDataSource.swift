//
//  CPUUsageDataSource.swift
//  KandjiSystemUtility
//
//  Created by Michael Dautermann on 2/22/24.
//

import Foundation
import Cocoa

// CPU usage credit VenoMKO: https://stackoverflow.com/a/6795612/1033581
class CpuUsage: NSObject {
    var cpuInfo: processor_info_array_t!
    var prevCpuInfo: processor_info_array_t?
    var numCpuInfo: mach_msg_type_number_t = 0
    var numPrevCpuInfo: mach_msg_type_number_t = 0
    var numCPUs: uint = 0
    var inUseArray: [Int32] = [Int32]()
    var totalArray: [Int32] = [Int32]()
    let CPUUsageLock: NSLock = NSLock()
    
    override init() {
        super.init()
        let mibKeys: [Int32] = [ CTL_HW, HW_NCPU ]
        // sysctl Swift usage credit Matt Gallagher: https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift
        mibKeys.withUnsafeBufferPointer() { mib in
            var sizeOfNumCPUs: size_t = MemoryLayout<uint>.size
            let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &numCPUs, &sizeOfNumCPUs, nil, 0)
            if status != 0 {
                numCPUs = 1
            }
            inUseArray = [Int32](repeating: 0, count: Int(numCPUs))
            totalArray = [Int32](repeating: 0, count: Int(numCPUs))
        }
    }
    
    func updateInfo() {
        var numCPUsU: natural_t = 0
        let err: kern_return_t = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
        if err == KERN_SUCCESS {
            CPUUsageLock.lock()
            
            for i in 0 ..< Int32(numCPUs) {
                var inUse: Int32
                var total: Int32
                if let prevCpuInfo = prevCpuInfo {
                    inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    total = inUse + (cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)])
                } else {
                    inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    total = inUse + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                }
                inUseArray[Int(i)] = inUse
                totalArray[Int(i)] = total

                // print(String(format: "Core: %u Usage: %f", i, Float(inUse) / Float(total)))
            }
            CPUUsageLock.unlock()
            
            if let prevCpuInfo = prevCpuInfo {
                // vm_deallocate Swift usage credit rsfinn: https://stackoverflow.com/a/48630296/1033581
                let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
            }
            
            prevCpuInfo = cpuInfo
            numPrevCpuInfo = numCpuInfo
            
            cpuInfo = nil
            numCpuInfo = 0
        } else {
            print("Error!")
        }
    }
}

class CpuMeterTableCellView: NSTableCellView {
    @IBOutlet var progressBar: NSProgressIndicator?
}

extension CpuUsage: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Int(numCPUs)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let identifier = tableColumn?.identifier {
            let totalForThisCPU = totalArray[row]
            let percentage = totalForThisCPU > 0 ? Float(inUseArray[row]) / Float(totalForThisCPU) : 0.0
            if(identifier == NSUserInterfaceItemIdentifier("bar")) {
                guard let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? CpuMeterTableCellView else { return nil }
                cell.progressBar?.doubleValue = Double(percentage)
                return cell
            }

            guard let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView else { return nil }
            cell.textField?.stringValue = String(format: "%.2f%%%", percentage * 100)
            return cell
        }
        // should never ever hit here
        return NSView()
    }
}
