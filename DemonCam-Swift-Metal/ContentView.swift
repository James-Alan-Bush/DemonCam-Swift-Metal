//
//  ContentView.swift
//  DemonCam-Swift-Metal
//
//  Created by Xcode Developer on 3/6/24.
//



import SwiftUI
import Photos

struct ContentView: View {
    @ObservedObject var cameraManager = CameraManager()
    @State private var isRecording:  Bool   = false
    
    @State private var showingSheet: Bool   = false
    
    @State private var lumaRed:      Double = 0.2126
    @State private var lumaGreen:    Double = 0.7152
    @State private var lumaBlue:     Double = 0.0722
    @State private var isEditing:    Bool   = false
    
    @State private var highlights:   Double = 1.0
    @State private var shadows:      Double = 0.0
    
    var body: some View {
        let alignment: Alignment = .bottom
        
        ZStack(alignment: alignment) {
            if let image = cameraManager.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                  .colorEffect(ShaderLibrary.default.desaturate(.float(lumaRed), .float(lumaGreen), .float(lumaBlue), .float(lumaAlpha)))
                  .colorEffect(ShaderLibrary.default.highlightsShadows(.float(highlights), .float(shadows), .float(lumaRed), .float(lumaGreen), .float(lumaBlue)))
//                    .layerEffect(
//                        ShaderLibrary.variableBlur(
//                            .boundingRect,
//                            .float(highlights * 100.0),
//                            .float(1.0),
//                            .image(Image(uiImage: image)),
//                            .float(1)
//                        ),
//                        maxSampleOffset: CGSizeZero,
//                        isEnabled: true
//                    )
            } else {
                Text("Waiting for camera input...")
            }
        }
        .onTapGesture {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet, content: {
            Form {
                Section(header: Text("Luminance Weighting")) {
                    Slider(value: $lumaRed, in: 0.0...1.0, step: 0.0001, onEditingChanged: {_ in }, minimumValueLabel: Image(systemName: "r.circle"), maximumValueLabel: Image(systemName: "r.circle.fill"), label: {})
                    
                    Slider(value: $lumaGreen, in: 0.0...1.0, step: 0.0001, onEditingChanged: {_ in }, minimumValueLabel: Image(systemName: "g.circle"), maximumValueLabel: Image(systemName: "g.circle.fill"), label: {})
                    
                    Slider(value: $lumaBlue, in: 0.0...1.0, step: 0.0001, onEditingChanged: {_ in }, minimumValueLabel: Image(systemName: "b.circle"), maximumValueLabel: Image(systemName: "b.circle.fill"), label: {})
                }
                
                Section(header: Text("Highlights and Shadows")) {
                    Slider(value: $highlights, in: 0.0...2.0, step: 0.0001, onEditingChanged: {_ in }, minimumValueLabel: Image(systemName: "h.circle"), maximumValueLabel: Image(systemName: "h.circle.fill"), label: {})
                    
                    Slider(value: $shadows, in: 0.0...1.0, step: 0.0001, onEditingChanged: {_ in }, minimumValueLabel: Image(systemName: "s.circle"), maximumValueLabel: Image(systemName: "s.circle.fill"), label: {})
                }
                
                Section(header: Text("Capture Devices")) {
                    List(cameraManager.deviceNames, id: \.self) { deviceName in
                        HStack {
                            Text(deviceName)
                            Spacer()
                            // Conditionally display the checkmark right next to the text
                            if deviceName == cameraManager.currentDeviceName {
                                Image(systemName: "checkmark").foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle()) // Ensures the tap gesture registers across the entire row
                        .onTapGesture {
                            // Update the current device when a user taps a row
                            cameraManager.setCurrentDevice(name: deviceName)
                        }
                    }
                    .onAppear {
                        cameraManager.fetchDevices()
                    }
                    
                }
                .onAppear {
                    cameraManager.fetchDevices()
                }
                
            }
            .onTapGesture {
                showingSheet.toggle()
            }
        })
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        
        //        Spacer()
        //
        //        Button(action: {
        //            isRecording.toggle() // Toggle the recording state
        //
        //            if isRecording {
        //                // Start recording
        //                cameraManager.setupVideoWriter()
        //                cameraManager.startRecording()
        //            } else {
        //                // Stop recording and save the video
        //                cameraManager.finishRecording { savedURL in
        //                    guard let url = savedURL else { return }
        //                    PHPhotoLibrary.shared().performChanges({
        //                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        //                    }) { success, error in
        //                        if success {
        //                            print("Video saved to Photos")
        //                        } else {
        //                            print("Error saving video: \(String(describing: error))")
        //                        }
        //                    }
        //                }
        //            }
        //        }) {
        //            Text(isRecording ? "Stop Recording" : "Start Recording")
        //                .foregroundColor(.white)
        //                .padding()
        //                .background(isRecording ? Color.red : Color.blue)
        //                .clipShape(Capsule())
        //        }
        //        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 50) // Adjust position as needed
        
    }
}

#Preview {
    ContentView()
}
