//
//  ContentView.swift
//  DemonCam-Swift-Metal
//
//  Created by Xcode Developer on 3/6/24.
//

import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var isRecording = false
    
    @State private var showingSheet: Bool = false
    
    @State private var lumaRed: Double = 0.2126
    @State private var lumaGreen: Double = 0.7152
    @State private var lumaBlue: Double = 0.0722
    @State private var isEditing = false
    
    @State private var lumaAlpha: Double = 0.0
    @State private var highlights: Double = 1.0
    @State private var shadows: Double = 0.0
    
    var body: some View {
        let alignment: Alignment = .bottom
        
        ZStack(alignment: alignment) {
            if let image = cameraManager.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                //                    .colorEffect(ShaderLibrary.default.desaturate(.float(lumaRed), .float(lumaGreen), .float(lumaBlue), .float(lumaAlpha)))
                    .colorEffect(ShaderLibrary.default.highlightsShadows(.float(highlights), .float(shadows), .float(lumaRed), .float(lumaGreen), .float(lumaBlue)))
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
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
                    Slider(
                        value: $lumaRed.animation(),
                        in: 0.1...0.9,
                        onEditingChanged: { editing in
                            isEditing = editing
                        },
                        minimumValueLabel: Image(systemName: "r.circle"),
                        maximumValueLabel: Image(systemName: "r.circle.fill"),
                        label: {}
                    )
                    .accentColor(Color(red: 1.0, green: 0.0, blue: 0, opacity: 0.15))
                    
                    Slider(value: $lumaGreen, in: 0...1, step: 0.0001)
                        .accentColor(Color(red: 0.0, green: 1.0, blue: 0, opacity: 0.15))
                    
                    Slider(value: $lumaBlue, in: 0...1, step: 0.0001)
                        .accentColor(Color(red: 0.0, green: 0, blue: 1.0, opacity: 0.15))
                }
                Section(header: Text("Highlights and Shadows")) {
                    Slider(value: $highlights, in: 0.0...2.0, step: 0.0001)
                        .accentColor(Color(red: 0.0, green: 1.0, blue: 0, opacity: 0.15))
                    
                    Slider(value: $shadows, in: 0...1, step: 0.0001)
                        .accentColor(Color(red: 0.0, green: 0, blue: 1.0, opacity: 0.15))
                }
            }
            .onTapGesture {
                showingSheet.toggle()
            }
        })
        
            //            })
            //            .frame(width: UIScreen.main.bounds.width / 2.0, height: UIScreen.main.bounds.height / 2.0, alignment: .bottom)
            
            //        }
            
            
            
            
            
            //        VStack {
            //            Slider(value: $lumaRed, in: 0...1, step: 0.0001)
            //                .accentColor(Color(red: 1.0, green: 0.0, blue: 0, opacity: 0.15))
            //
            //            Slider(value: $lumaGreen, in: 0...1, step: 0.0001)
            //                .accentColor(Color(red: 0.0, green: 1.0, blue: 0, opacity: 0.15))
            //
            //            Slider(value: $lumaBlue, in: 0...1, step: 0.0001)
            //                .accentColor(Color(red: 0.0, green: 0, blue: 1.0, opacity: 0.15))
            //
            //            Slider(value: $highlights, in: 0.0...2.0, step: 0.0001)
            //                .accentColor(Color(red: 0.0, green: 1.0, blue: 0, opacity: 0.15))
            //
            //            Slider(value: $shadows, in: 0...1, step: 0.0001)
            //                .accentColor(Color(red: 0.0, green: 0, blue: 1.0, opacity: 0.15))
            //        }
            ////        .frame(width: UIScreen.main.bounds.width / 3.0, height: UIScreen.main.bounds.height / 3.0, alignment: .bottom)
            //        .background {
            //            if let image = cameraManager.image {
            //                Image(uiImage: image)
            //                    .resizable()
            //                    .aspectRatio(contentMode: .fit)
            //                //                    .colorEffect(ShaderLibrary.default.desaturate(.float(lumaRed), .float(lumaGreen), .float(lumaBlue), .float(lumaAlpha)))
            //                    .colorEffect(ShaderLibrary.default.highlightsShadows(.float(highlights), .float(shadows), .float(lumaRed), .float(lumaGreen), .float(lumaBlue)))
            //                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
            //            } else {
            //                Text("Waiting for camera input...")
            //            }
            //        }
            
            
            
            
            //            VStack {
            //                Spacer()
            //                Group {
            //                    Slider(value: $lumaRed, in: 0...1, step: 0.001, label: { Label {
            //                        Text("1.0")
            //                    } icon: {
            //                        Image(systemName: "circle.r.fill")
            //                    } }, minimumValueLabel: { Image(systemName: "r.circle") }, maximumValueLabel: { Image(systemName: "r.circle.fill") }, onEditingChanged: { editing in
            //                        isEditing = editing
            //                    }
            //
            
            //                    Slider(value: $lumaRed, in: 0...1, step: 0.0001)
            //                    //                        .accentColor(Color(red: 1.0, green: 0, blue: 0, opacity: 0.15))
            //                    {
            //                        Text("Red")
            //                    } minimumValueLabel: {
            //                        HStack {
            //                            Text("0")
            //                            Image(systemName: "circle.r")
            //                        }
            //                    } maximumValueLabel: {
            //                        Label {
            //                            Text("1.0")
            //                        } icon: {
            //                            Image(systemName: "circle.r.fill")
            //                        }
            //                    } onEditingChanged: { editing in
            //                        isEditing = editing
            //                    }
            //                    Text(
            //                    )
            //                        .foregroundColor(isEditing ? .red : .blue)
            
            
            //                }
            //                .background {
            //                    GeometryReader { geometry in
            //                        Capsule(style: .circular)
            //                            .fill(Color.gray.opacity(0.075)
            //                                .gradient.shadow(.inner(color: Color.black, radius: 2, x: 2, y: 2))
            //                                .shadow(.inner(color: Color.white, radius: 2, x: -2, y: -2)))
            //                            .frame(width: geometry.size.width, height: geometry.size.height)
            //                    }
            //
            //                }
            //                .clipShape(Capsule())
            //                .safeAreaPadding(.bottom)
            //                .safeAreaPadding(.top)
            //            }
            //            .safeAreaPadding()
            //
            //
            //        }
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
