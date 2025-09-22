import Foundation
@preconcurrency import Parsing

struct FixedWidthIntegerParserPrinter<T: FixedWidthInteger>: ParserPrinter {
	struct ParsingError: Error {}

	func parse(_ input: inout Data.SubSequence) throws -> T {
		let bytes = T.bitWidth / 8
		guard input.count >= bytes else {
			throw ParsingError()
		}
		let output = input.withUnsafeBytes { $0.load(as: T.self) }
		input.removeFirst(bytes)
		return output
	}

	func print(_ output: T, into input: inout Data.SubSequence) throws {
		input.insert(
			contentsOf: withUnsafeBytes(of: output.bigEndian) { Data($0) },
			at: 0
		)
	}
}
extension FixedWidthInteger {
	static var parserPrinter: FixedWidthIntegerParserPrinter<Self> {
		.init()
	}
}

struct StringParser: ParserPrinter {
	enum ParseError: Error {
		case decodeFailed
		case encodeFailed
	}
	
	func parse(_ input: inout Data) throws -> String {
		guard let output = String(data: input, encoding: .utf8) else {
			throw ParseError.decodeFailed
		}
		input.removeAll()
		return output
	}
	
	func print(_ output: String, into input: inout Data) throws {
		guard let data = output.data(using: .utf8) else {
			throw ParseError.decodeFailed
		}
		input = data + input
	}
}

/// A parser printer which first reads an integer of `Width` and then outputs a Data containing that many bytes.
struct VariableWidthData<Width: FixedWidthInteger>: ParserPrinter {
	enum ParseError: Error {
		case inputTooSmall
		case outputTooLarge
	}
	
	func parse(_ input: inout Data) throws -> Data {
		let width = Int(try Width.parserPrinter.parse(&input))
		guard input.count >= Width.max else {
			throw ParseError.inputTooSmall
		}
		let localData = input.prefix(width)
		input.removeFirst(width)
		return localData
	}
	
	func print(_ output: Data, into input: inout Data) throws {
		guard output.count <= Width.max else {
			throw ParseError.outputTooLarge
		}
		let width = withUnsafeBytes(of: Width(output.count).bigEndian) { Data($0) }
		input = width + output + input
	}
}

struct TransactionFieldParser: ParserPrinter {
	var body: some ParserPrinter<Data, TransactionField> {
		ParsePrint {
			UInt16.parserPrinter
			VariableWidthData<UInt16>()
		}.map(TransactionFieldConversion())
	}
}

public struct TransactionFieldConversion: Conversion {
	enum ConversionError: Error {
		case unknownType
	}
	
	let stringParser = StringParser()
	let intParser = Int.parserPrinter
	
	public func apply(_ input: (UInt16, Data)) throws -> TransactionField {
		var data = input.1
		return switch input.0 {
		case 100: .errorText(try stringParser.parse(&data))
		case 101: .data(try stringParser.parse(&data))
		case 102: .userName(try stringParser.parse(&data))
		case 103: .userID(try intParser.parse(&data))
		case 104: .userIconID(try intParser.parse(&data))
		case 105: .userLogin(try stringParser.parse(&data))
		case 106: .userPassword(try stringParser.parse(&data))
		case 107: .referenceNumber(try intParser.parse(&data))
		case 108: .transferSize(try intParser.parse(&data))
		case 109: .chatOptions(try intParser.parse(&data))
		case 110: .userAccess(try intParser.parse(&data))
		case 111: .userAlias(data)
		case 112: .userFlags(UserFlags(rawValue: try UInt16.parserPrinter.parse(&data)))
		case 113: .options(try intParser.parse(&data))
		case 114: .chatID(try intParser.parse(&data))
		case 115: .chatSubject(try stringParser.parse(&data))
		case 116: .waitingCount(try intParser.parse(&data))
		case 150: .serverAgreement(data)
		case 151: .serverBanner(data)
		case 152: .serverBannerType(BannerType(rawValue: try intParser.parse(&data))!)
		case 153: .serverBannerURL(try stringParser.parse(&data))
		case 154: .noServerAgreement(try intParser.parse(&data) != 0)
		case 160: .versionNumber(try intParser.parse(&data))
		case 161: .communityBannerID(try intParser.parse(&data))
		case 162: .serverName(try stringParser.parse(&data))
//		case 200: .fileNameWithInfo(try parseFileNameWithInfo(&data))
		case 201: .fileName(try stringParser.parse(&data))
		case 202: .filePath(data)
		case 204: .fileTransferOptions(try intParser.parse(&data))
		case 205: .fileTypeString(try stringParser.parse(&data))
		case 206: .fileCreatorString(try stringParser.parse(&data))
		case 207: .fileSize(try intParser.parse(&data))
//		case 208: .fileCreateDate(try parseHotlineDate(&data))
//		case 209: .fileModifyDate(try parseHotlineDate(&data))
		case 210: .fileComment(try stringParser.parse(&data))
		case 211: .fileNewName(try stringParser.parse(&data))
		case 213: .fileType(data)
		case 214: .quotingMessage(try stringParser.parse(&data))
		case 215: .automaticResponse(try stringParser.parse(&data))
		case 220: .folderItemCount(try intParser.parse(&data))
//		case 300: .userNameWithInfo(try parseUserNameWithInfo(&data))
		case 319: .newsCategoryGUID(data)
		case 320: .newsCategoryListDataOld(data)
		case 321: .newsArticleListData(data)
		case 322: .newsCategoryName(try stringParser.parse(&data))
		case 323: .newsCategoryListData(data)
		case 325: .newsPath(data)
		case 326: .newsArticleID(try intParser.parse(&data))
		case 327: .newsArticleDataFlavor(try stringParser.parse(&data))
		case 328: .newsArticleTitle(try stringParser.parse(&data))
		case 329: .newsArticlePoster(try stringParser.parse(&data))
//		case 330: .newsArticleDate(try parseHotlineDate(&data))
		case 331: .newsArticlePrevious(try intParser.parse(&data))
		case 332: .newsArticleNext(try intParser.parse(&data))
		case 333: .newsArticleData(data)
		case 334: .newsArticleFlags(try intParser.parse(&data))
		case 335: .newsArticleParentArticle(try intParser.parse(&data))
		case 336: .newsArticleFirstChildArticle(try intParser.parse(&data))
		case 337: .newsArticleRecursiveDelete(try intParser.parse(&data))
		default:
			throw ConversionError.unknownType
		}
	}
	
	public func unapply(_ output: TransactionField) throws -> (UInt16, Data) {
		return switch output {
		case .errorText(let string):
			(100, try stringParser.print(string))
		case .data(let string):
			(101, try stringParser.print(string))
		case .userName(let string):
		  (102, try stringParser.print(string))
		case .userID(let int):
			(103, try intParser.print(int))
		case .userIconID(let int):
			(104, try intParser.print(int))
		case .userLogin(let string):
			(105, try stringParser.print(string))
		case .userPassword(let string):
			(106, try stringParser.print(string))
		case .referenceNumber(let int):
			(107, try intParser.print(int))
		case .transferSize(let int):
			(108, try intParser.print(int))
		case .chatOptions(let int):
			(109, try intParser.print(int))
		case .userAccess(let int):
			(110, try intParser.print(int))
		case .userAlias(let data):
			(111, data)
//		case .userFlags(let flags):
//			(112, try uint16ToData(flags.rawValue))
		case .options(let int):
			(113, try intParser.print(int))
		case .chatID(let int):
			(114, try intParser.print(int))
		case .chatSubject(let string):
			(115, try stringParser.print(string))
		case .waitingCount(let int):
			(116, try intParser.print(int))
		case .serverAgreement(let data):
			(150, data)
		case .serverBanner(let data):
			(151, data)
		case .serverBannerType(let type):
			(152, try intParser.print(type.rawValue))
		case .serverBannerURL(let string):
			(153, try stringParser.print(string))
		case .noServerAgreement(let bool):
			(154, try intParser.print(bool ? 1 : 0))
		case .versionNumber(let int):
			(160, try intParser.print(int))
		case .communityBannerID(let int):
			(161, try intParser.print(int))
		case .serverName(let string):
			(162, try stringParser.print(string))
//		case .fileNameWithInfo(let info):
//			(200, try fileNameWithInfoToData(info))
		case .fileName(let string):
			(201, try stringParser.print(string))
		case .filePath(let data):
			(202, data)
		case .fileResumeData(let data):
			(203, data)
		case .fileTransferOptions(let int):
			(204, try intParser.print(int))
		case .fileTypeString(let string):
			(205, try stringParser.print(string))
		case .fileCreatorString(let string):
			(206, try stringParser.print(string))
		case .fileSize(let int):
			(207, try intParser.print(int))
//		case .fileCreateDate(let date):
//			(208, try hotlineDateToData(date))
//		case .fileModifyDate(let date):
//			(209, try hotlineDateToData(date))
		case .fileComment(let string):
			(210, try stringParser.print(string))
		case .fileNewName(let string):
			(211, try stringParser.print(string))
		case .fileNewPath(let data):
			(212, data)
		case .fileType(let data):
			(213, data)
		case .quotingMessage(let string):
			(214, try stringParser.print(string))
		case .automaticResponse(let string):
			(215, try stringParser.print(string))
		case .folderItemCount(let int):
			(220, try intParser.print(int))
//		case .userNameWithInfo(let info):
//			(300, try userNameWithInfoToData(info))
		case .newsCategoryGUID(let data):
			(319, data)
		case .newsCategoryListDataOld(let data):
			(320, data)
		case .newsArticleListData(let data):
			(321, data)
		case .newsCategoryName(let string):
			(322, try stringParser.print(string))
		case .newsCategoryListData(let data):
			(323, data)
		case .newsPath(let data):
			(325, data)
		case .newsArticleID(let int):
			(326, try intParser.print(int))
		case .newsArticleDataFlavor(let string):
			(327, try stringParser.print(string))
		case .newsArticleTitle(let string):
			(328, try stringParser.print(string))
		case .newsArticlePoster(let string):
			(329, try stringParser.print(string))
//		case .newsArticleDate(let date):
//			(330, try hotlineDateToData(date))
		case .newsArticlePrevious(let int):
			(331, try intParser.print(int))
		case .newsArticleNext(let int):
			(332, try intParser.print(int))
		case .newsArticleData(let data):
			(333, data)
		case .newsArticleFlags(let int):
			(334, try intParser.print(int))
		case .newsArticleParentArticle(let int):
			(335, try intParser.print(int))
		case .newsArticleFirstChildArticle(let int):
			(336, try intParser.print(int))
		case .newsArticleRecursiveDelete(let int):
			(337, try intParser.print(int))
		default:
			throw ConversionError.unknownType
		}
	}}
