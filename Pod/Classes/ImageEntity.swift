//
//  ImageEntity.swift
//
//  This code was generated by AlecrimCoreData code generator tool.
//
//  Changes to this file may cause incorrect behavior and will be lost if
//  the code is regenerated.
//

import Foundation
import CoreData

import AlecrimCoreData

public class ImageEntity: NSManagedObject {

    @NSManaged public var creation_date: NSDate?
    @NSManaged public var height: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged public var id: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged public var modified_date: NSDate?
    @NSManaged public var slug: String?
    @NSManaged public var thumbnailHeight: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var thumbnailWidth: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var width: Int32 // cannot mark as optional because Objective-C compatibility issues

    @NSManaged public var posts: Set<BlogPostEntity>

}

// MARK: - AlecrimCoreData query attributes

extension ImageEntity {

    public static let creation_date = AlecrimCoreData.Attribute<NSDate?>("creation_date")
    public static let height = AlecrimCoreData.Attribute<Int32?>("height")
    public static let id = AlecrimCoreData.Attribute<Int32?>("id")
    public static let modified_date = AlecrimCoreData.Attribute<NSDate?>("modified_date")
    public static let slug = AlecrimCoreData.Attribute<String?>("slug")
    public static let thumbnailHeight = AlecrimCoreData.Attribute<Int32?>("thumbnailHeight")
    public static let thumbnailUrl = AlecrimCoreData.Attribute<String?>("thumbnailUrl")
    public static let thumbnailWidth = AlecrimCoreData.Attribute<Int32?>("thumbnailWidth")
    public static let title = AlecrimCoreData.Attribute<String?>("title")
    public static let url = AlecrimCoreData.Attribute<String?>("url")
    public static let width = AlecrimCoreData.Attribute<Int32?>("width")

    public static let posts = AlecrimCoreData.EntitySetAttribute<Set<BlogPostEntity>>("posts")

}

public class ImageEntityAttribute<T>: AlecrimCoreData.SingleEntityAttribute<T> {

    public override init(_ name: String) { super.init(name) }

    public lazy var creation_date: AlecrimCoreData.Attribute<NSDate?> = { AlecrimCoreData.Attribute<NSDate?>("\(self.___name).creation_date") }()
    public lazy var height: AlecrimCoreData.Attribute<Int32?> = { AlecrimCoreData.Attribute<Int32?>("\(self.___name).height") }()
    public lazy var id: AlecrimCoreData.Attribute<Int32?> = { AlecrimCoreData.Attribute<Int32?>("\(self.___name).id") }()
    public lazy var modified_date: AlecrimCoreData.Attribute<NSDate?> = { AlecrimCoreData.Attribute<NSDate?>("\(self.___name).modified_date") }()
    public lazy var slug: AlecrimCoreData.Attribute<String?> = { AlecrimCoreData.Attribute<String?>("\(self.___name).slug") }()
    public lazy var thumbnailHeight: AlecrimCoreData.Attribute<Int32?> = { AlecrimCoreData.Attribute<Int32?>("\(self.___name).thumbnailHeight") }()
    public lazy var thumbnailUrl: AlecrimCoreData.Attribute<String?> = { AlecrimCoreData.Attribute<String?>("\(self.___name).thumbnailUrl") }()
    public lazy var thumbnailWidth: AlecrimCoreData.Attribute<Int32?> = { AlecrimCoreData.Attribute<Int32?>("\(self.___name).thumbnailWidth") }()
    public lazy var title: AlecrimCoreData.Attribute<String?> = { AlecrimCoreData.Attribute<String?>("\(self.___name).title") }()
    public lazy var url: AlecrimCoreData.Attribute<String?> = { AlecrimCoreData.Attribute<String?>("\(self.___name).url") }()
    public lazy var width: AlecrimCoreData.Attribute<Int32?> = { AlecrimCoreData.Attribute<Int32?>("\(self.___name).width") }()

    public lazy var posts: AlecrimCoreData.EntitySetAttribute<Set<BlogPostEntity>> = { AlecrimCoreData.EntitySetAttribute<Set<BlogPostEntity>>("\(self.___name).posts") }()

}