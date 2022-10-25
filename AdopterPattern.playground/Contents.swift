import UIKit


protocol DataStoreProtocol {
    func add()
    func delete()
}


class OwnServerDataStore: DataStoreProtocol {

    func add() {
        print("サーバーにデータを保存しました")
    }

    func delete() {
        print("サーバーからデータを削除しました")
    }
}

class FirebaseDataStore {

    func addToFirebase() {
        print("Firebaseにデータを保存しました")
    }

    func deleteFromFirebase() {
        print("Firebaseからデータを削除しました")
    }
}

class FirebaseDataStoreAdopter: DataStoreProtocol {

    private let firebaseDataStore = FirebaseDataStore()

    func add() {
        firebaseDataStore.addToFirebase()
    }

    func delete() {
        firebaseDataStore.deleteFromFirebase()
    }
}


class Client {

    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
    }

    func addData() {
        dataStore.add()
    }

    func deleteData() {
        dataStore.delete()
    }
}

let client = Client(dataStore: FirebaseDataStoreAdopter())
client.addData()
client.deleteData()

