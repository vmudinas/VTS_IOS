import SwiftUI
import AVKit

public struct VideoUploadView: View {
    @ObservedObject var videoService = VideoService()
    @State private var showingVideoPickerSheet = false
    @State private var showingVideoUploadForm = false
    @State private var selectedVideoURL: URL? = nil
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if videoService.isUploading {
                    // Upload progress view
                    VStack {
                        ProgressView("Uploading video...", value: Double(videoService.uploadProgress), total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding()
                        
                        Text("\(Int(videoService.uploadProgress * 100))%")
                            .font(.caption)
                    }
                    .padding()
                }
                
                List {
                    Section(header: Text(localization.localized("upload_new_video"))) {
                        Button(action: {
                            showingVideoPickerSheet = true
                        }) {
                            HStack {
                                Image(systemName: "video.badge.plus")
                                    .foregroundColor(.blue)
                                Text("Record or Select Video")
                            }
                        }
                    }
                    
                    Section(header: Text("Uploaded Videos")) {
                        ForEach(videoService.videos) { video in
                            VideoRowView(video: video)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle(localization.localized("video_upload"), displayMode: .inline)
            .actionSheet(isPresented: $showingVideoPickerSheet) {
                ActionSheet(
                    title: Text("Select Video Source"),
                    message: Text("Choose a video to upload"),
                    buttons: [
                        .default(Text("Camera")) {
                            // In a real app, would open camera
                            // For mockup, we'll just show the form
                            self.showingVideoUploadForm = true
                        },
                        .default(Text("Photo Library")) {
                            // In a real app, would open photo library
                            // For mockup, we'll just show the form
                            self.showingVideoUploadForm = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingVideoUploadForm) {
                VideoUploadFormView(
                    videoService: videoService,
                    isPresented: $showingVideoUploadForm
                )
            }
        }
    }
}

struct VideoRowView: View {
    let video: Video
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: "video.fill")
                    .foregroundColor(.blue)
                
                Text(video.title)
                    .font(.headline)
                
                Spacer()
                
                statusView(for: video.uploadStatus)
            }
            
            Text(video.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            HStack {
                Text(formattedDate(video.uploadDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if video.duration > 0 {
                    Text(formattedDuration(video.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 5)
    }
    
    private func statusView(for status: UploadStatus) -> some View {
        let color: Color = {
            switch status {
            case .notStarted: return .gray
            case .uploading: return .orange
            case .completed: return .green
            case .failed: return .red
            }
        }()
        
        return Text(status.rawValue)
            .font(.caption)
            .foregroundColor(color)
            .bold()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct VideoUploadFormView: View {
    @ObservedObject var videoService: VideoService
    @Binding var isPresented: Bool
    
    @State private var title: String = ""
    @State private var description: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Video Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section {
                    // Preview placeholder - in a real app, this would show the actual video
                    HStack {
                        Spacer()
                        Image(systemName: "video")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(height: 120)
                }
            }
            .navigationBarTitle(localization.localized("upload_video"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Upload") {
                    if !title.isEmpty {
                        // Create a mock URL for demonstration
                        let mockURL = URL(string: "https://example.com/video.mp4")
                        
                        // Call the upload function
                        videoService.uploadVideo(
                            title: title,
                            description: description,
                            videoURL: mockURL!
                        ) { success in
                            if success {
                                isPresented = false
                            }
                        }
                    }
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

struct VideoUploadView_Previews: PreviewProvider {
    static var previews: some View {
        VideoUploadView()
    }
}