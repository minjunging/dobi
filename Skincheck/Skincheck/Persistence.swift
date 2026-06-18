//
//  Persistence.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//
//  ⚠️ 이 파일은 초기 Xcode 템플릿에서 생성된 CoreData 파일입니다.
//  현재 프로젝트에서는 CoreData를 사용하지 않습니다.
//
//  향후 분석 히스토리 기능을 추가할 때 사용할 수 있습니다.
//  지금은 이 파일을 Xcode에서 삭제해도 됩니다.
//

import CoreData

/// CoreData Persistence Controller (현재 미사용)
/// 향후 분석 히스토리 저장 기능 추가 시 활용 가능
struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Skincheck")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // 에러 발생 시 처리
                // 현재는 CoreData를 사용하지 않으므로 에러가 발생해도 앱은 정상 동작
                print("⚠️ CoreData 로드 실패 (현재 미사용): \(error)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
