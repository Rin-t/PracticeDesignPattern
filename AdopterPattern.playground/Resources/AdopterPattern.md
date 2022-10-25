# Adopter Pattern
# 目的
--
GoFのデザインパターン本には以下のように書かれている。

 > あるインターフェースをクライアントが求める他のインターフェースへ変換する。
 > Adopterパターンは、インターフェースに互換性のないクラス同士を組み合わせることができるようにする。

 <br/>

# つまりどういうこと？
 イメージはコンセント。国内用のスマホ充電器を国内で使うときはコンセントにそのまま挿せる。

 __スマホ - 国内充電器 - 国内コンセント__

<br/>

 しかし、国内用のスマホ充電器をそのまま海外のコンセントにはさせないので、間に**アダプター**を挟む。

 __スマホ - 国内充電器 - アダプター - 海外コンセント__

 <br/>

 このように**充電器**と**コンセント**規格が合うように間に入ってうまい具合につながるようにしてくれるのが**アダプター**の役割。

 ソフトウェア開発においてもこれと同じ。2つの異なるクラスA、B間において、AもBも修正することなくつなげるようにするのがAdopterパターン。

 ラッパーパターンとも呼ばれる。

# 具体的な使用例
こんな感じで使えるんではないかという個人的に考えたものなので、ツッコミどころ満載かもしれません。なんか違うんじゃないというところがあれば、ぜひ教えていただければ幸いです。

## シチュエーション

以下のようなシチュエーションがあったとします

- 自前のサーバーを持っており、モバイル側では自前のサーバーからデータを取得していた
- しかし、理由があって自前のサーバーでの運用を辞め、サーバーサイドはFirebaseを使うことになった

<br/>

## 自前のサーバーを使用しているときの実装



- サーバーと直接やりとりするクラス

```
protocol DataStoreProtocol {
    func add()
    func delete()
}


final class OwnServerDataStore: DataStoreProtocol {

    func add() {
        print("サーバーにデータを保存しました")
    }

    func delete() {
        print("サーバーからデータを削除しました")
    }
}
```

<br/>

- サーバーとやりとりする処理を呼び出すクラス

```
final class Client {

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
```
<br/>

- 処理の実行

```
let client = Client(dataStore: OwnServerDataStore())
client.addData()        // サーバーにデータを保存しました
client.deleteData()     // サーバーからデータを削除しました
```

<br/>

## Firebaseに乗り換えるときに困ること

さて、上記で紹介した自前サーバーとやりとりしていたものを、Firebaseに繋ぎかえます。

Firebaseではサーバーとの通信に以下のようなクラスが用意されているとします。

<br/>

- Firebase側で用意されている、サーバーと直接やりとりするクラス

```
final class FirebaseDataStore {

    func addToFirebase() {
        print("Firebaseにデータを保存しました")
    }

    func deleteFromFirebase() {
        print("Firebaseからデータを削除しました")
    }
}
```

<br/>

- 下のコードみたいなノリで使えたら楽なのに...

```
let client = Client(dataStore: OwnServerDataStore())
client.addData()        // Firebaseにデータを保存しました
client.deleteData()     // Firebaseからデータを削除しました
```
当然このコードはエラーが出て使えません。なぜなら__FirebaseDataStore__は__DataStoreProtocol__を準拠していないからですね。

はい。ここでの課題は
### 既に実装済みのClientクラスに直接Firebaseの通信クラスを渡せないこと

<br/>

## この問題はどのように解決できるのか
まず先に思いつきそうな、２つの解決方法は以下の通りかと思います。

### ①FirebaseDataStoreクラスに__DataStoreProtocol__を準拠させる
### ②ClientクラスでFirebaseDataStoreクラスを受け取れるように修正

２つの解決できそうな方法を出しましたが、これにも問題があります。

<br/>

### ①FirebaseDataStoreクラスにDataStoreProtocolを準拠させる方法の問題点
--

- ライブラリの中での実装で直接クラスを修正することができない
- 仮にライブラリでなかったとしても誰かが実装して、テストまで完了していて修正を加えたくない

<br/>

### ②ClientクラスでFirebaseDataStoreクラスを受け取れるように修正する問題点

--

- Clientクラスの修正をすることで影響範囲が大きくなってしまう可能性がある
- これも①と同様テスト済みなどでクラスに修正を加えたくない

以上のような理由でFirebaseDataStore、Clientの両クラスに変更を加えられない、加えたくないという事情があることがあります。
このようなときに役立つのが__AdopterPattern__です。

<br/>

## AdopterPatternを使った実装

以下のようにAdopterクラスを作ります。

```
final class FirebaseDataStoreAdopter: DataStoreProtocol {

    private let firebaseDataStore = FirebaseDataStore()

    func add() {
        firebaseDataStore.addToFirebase()
    }

    func delete() {
        firebaseDataStore.deleteFromFirebase()
    }
}
```
このクラスでは、以下の2つのことをしています。

- Clientクラスに必要な__DataStoreProtocol__に準拠する
- FirebaseDataStoreとprotocolのメソッドを結びつける

このようにすることで、FirebaseDataStoreAdopterをClientクラスで使えるようになり、大元のFirebaseDataStoreの処理を呼び出すことができます。

```
let client = Client(dataStore: FirebaseDataStoreAdopter())
client.addData()       // Firebaseにデータを保存しました
client.deleteData()    // Firebaseからデータを削除しました
```

コンセントのときと同様にちょうど２つのクラスを結びつけるアダプターのような働きをしていますね。


