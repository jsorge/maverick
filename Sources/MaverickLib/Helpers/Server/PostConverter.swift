//
//  PostConverter.swift
//  App
//
//  Created by Jared Sorge on 6/6/18.
//

import Foundation
import Micropub
import TextBundleify
import PathKit

struct PostConverter {
    static func saveMicropubPost(_ post: MicropubBlogPostRequest) throws -> String {
        let blogPost = makeWholeFileContents(fromMicropub: post)
        let postPath = PostPath.from(micropub: post)
        let mdPath = PathHelper.incomingPostPath + Path("\(postPath.asFilename).md")
        try PathHelper.prepTheTemporaryPaths()
        try mdPath.write(blogPost)

        var photoPath: Path? = nil
        if let image = post.photo {
            photoPath = PathHelper.incomingMediaPath + Path(image.filename)
            try photoPath!.write(image.data)
        }

        try TextBundleify.start(in: PathHelper.incomingPostPath, pathToAssets: PathHelper.incomingMediaPath)
        let incomingBundlePath = PathHelper.incomingPostPath + Path("\(postPath.asFilename).textbundle")
        let destinationBundlePath = PathHelper.postFolderPath + Path("\(postPath.asFilename).textbundle")
        try incomingBundlePath.move(destinationBundlePath)
        
        try FeedOutput.makeAllTheFeeds()
        try? photoPath?.delete()
        
        return postPath.asURIPath
    }
}

private func makeWholeFileContents(fromMicropub micropub: MicropubBlogPostRequest) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [
        .withYear,
        .withMonth,
        .withDay,
        .withDashSeparatorInDate,
        .withTime,
        .withSpaceBetweenDateAndTime,
        .withColonSeparatorInTime
    ]

    return """
    ---
    title: \(micropub.name ?? "")
    date: \(formatter.string(from: micropub.date))
    ---
    \(micropub.content)
    """
}

private extension PostPath {
    static func from(micropub post: MicropubBlogPostRequest) -> PostPath {
        let calendar = Calendar.current
        let date = post.date
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        var slug = [String]()
        for word in post.content.split(separator: " ") {
            guard slug.count < 6 else { break }
            var slugComponent = String(word).lowercased()
                .replacingOccurrences(of: "!", with: "")
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            if slugComponent.contains(".") {
                let exploded = slugComponent.split(separator: ".")
                slugComponent = String(exploded[0])
            }
            slug.append(slugComponent)
        }

        let path = PostPath(year: year, month: month, day: day, slug: slug.joined(separator: "-"))
        return path
    }
}
