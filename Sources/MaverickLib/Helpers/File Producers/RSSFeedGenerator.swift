//
//  RSSFeedGenerator.swift
//  App
//
//  Created by Jared Sorge on 6/3/18.
//

import Foundation
import SwiftMarkdown

struct RSSFeedGenerator: FeedGenerator {
    static func makeFeed(from posts: [Post], for site: SiteConfig, goingTo type: TextOutputType) throws -> String {
        var feed = """
        <rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" version="2.0" xmlns:media="http://search.yahoo.com/mrss/"><channel>
        """
        
        feed += makeRSSHeaderText(from: site, goingTo: type)
        posts.forEach({ feed += makeFeedItem(from: $0, for: site) ?? "" })
        
        feed += "\n</channel>\n</rss>"
        
        return feed
    }
    
    static func outputFileName(forType type: TextOutputType) -> String {
        switch type {
        case .fullText:
            return "rss"
        case .microblog:
            return "microblog-rss"
        }
    }
}

private func makeRSSHeaderText(from site: SiteConfig, goingTo type: TextOutputType) -> String {
    let feedLink = site.url.appendingPathComponent(RSSFeedGenerator.outputFileName(forType: type))
    let date = "Sun, 03 Jun 2018 21:19:23 GMT"
    
    return """
    <title><![CDATA[\(site.title)]]></title>
    <description><![CDATA[\(site.description)]]></description>
    <link>\(site.url)</link>
    <image><url>\(site.url)/favicon.png</url><title>\(site.title)</title><link>\(site.url)</link></image>
    <generator>\(Constants.App.fullVersion)</generator>
    <lastbuilddate>\(date)</lastbuilddate>
    <atom:link href="\(feedLink)" rel="self" type="application/rss+xml" />
    <ttl>60</ttl>
    """
}

private func makeFeedItem(from post: Post, for site: SiteConfig) -> String? {
    let title: String
    if let postTitle = post.title {
        title = "<title><![CDATA[\(postTitle)]]></title>"
    }
    else {
        title = ""
    }
    
    return """
    <item>
    \(title)
    <link>\(site.url)\(post.path!.asURIPath)</link>
    <guid ispermalink="false">\(post.path!.asURIPath.asBase64)</guid>
    <pubdate>\(post.formattedDate)</pubdate>
    <content:encoded><![CDATA[\(post.content)]]></content:encoded>
    </item>
    """
}

private extension String {
    var asBase64: String {
        let data = self.data(using: .utf8)!
        return data.base64EncodedString()
    }
}
