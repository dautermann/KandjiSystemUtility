//
//  MemoryUsageDataSource.swift
//  KandjiSystemUtility
//
//  Created by Michael Dautermann on 2/22/24.
//

import Cocoa

struct MemoryUsage {
    let physicalMemoryUsed: String
}

class MemoryUsageDataSource: NSObject {
    var pageSize: Int = 0
    let HOST_VM_INFO_COUNT = MemoryLayout<vm_statistics_data_t>.stride/MemoryLayout<integer_t>.stride
    var count: mach_msg_type_number_t = 0
    let unit: Double = Double(1024 * 1024)
    let byteCountFormatter: ByteCountFormatter = ByteCountFormatter()
    var totalPhysicalMemoryString: String = ""

    override init() {
        super.init()
        count = mach_msg_type_number_t(HOST_VM_INFO_COUNT)
        let mibKeys: [Int32] = [ CTL_HW, HW_PAGESIZE ]
        mibKeys.withUnsafeBufferPointer() { mib in
            var length: size_t = MemoryLayout<Int>.size
            let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &pageSize, &length, nil, 0)
            if status != 0 {
                Swift.print("error getting page size \(status)")
            }
        }
        var pibKeys : [Int32] = [ CTL_HW, HW_MEMSIZE ]
        var physicalMemorySize: Int64 = 0
        var size = MemoryLayout<Int64>.size
        if sysctl(&pibKeys, UInt32(pibKeys.count), &physicalMemorySize, &size, nil, 0) != 0 {
            print("sysctl failed")
        }
        totalPhysicalMemoryString = byteCountFormatter.string(fromByteCount: physicalMemorySize)
    }
    
    func updateInfo()->MemoryUsage? {
        // Initialize a blank vm_statistics_data_t
        var vm_stat = vm_statistics_data_t()

        // Get a raw pointer to vm_stat
        let err: kern_return_t = withUnsafeMutableBytes(of: &vm_stat) {
            // Bind the raw buffer to Int32, since that's what host_statistics
            // seems to want a pointer to.
            let boundBuffer = $0.bindMemory(to: Int32.self)

            // Call host_statistics, and return its status out of the closure.
            return host_statistics(mach_host_self(), HOST_VM_INFO, boundBuffer.baseAddress, &count)
        }

        // Now take a look at what we got and compare it against KERN_SUCCESS
        if err != KERN_SUCCESS {
            // Error, failed to get Virtual memory info
            Swift.print("error, failed to get virtual memory info")
            return nil
        }
        
        let totalUsed = byteCountFormatter.string(fromByteCount: Int64(Double(vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count + vm_stat.free_count) * Double(pageSize)))
        let structToReturn = MemoryUsage(physicalMemoryUsed: totalUsed)
        return structToReturn
    }
}
