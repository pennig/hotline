import Foundation

public struct Transaction: Sendable {
	let header: TransactionHeader
	let fields: [TransactionField]
}

public struct TransactionHeader: Sendable {
	let flags: UInt8
	let isReply: Bool
	let kind: TransactionKind
	let id: UInt32
	let errorCode: UInt32
	let totalSize: UInt32
	let dataSize: UInt32
}

public enum TransactionKind: UInt16, Sendable {
	case reply = 0
	case error = 100
	case getMessageBoard = 101
	case newMessage = 102
	case oldPostNews = 103
	case serverMessage = 104
	case sendChat = 105
	case chatMessage = 106
	case login = 107
	case sendInstantMessage = 108
	case showAgreement = 109
	case disconnectUser = 110
	case disconnectMessage = 111
	case inviteToNewChat = 112
	case inviteToChat = 113
	case rejectChatInvite = 114
	case joinChat = 115
	case leaveChat = 116
	case notifyChatOfUserChange = 117
	case notifyChatOfUserDelete = 118
	case notifyChatSubject = 119
	case setChatSubject = 120
	case agreed = 121
	case serverBanner = 122
	case getFileNameList = 200
	case downloadFile = 202
	case uploadFile = 203
	case deleteFile = 204
	case newFolder = 205
	case getFileInfo = 206
	case setFileInfo = 207
	case moveFile = 208
	case makeFileAlias = 209
	case downloadFolder = 210
	case downloadInfo = 211
	case downloadBanner = 212
	case uploadFolder = 213
	case getNewsFile = 294
	case postNews = 295
	case receiveNewsFile = 296
	case getUserNameList = 300
	case notifyOfUserChange = 301
	case notifyOfUserDelete = 302
	case getClientInfoText = 303
	case setClientUserInfo = 304
	case getAccounts = 348
	case updateUser = 349
	case newUser = 350
	case deleteUser = 351
	case getUser = 352
	case setUser = 353
	case userAccess = 354
	case userBroadcast = 355
	case getNewsCategoryNameList = 370
	case getNewsArticleNameList = 371
	case deleteNewsItem = 380
	case newNewsFolder = 381
	case newNewsCategory = 382
	case getNewsArticleData = 400
	case postNewsArticle = 410
	case deleteNewsArticle = 411
	case connectionKeepAlive = 500
}

public struct UserFlags: OptionSet, Sendable {
	public let rawValue: UInt16
	
	public init(rawValue: UInt16) {
		self.rawValue = rawValue
	}
	
	public static let none: UserFlags = []
	
	public static let isAway = UserFlags(rawValue: 1 << 0)
	public static let isAdmin = UserFlags(rawValue: 1 << 1)
	public static let refusesPrivateMessages = UserFlags(rawValue: 1 << 2)
	public static let automaticResponse = UserFlags(rawValue: 1 << 2)
}

public enum BannerType: Int, Sendable {
	case url = 1
	case jpeg = 3
	case gif = 4
	case bmp = 5
	case pict = 6
}

public struct FileNameWithInfo: Sendable {
	public let type: UInt32
	public let creator: UInt32
	public let fileSize: UInt32
	public let nameScript: UInt16
	public let nameSize: UInt16
	public let name: Data
}

public struct UserNameWithInfo: Sendable {
	public let userID: UInt16
	public let iconID: UInt16
	public let userFlags: UserFlags
	public let nameSize: UInt16
	public let name: Data
}

public struct HotlineDate: Sendable {
	public let year: UInt16
	public let milliseconds: UInt16
	public let seconds: UInt32
}

public enum TransactionField: Sendable {
	case errorText(String)
	case data(String)
	case userName(String)
	case userID(Int)
	case userIconID(Int)
	case userLogin(String) // encoded
	case userPassword(String) // encoded
	case referenceNumber(Int)
	case transferSize(Int)
	case chatOptions(Int)
	case userAccess(Int)
	case userAlias(Data)
	case userFlags(UserFlags)
	case options(Int)
	case chatID(Int)
	case chatSubject(String)
	case waitingCount(Int)
	case serverAgreement(Data)
	case serverBanner(Data)
	case serverBannerType(BannerType)
	case serverBannerURL(String)
	case noServerAgreement(Bool)
	case versionNumber(Int)
	case communityBannerID(Int)
	case serverName(String)
	case fileNameWithInfo(FileNameWithInfo)
	case fileName(String)
	case filePath(Data) // TODO: FilePath
	case fileResumeData(Data) // TODO: FileResumeData
	case fileTransferOptions(Int)
	case fileTypeString(String)
	case fileCreatorString(String)
	case fileSize(Int)
	case fileCreateDate(HotlineDate)
	case fileModifyDate(HotlineDate)
	case fileComment(String)
	case fileNewName(String)
	case fileNewPath(Data) // TODO: FilePath
	case fileType(Data) // Is this just .fileTypeString?
	case quotingMessage(String)
	case automaticResponse(String)
	case folderItemCount(Int)
	case userNameWithInfo(UserNameWithInfo)
	case newsCategoryGUID(Data)
	case newsCategoryListDataOld(Data) // Unused? (client/server < 1.5)
	case newsArticleListData(Data) // TODO: NewsArticleListData
	case newsCategoryName(String)
	case newsCategoryListData(Data) // TODO: NewsArticleListData
	case newsPath(Data)
	case newsArticleID(Int)
	case newsArticleDataFlavor(String)
	case newsArticleTitle(String)
	case newsArticlePoster(String)
	case newsArticleDate(HotlineDate)
	case newsArticlePrevious(Int)
	case newsArticleNext(Int)
	case newsArticleData(Data)
	case newsArticleFlags(Int)
	case newsArticleParentArticle(Int)
	case newsArticleFirstChildArticle(Int)
	case newsArticleRecursiveDelete(Int)
}
