/*
 * Copyright (c) 2023 Félix Poulin-Bélanger. All rights reserved.
 */

import SwiftUI
private let dynamicPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"

struct ContentView: View {
    init() {
    }
    
    @State private var kfd: UInt64 = 0

    private var puaf_pages_options = [16, 32, 64, 128, 256, 512, 1024, 2048]
    @State private var puaf_pages_index = 7
    @State private var puaf_pages = 0

    private var puaf_method_options = ["physpuppet", "smith"]
    @State private var puaf_method = 1

    private var kread_method_options = ["kqueue_workloop_ctl", "sem_open"]
    @State private var kread_method = 1

    private var kwrite_method_options = ["dup", "sem_open"]
    @State private var kwrite_method = 1

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $puaf_pages_index, label: Text("puaf pages:")) {
                        ForEach(0 ..< puaf_pages_options.count, id: \.self) {
                            Text(String(self.puaf_pages_options[$0]))
                        }
                    }.disabled(kfd != 0)
                }
                Section {
                    Picker(selection: $puaf_method, label: Text("puaf method:")) {
                        ForEach(0 ..< puaf_method_options.count, id: \.self) {
                            Text(self.puaf_method_options[$0])
                        }
                    }.disabled(kfd != 0)
                }
                Section {
                    Picker(selection: $kread_method, label: Text("kread method:")) {
                        ForEach(0 ..< kread_method_options.count, id: \.self) {
                            Text(self.kread_method_options[$0])
                        }
                    }.disabled(kfd != 0)
                }
                Section {
                    Picker(selection: $kwrite_method, label: Text("kwrite method:")) {
                        ForEach(0 ..< kwrite_method_options.count, id: \.self) {
                            Text(self.kwrite_method_options[$0])
                        }
                    }.disabled(kfd != 0)
                }
                Section {
                    HStack {
                        Button("kopen") {
                            puaf_pages = puaf_pages_options[puaf_pages_index]
                            kfd = do_kopen(UInt64(puaf_pages), UInt64(puaf_method), UInt64(kread_method), UInt64(kwrite_method))
                            do_fun()
                        }.disabled(kfd != 0).frame(minWidth: 0, maxWidth: .infinity)
                        
                        Button("hide bar") {
                            do_hidebar()
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        Button("Change Card") {
                            do_card()
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        Button("change font") {
                            do_font()
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        
                        Button("kclose") {
                            do_kclose()
                            do_respring()
                            puaf_pages = 0
                            kfd = 0
                        }.disabled(kfd == 0).frame(minWidth: 0, maxWidth: .infinity)
                    }.buttonStyle(.bordered)
                }.listRowBackground(Color.clear)
                if kfd != 0 {
                    Section {
                        VStack {
                            Text("Success!").foregroundColor(.green)
                            Text("Look at output in Xcode")
                        }.frame(minWidth: 0, maxWidth: .infinity)
                    }.listRowBackground(Color.clear)
                }
            }.navigationBarTitle(Text("kfd"), displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
func plistChange(plistPath: String, key: String, value: Int) {
    let stringsData = try! Data(contentsOf: URL(fileURLWithPath: plistPath))
    
    let plist = try! PropertyListSerialization.propertyList(from: stringsData, options: [], format: nil) as! [String: Any]
    func changeValue(_ dict: [String: Any], _ key: String, _ value: Int) -> [String: Any] {
        var newDict = dict
        for (k, v) in dict {
            if k == key {
                newDict[k] = value
            } else if let subDict = v as? [String: Any] {
                newDict[k] = changeValue(subDict, key, value)
            }
        }
        return newDict
    }
    
    var newPlist = plist
    newPlist = changeValue(newPlist, key, value)
    
    let newData = try! PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
    
    if overwriteFile(originPath: plistPath, replacementData: newData) {
        // all actions completed
        DispatchQueue.main.asyncAfter(deadline: .now()){
            do_respring();
        }
    } else {
        // something went wrong
      //  shouldAlertPlistCorrupted = true
    }
}


extension UserDefaults {
   
}
func overwriteFile(originPath: String, replacementData: Data) -> Bool {
#if false
    let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].path
    
    let pathToRealTarget = originPath
    let originPath = documentDirectory + originPath
    let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTarget))
    try! origData.write(to: URL(fileURLWithPath: originPath))
#endif
    
    // open and map original font
    let fd = open(originPath, O_RDONLY | O_CLOEXEC)
    if fd == -1 {
        print("Could not open target file")
        return false
    }
    defer { close(fd) }
    // check size of font
    let originalFileSize = lseek(fd, 0, SEEK_END)
    guard originalFileSize >= replacementData.count else {
        print("Original file: \(originalFileSize)")
        print("Replacement file: \(replacementData.count)")
        print("File too big")
        return false
    }
    lseek(fd, 0, SEEK_SET)
    
    // Map the font we want to overwrite so we can mlock it
    let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, fd, 0)
    if fileMap == MAP_FAILED {
        print("Failed to map")
        return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, replacementData.count) == 0 else {
        print("Failed to mlock")
        return true
    }
    
    // for every 16k chunk, rewrite
    print(Date())
    for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
        print(String(format: "%lx", chunkOff))
//        if chunkOff % 0x40000 == 0 {
//            updateProgress(total: false, progress: Double(chunkOff))
//        }
        let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x4000)]
        var overwroteOne = false
        for _ in 0..<2 {
              let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                    return funVnodeOverwriteWithBytes(
                        dynamicPath, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count, true)
              }
//        let dataChunk = fontData[chunkOff..<min(fontData.count, chunkOff + 0x4000)]
//        var overwroteOne = false
//        print(pathToTargetFont, chunkOff, dataChunk.count)
//        for _ in 0..<2 {
//            let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
//                return funVnodeOverwriteWithBytes(
//                    pathToTargetFont,
//                    Int64(chunkOff),
//                    dataChunkBytes.baseAddress?.bindMemory(to: UInt8.self, capacity: dataChunkBytes.count),
//                    dataChunkBytes.count,
//                    true
//                )
//            }
              if overwriteSucceeded != 0 {
                overwroteOne = true
                break
              }
//              print("try again?!")
//              sleep(1)
                break
            }
        guard overwroteOne else {
           // sendImportMessage(.failure("can't overwrite"))
            print("try again?!")
            return false;
         //   return
        }
    }

  //  updateProgress(total: false, progress: Double(replacementData.count))
    //sendImportMessage(.success)
    print(Date())
    return false;
}
