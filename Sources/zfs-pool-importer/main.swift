import Foundation

let zpoolImportCookie="/var/run/org.openzfsonosx.zpool-import-all.didRun"
let invariantDisksCookie="/var/run/disk/invariant.idle"
let timeout = TimeInterval(60)

let formatter = DateFormatter()
formatter.locale = Locale(identifier: "en_US")
formatter.dateStyle = .medium
formatter.timeStyle = .long

let stdout = FileHandle.standardOutput

stdout.print("+zfs-pool-importer")
stdout.print(formatter.string(from: Date()))

formatter.dateStyle = .none
formatter.timeStyle = .medium
stdout.print("Running system_profiler to ensure the device tree is populated...")
launch(command: "/usr/sbin/system_profiler",
       arguments: ["SPParallelATADataType", "SPCardReaderDataType", "SPFibreChannelDataType", "SPFireWireDataType",
                   "SPHardwareRAIDDataType", "SPNetworkDataType", "SPPCIDataType", "SPParallelSCSIDataType",
                   "SPSASDataType", "SPSerialATADataType", "SPStorageDataType", "SPThunderboltDataType",
                   "SPUSBDataType", "SPNetworkVolumeDataType"],
       output: .nullDevice, error: .nullDevice)
launch(command: "/bin/sync")

stdout.print("\(formatter.string(from: Date())): waiting until file \(invariantDisksCookie) is found...")

let fm = FileManager.default
let beganWaiting = Date()
var waited = TimeInterval.zero
var found = fm.fileExists(atPath: invariantDisksCookie)
while !found && waited < timeout
{
  Thread.sleep(forTimeInterval: 0.1)
  waited = Date().timeIntervalSince(beganWaiting)
  found = fm.fileExists(atPath: invariantDisksCookie)
}
stdout.print("\(invariantDisksCookie) was\(found ? "" : "n't") found in \(String(format: "%.2f", waited)) seconds")

Thread.sleep(forTimeInterval: 10)
stdout.print("\(formatter.string(from: Date())): running zpool import -a")

let code = launch(command: "/usr/local/zfs/bin/zpool",
                  arguments: ["import", "-a", "-d", "/var/run/disk/by-id"])

stdout.print("\(formatter.string(from: Date())): zpool import returned with exit code \(code)")

stdout.print("Updating file access and modification time at path \(zpoolImportCookie)")
launch(command: "/usr/bin/touch", arguments: [zpoolImportCookie])

formatter.dateStyle = .medium
formatter.timeStyle = .long
stdout.print(formatter.string(from: Date()))
stdout.print("-zfs-pool-importer")

exit(code)
