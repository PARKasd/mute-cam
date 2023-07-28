import SwiftUI

struct ContentView: View {
    @State private var kfd: UInt64 = 0
    
    @State private var puafPages = 2048
    @State private var puafMethod = 1
    @State private var kreadMethod = 1
    @State private var kwriteMethod = 1
    
    var puafPagesOptions = [16, 32, 64, 128, 256, 512, 1024, 2048]
    var puafMethodOptions = ["physpuppet", "smith"]
    var kreadMethodOptions = ["kqueue_workloop_ctl", "sem_open"]
    var kwriteMethodOptions = ["dup", "sem_open"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payload Settings")) {
                    Picker("puaf pages:", selection: $puafPages) {
                        ForEach(puafPagesOptions, id: \.self) { pages in
                            Text(String(pages))
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    .disabled(kfd != 0)
                    
                    Picker("puaf method:", selection: $puafMethod) {
                        ForEach(0..<puafMethodOptions.count, id: \.self) { index in
                            Text(puafMethodOptions[index])
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    .disabled(kfd != 0)
                }
                
                Section(header: Text("Kernel Settings")) {
                    Picker("kread method:", selection: $kreadMethod) {
                        ForEach(0..<kreadMethodOptions.count, id: \.self) { index in
                            Text(kreadMethodOptions[index])
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    .disabled(kfd != 0)
                    
                    Picker("kwrite method:", selection: $kwriteMethod) {
                        ForEach(0..<kwriteMethodOptions.count, id: \.self) { index in
                            Text(kwriteMethodOptions[index])
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    .disabled(kfd != 0)
                }
                
                Section {
                    HStack(spacing: 20) {
                        Button("Open exploit") {
                            kfd = do_kopen(UInt64(puafPages), UInt64(puafMethod), UInt64(kreadMethod), UInt64(kwriteMethod))
                            do_fun(kfd)
                        }.disabled(kfd != 0)
                        Button("Close exploit") {
                            do_kclose(kfd)
                            kfd = 0
                        }.disabled(kfd == 0)
                        Button("Respring") {
                            kfd = 0
                            do_respring()
                        }
                        .accentColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                if kfd != 0 {
                    Section(header: Text("Status")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Success!")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text("View output in Xcode")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Other Actions")) {
                    Button("Hide Dock") {
                        do_hidedock(kfd)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Button("Enable Dynamic Island") {
                                          gibmebar(kfd)
                                      }
                                      .buttonStyle(BorderlessButtonStyle())
                }
            }
            .navigationBarTitle("Kernel Exploit", displayMode: .inline)
            .accentColor(.green) // Highlight the navigation bar elements in green
        }
        .foregroundColor(.white) // Set the default text color to black
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
