import Foundation

public enum FileOrganizer {

    public static let destinationName = "Roba cleaaan"

    private static let subfolders = ["Documenti", "Immagini", "Video", "Altro"]

    private static let categoryMap: [String: String] = [
        // Documenti
        "pdf": "Documenti", "doc": "Documenti", "docx": "Documenti",
        "pages": "Documenti", "xls": "Documenti", "xlsx": "Documenti",
        "numbers": "Documenti", "ppt": "Documenti", "pptx": "Documenti",
        "key": "Documenti", "txt": "Documenti", "rtf": "Documenti", "csv": "Documenti",
        // Immagini
        "png": "Immagini", "jpg": "Immagini", "jpeg": "Immagini",
        "gif": "Immagini", "bmp": "Immagini", "tiff": "Immagini", "tif": "Immagini",
        "webp": "Immagini", "heic": "Immagini", "svg": "Immagini", "raw": "Immagini",
        // Video
        "mp4": "Video", "mov": "Video", "avi": "Video", "mkv": "Video",
        "m4v": "Video", "webm": "Video", "mpg": "Video", "mpeg": "Video"
    ]

    /// Returns the destination subfolder name for a file extension.
    public static func category(for ext: String) -> String {
        categoryMap[ext.lowercased()] ?? "Altro"
    }

    /// Returns a non-conflicting URL inside `directory` for `file`.
    /// If `file.lastPathComponent` already exists, appends " (2)", " (3)", etc.
    public static func resolveConflict(for file: URL, in directory: URL) -> URL {
        let fm = FileManager.default
        var candidate = directory.appendingPathComponent(file.lastPathComponent)
        guard fm.fileExists(atPath: candidate.path) else { return candidate }

        let base = file.deletingPathExtension().lastPathComponent
        let ext  = file.pathExtension
        var n = 2
        repeat {
            let name = ext.isEmpty ? "\(base) (\(n))" : "\(base) (\(n)).\(ext)"
            candidate = directory.appendingPathComponent(name)
            n += 1
        } while fm.fileExists(atPath: candidate.path)
        return candidate
    }

    /// Moves all visible files from `sources` into categorized subfolders under `destinationBase`.
    /// Returns the number of files successfully moved.
    @discardableResult
    public static func clean(sources: [URL], destinationBase: URL) -> Int {
        let fm = FileManager.default

        for sub in subfolders {
            try? fm.createDirectory(
                at: destinationBase.appendingPathComponent(sub),
                withIntermediateDirectories: true
            )
        }

        var moved = 0

        for source in sources {
            guard let entries = try? fm.contentsOfDirectory(
                at: source,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            for fileURL in entries {
                let isDir = (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if isDir { continue }

                let targetDir = destinationBase.appendingPathComponent(category(for: fileURL.pathExtension))
                let targetURL = resolveConflict(for: fileURL, in: targetDir)

                if (try? fm.moveItem(at: fileURL, to: targetURL)) != nil {
                    moved += 1
                }
            }
        }

        return moved
    }
}
