import XCTest
@testable import CleaaanCore

final class FileOrganizerTests: XCTestCase {

    // MARK: - category(for:)

    func testCategoryPDF() {
        XCTAssertEqual(FileOrganizer.category(for: "pdf"), "Documenti")
    }

    func testCategoryDOCX() {
        XCTAssertEqual(FileOrganizer.category(for: "docx"), "Documenti")
    }

    func testCategoryPNG() {
        XCTAssertEqual(FileOrganizer.category(for: "png"), "Immagini")
    }

    func testCategoryJPEG() {
        XCTAssertEqual(FileOrganizer.category(for: "jpeg"), "Immagini")
    }

    func testCategoryMP4() {
        XCTAssertEqual(FileOrganizer.category(for: "mp4"), "Video")
    }

    func testCategoryMOV() {
        XCTAssertEqual(FileOrganizer.category(for: "mov"), "Video")
    }

    func testCategoryUnknown() {
        XCTAssertEqual(FileOrganizer.category(for: "xyz"), "Altro")
    }

    func testCategoryEmptyExtension() {
        XCTAssertEqual(FileOrganizer.category(for: ""), "Altro")
    }

    func testCategoryIsCaseInsensitive() {
        XCTAssertEqual(FileOrganizer.category(for: "PDF"), "Documenti")
        XCTAssertEqual(FileOrganizer.category(for: "PNG"), "Immagini")
        XCTAssertEqual(FileOrganizer.category(for: "MP4"), "Video")
    }

    // MARK: - resolveConflict(for:in:)

    func testResolveConflictNoExistingFile() throws {
        let dir = try makeTempDir()
        let file = URL(fileURLWithPath: "/tmp/photo.jpg")
        let result = FileOrganizer.resolveConflict(for: file, in: dir)
        XCTAssertEqual(result.lastPathComponent, "photo.jpg")
    }

    func testResolveConflictWithOneExisting() throws {
        let dir = try makeTempDir()
        FileManager.default.createFile(atPath: dir.appendingPathComponent("photo.jpg").path, contents: nil)
        let file = URL(fileURLWithPath: "/tmp/photo.jpg")
        let result = FileOrganizer.resolveConflict(for: file, in: dir)
        XCTAssertEqual(result.lastPathComponent, "photo (2).jpg")
    }

    func testResolveConflictWithTwoExisting() throws {
        let dir = try makeTempDir()
        FileManager.default.createFile(atPath: dir.appendingPathComponent("photo.jpg").path, contents: nil)
        FileManager.default.createFile(atPath: dir.appendingPathComponent("photo (2).jpg").path, contents: nil)
        let file = URL(fileURLWithPath: "/tmp/photo.jpg")
        let result = FileOrganizer.resolveConflict(for: file, in: dir)
        XCTAssertEqual(result.lastPathComponent, "photo (3).jpg")
    }

    func testResolveConflictNoExtension() throws {
        let dir = try makeTempDir()
        FileManager.default.createFile(atPath: dir.appendingPathComponent("Makefile").path, contents: nil)
        let file = URL(fileURLWithPath: "/tmp/Makefile")
        let result = FileOrganizer.resolveConflict(for: file, in: dir)
        XCTAssertEqual(result.lastPathComponent, "Makefile (2)")
    }

    // MARK: - clean(sources:destinationBase:)

    func testCleanMovesFilesToCorrectFolders() throws {
        let (src, dst) = try makeSrcDst()
        for name in ["doc.pdf", "photo.png", "clip.mp4", "archive.zip"] {
            FileManager.default.createFile(atPath: src.appendingPathComponent(name).path, contents: Data("x".utf8))
        }
        let count = FileOrganizer.clean(sources: [src], destinationBase: dst)
        XCTAssertEqual(count, 4)
        XCTAssertTrue(FileManager.default.fileExists(atPath: dst.appendingPathComponent("Documenti/doc.pdf").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: dst.appendingPathComponent("Immagini/photo.png").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: dst.appendingPathComponent("Video/clip.mp4").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: dst.appendingPathComponent("Altro/archive.zip").path))
    }

    func testCleanSkipsHiddenFiles() throws {
        let (src, dst) = try makeSrcDst()
        FileManager.default.createFile(atPath: src.appendingPathComponent(".DS_Store").path, contents: nil)
        FileManager.default.createFile(atPath: src.appendingPathComponent(".hidden").path, contents: nil)
        XCTAssertEqual(FileOrganizer.clean(sources: [src], destinationBase: dst), 0)
    }

    func testCleanSkipsFolders() throws {
        let (src, dst) = try makeSrcDst()
        try FileManager.default.createDirectory(at: src.appendingPathComponent("SomeFolder"), withIntermediateDirectories: true)
        XCTAssertEqual(FileOrganizer.clean(sources: [src], destinationBase: dst), 0)
    }

    func testCleanHandlesNameConflict() throws {
        let (src, dst) = try makeSrcDst()
        try FileManager.default.createDirectory(at: dst.appendingPathComponent("Immagini"), withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: dst.appendingPathComponent("Immagini/photo.png").path, contents: nil)
        FileManager.default.createFile(atPath: src.appendingPathComponent("photo.png").path, contents: Data("x".utf8))
        let count = FileOrganizer.clean(sources: [src], destinationBase: dst)
        XCTAssertEqual(count, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: dst.appendingPathComponent("Immagini/photo (2).png").path))
    }

    func testCleanMultipleSources() throws {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let src1 = base.appendingPathComponent("Source1")
        let src2 = base.appendingPathComponent("Source2")
        let dst  = base.appendingPathComponent("Dest")
        try FileManager.default.createDirectory(at: src1, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: src2, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: base) }
        FileManager.default.createFile(atPath: src1.appendingPathComponent("a.pdf").path, contents: Data("x".utf8))
        FileManager.default.createFile(atPath: src2.appendingPathComponent("b.png").path, contents: Data("x".utf8))
        let count = FileOrganizer.clean(sources: [src1, src2], destinationBase: dst)
        XCTAssertEqual(count, 2)
    }

    // MARK: - Helpers

    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: dir) }
        return dir
    }

    private func makeSrcDst() throws -> (URL, URL) {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let src = base.appendingPathComponent("Source")
        let dst = base.appendingPathComponent("Dest")
        try FileManager.default.createDirectory(at: src, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: base) }
        return (src, dst)
    }
}
