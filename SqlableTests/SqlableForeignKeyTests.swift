//
//  SqlableForeignKeyTests.swift
//  Sqlable
//
//  Created by Ulrik Damm on 16/12/2015.
//  Copyright © 2015 Ufd.dk. All rights reserved.
//

import XCTest
@testable import Sqlable

struct Table1 {
	let id : Int?
	let table2id : Int?
}

struct Table2 {
	let id : Int?
	let table1id : Int?
}

extension Table1 : Sqlable {
	static let id = Column("id", .Integer, PrimaryKey(autoincrement: true))
	static let table2id = Column("table2id", .Nullable(.Integer), ForeignKey<Table2>(onDelete: .Cascade))
	static let tableLayout = [id, table2id]
	
	func valueForColumn(column : Column) -> SqlValue? {
		switch column {
		case Table1.id: return id
		case Table1.table2id: return table2id ?? Null()
		case _: return nil
		}
	}
	
	init(row : ReadRow<Table1>) throws {
		id = try row.get(Table1.id)
		table2id = try row.get(Table1.table2id)
	}
}

extension Table2 : Sqlable {
	static let id = Column("id", .Integer, PrimaryKey(autoincrement: true))
	static let table1id = Column("table1id", .Nullable(.Integer), ForeignKey<Table1>(onDelete: .SetNull))
	static let tableLayout = [id, table1id]
	
	func valueForColumn(column : Column) -> SqlValue? {
		switch column {
		case Table2.id: return id
		case Table2.table1id: return table1id ?? Null()
		case _: return nil
		}
	}
	
	init(row : ReadRow<Table2>) throws {
		id = try row.get(Table2.id)
		table1id = try row.get(Table2.table1id)
	}
}

class SqliteForeignKeyTests: XCTestCase {
	let path = documentsPath() + "/test.sqlite"
	var db : SqliteDatabase!
	
	override func setUp() {
		try! SqliteDatabase.deleteDatabase(at: path)
		db = try! SqliteDatabase(filepath: path)
		
		try! db.createTable(Table1.self)
		try! db.createTable(Table2.self)
	}
	
	func testCascadeDeletes() {
		try! Table2(id: 1, table1id: nil).insert().run(db)
		try! Table1(id: 1, table2id: 1).insert().run(db)
		
		XCTAssert(try! Table2.count().run(db) == 1)
		XCTAssert(try! Table1.count().run(db) == 1)
		
		try! Table2.delete(Table2.id == 1).run(db)
		
		XCTAssert(try! Table2.count().run(db) == 0)
		XCTAssert(try! Table1.count().run(db) == 0)
	}
	
	func testSetNullDeletes() {
		try! Table1(id: 1, table2id: nil).insert().run(db)
		try! Table2(id: 1, table1id: 1).insert().run(db)
		
		XCTAssert(try! Table2.count().run(db) == 1)
		XCTAssert(try! Table1.count().run(db) == 1)
		
		try! Table1.delete(Table1.id == 1).run(db)
		
		XCTAssert(try! Table2.count().run(db) == 1)
		XCTAssert(try! Table1.count().run(db) == 0)
		XCTAssert(try! Table2.read().run(db).first!.table1id == nil)
	}
}
