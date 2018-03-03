import UIKit
import XCTest
import VCHTTPConnect
import ObjectMapper

class TestEntityModel: VCEntityModel {
    var name: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.name <- map["name"]
    }
}

class VCDatabaseTests: XCTestCase {
    var database: VCDatabase = VCDatabase(name: "testDatabate")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Clears the database
        database.clear()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func generateTestEntities() -> [TestEntityModel] {
        var models: [TestEntityModel] = []
        
        for index in 0...99 {
            models.append(TestEntityModel(JSON: ["id":String(describing: index), "name": ("test" + String(describing: index))])!)
        }
        
        return models
    }
    
    // MARK: - INSERT
    
    func testInsert() {
        XCTAssertTrue(database.select().count == 0)
        
        database.insert(model: TestEntityModel(JSON: ["id":"x"])!)
        
        XCTAssertTrue(database.select().count == 1)
        
        database.insert(model: TestEntityModel(JSON: ["id":"y"])!)
        
        XCTAssertTrue(database.select().count == 2)
    }
    
    func testBatchInsert() {
        let models: [VCEntityModel] = self.generateTestEntities()

        XCTAssertTrue(database.select().count == 0)
        
        database.batchInsert(models:models)
        
        XCTAssertTrue(database.select().count == 100)
    }
    
    // MARK: - UPDATE
    
    func testUpdate() {
        let testModel: TestEntityModel = TestEntityModel(JSON: ["id":"x", "name":"test"])!
        
        XCTAssertNil(database.select(modelId: "x"))
        
        database.update(model: testModel)
        
        XCTAssertNil(database.select(modelId: "x"))
        
        database.insert(model: testModel)
        
        XCTAssertNotNil(database.select(modelId: "x"))
        
        XCTAssertTrue((database.select(modelId: "x") as! TestEntityModel).name == "test")
        
        testModel.name = "otherName"
        database.update(model: testModel)
        
        XCTAssertTrue((database.select(modelId: "x") as! TestEntityModel).name == "otherName")
    }
    
    func testBatchUpdate() {
        func id(index: Int) -> String {
            return String(describing: index)
        }
        let testModels: [TestEntityModel] = self.generateTestEntities()
        
        XCTAssertTrue(database.select().count == 0)
        
        database.batchInsert(models: testModels)
        
        for (index, model) in database.select().enumerated() {
            XCTAssertTrue((model as! TestEntityModel).name == "test" + id(index: index))
        }
        
        for model in testModels {
            model.name = "otherName"
        }
        
        database.batchUpdate(models: testModels)
        
        for model in database.select() {
            XCTAssertTrue((model as! TestEntityModel).name == "otherName")
        }
    }

    // MARK: - SELECT
    
    func testSelect() {
        let models: [VCEntityModel] = self.generateTestEntities()
        
        XCTAssertTrue(database.select().count == 0)
        
        database.batchInsert(models:models)
        
        XCTAssertTrue(database.select().count == 100)
        
        XCTAssertNotNil(database.select(filter: {model in return model.modelId == "0"}))
        
        XCTAssertNotNil(database.select(modelId: "0"))
        
    }
    
    // MARK: - REPLACE
    
    func testReplace() {
        let models: [VCEntityModel] = self.generateTestEntities()
        
        XCTAssertTrue(database.select().count == 0)
        
        database.batchInsert(models:models)
        
        XCTAssertTrue(database.select().count == 100)
        
        database.replace(models: [], condition: {model in
            return Int(model.modelId!)! % 2 == 0
            
        })
        
        XCTAssertTrue(database.select().count == 50)
        
        database.replace(models: [])
        
        XCTAssertTrue(database.select().count == 0)
    }
    
    // MARK: - CLEAR
    
    func testClear() {
        let models: [VCEntityModel] = self.generateTestEntities()
        
        XCTAssertTrue(database.select().count == 0)
        
        database.batchInsert(models:models)
        
        XCTAssertTrue(database.select().count == 100)
        
        database.clear()
        
        XCTAssertTrue(database.select().count == 0)
    }
}
