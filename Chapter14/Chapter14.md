# Chapter 14: In Practice: Project "News"



- 이번 챕터에서는, operator에 대한 지식과 함께 Foundation의 일부와 결합해서 사용해보도록 하겠습니다.
- 이번 챕터에서 사용할 "Hacker News" API는 컴퓨터와 사업가의 정신의 내용을 담고 있는 소셜 뉴스 웹사이트 입니다.
- 직접 웹사이트에 들어가보면 아래와 같은 내용을 가지고 있습니다.

<img width="687" alt="스크린샷 2020-11-01 오후 9 48 41" src="https://user-images.githubusercontent.com/48345308/97803220-03390600-1c8c-11eb-9159-4b7921e36a67.png">

- SwiftUI의 기본적인 것을 배우고 Combine 코드와 함께 새로운 declarative한 Apple의 프레임워크를 사용하여 놀랍고도 반응형 어플리케이션 UI를 구축하는 방법에 대해서 알아보도록 하겠습니다!



### Getting started with the Hacker News API

![스크린샷 2020-11-01 오후 9 51 33](https://user-images.githubusercontent.com/48345308/97803273-6a56ba80-1c8c-11eb-8c3d-682105b160cd.png)

- API 타입에는 2가지의 type을 가지고 있습니다.

  1) *Error* 라고 불리는 enum 타입은 API에서 두 개 custom 에러 타입을 지정하여 서버에 연결할 수 없거나 서버의 응답을 decode할 수 없을 때 API는 에러를 던집니다.

  2) *EndPoint* 라고 불리는 enum 타입은 두 API의 끝점의 URL을 연결하는 타입입니다.

```Swift
var maxStories = 10
```

- 그리고 *maxStories* 프로퍼티는 API 클라이언트가 가져올 최신 스토리의 수를 제한하여, Hacker news 서버의 로드를 줄일 수 있으며, JSON 데이터를 디코딩하데 사용하는데 필요한 decoder를 줄일 수 있습니다.

![스크린샷 2020-11-01 오후 10 18 20](https://user-images.githubusercontent.com/48345308/97803977-28c80e80-1c90-11eb-893a-8dc0e32411e0.png)

- 그리고 *Story* 구조체에는 story data를 decode하는 파일입니다.
- Hacker News API는 무료로 사용할 수 있으며 개발자 계정이 필요 없습니다.(Public API입니다.)



### Getting a single story

- 첫 번째 작업은 올바른 endpoint URL을 얻기 위해 Endpoint type을 사용하여 서버에 접속하고 스토리에 대한 데이터를 가져오는 방법을 API에 추가하는 것입니다.
- 새로운 메소드는 API consumer가 subscribe할 publisher를 알려주고 유효한 story나 실패중 하나를 전달 받습니다.

```Swift
func story(id: Int) -> AnyPublisher<Story, Error> {
		return Empty().eraseToAnyPublisher()
}
```

- 플레이그라운드의 컴파일 오류를 막기 위해서는 완료되는 즉시 빈 publisher를 리턴합니다. method body를 완성하고 expression을 추가하고 나서 나중에 대체하도록 하겠습니다.
- 언급했듯이, publisher의 결과는 *Story* 이고 실패하면 *API.ErrorType* 입니다. 나중에 보게 되겠지만, 네트워크 오류나 다른 오류가 발생했을 경우, 이것들을 API중 하나로 변환해야 합니다.
- subscirtipon을 모델링 하기 위하여 Hacker News API의 endpoint에 네트워크 요청을 생성하도록 하겠습니다.

```Swift
URLSession.shared.dataTaskPublisher(for: EndPoint.story(id).url)
```

- `URLSession.shared.dataTask(with: url)` 을 사용해봤었는데 `URLSession.shared.dataTaskPublisher(for:)` 은 처음이라 찾아보니 URLSession 데이터 작업을 래핑하는 *publisher* 를 리턴하는 메소드라고 합니다.
- 위의 코드를 통해 *EndPoint.story(id).url* 에게 요청을 시작했습니다. *url* 프로퍼티의 endpoint는 요청을 보낼 HTTP URL을 포함하고 있습니다. (https://hacker-news.firebaseio.com/v0/item/ 12345.json과 같은 형태를 띄게 될 것입니다.)
- 그 다음으로는, background thread를 사용하여 JSON을 파싱하고, 나머지는 앱의 반응성을 유지하기 위해서 새로운 custom dispatch queue를 생성해 보겠습니다.
- **앱의 반응성(?)!**

```Swift
private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
```

- 이 큐를 이용해서 JSON 응답을 처리하므로 네트워크 subscription에서 이 큐로 바꿉니다.

```Swift
.receive(on: apiQueue)
```

- 백그라운드 큐로 바뀌고 난 후에는, 응답에서 JSON 데이터를 가져오는 것이 필요합니다.
- *dataTaskPublisher(for:)* publisher는 (Data, URLResponse) 타입의 리턴값을 튜플로 반환하지만 subscription은 데이터만 필요합니다. 그렇기 때문에 결과값을 데이터만 가져올 수 있도록 *map* 메서드를 사용합니다.

```Swift
.map(\.data)
```

- 따라서 이 operator의 리턴 타입은 Data이고 decode 연산자에게 이것을 전달하고 응답을 Story로 변환할 수 있게 되었습니다.

```Swift
.decode(type: Story.self, decoder: decoder)
```

- 유효한 story JSON이 반환되지 않는 경우에는 decode는 Error를 던지고 publisher는 이것을 다룰 것입니다. Error를 다루는 것에 대해서는 챕터 16장에서 더 자세히 배워 볼 예정입니다.
- 현재 *story(id:)* 메서드는 빈 publisher를 리턴합니다. 이것은 *catch* operator를 사용하여 쉽게 사용할 수 있습니다.

```Swift
.catch { _ in Empty<Story, Error>() }
```

- 던져지는 오류를 무시하고 Empty()를 리턴합니다. 이것은 출력 값을 방출하지 않고 즉시 완료하는 publisher 입니다.

<img width="363" alt="스크린샷 2020-11-01 오후 11 13 36" src="https://user-images.githubusercontent.com/48345308/97805183-df7bbd00-1c97-11eb-8871-7aa856506923.png">

- upstream error는 *catch(_)* 를 통해서 다룰 수가 있습니다.

  1) Story 값을 받으면 값을 방출하고 완성합니다.

  2) 오류가 발생한 경우 값을 내보내지 않고 빈 publisher를 리턴합니다.

- 다음으로 메서드 코드를 깔끔하고 디자인된 publisher를 리턴하도록 감싸기 위해서 현재 subscription의 마지막에 현재 subscription을 대체해야 합니다.

![스크린샷 2020-11-01 오후 11 17 31](https://user-images.githubusercontent.com/48345308/97805271-6cbf1180-1c98-11eb-880f-6fb3b907b086.png)

- 위의 코드는 컴파일은 되지만, 이 메서드는 아직 어떤 결과도 만들어내지 못합니다. 
- 이제 API를 인스턴스화하고 Hacker News server를 호출합니다.

```Swift
let api = API()
var subscriptions = [AnyCancellable]()

api.story(id: 1000)
	.sink(receiveCompletion: { print($0) }, receiveValue: { print($0 )})
	.store(in: &subscriptions)
```

- *api.story(id: 1000)* 을 호출하는 새로운 publisher를 만들고 출력 값이나 완료 이벤트를 프린트하는 *sink* 를 통해 subscribe 합니다.
- 작업이 완료될때까지 subscription을 유지하기 위해서 subscriptions에 저장합니다.

<img width="600" alt="스크린샷 2020-11-02 오후 1 28 40" src="https://user-images.githubusercontent.com/48345308/97830118-530ce100-1d0f-11eb-852e-6af10e7246c1.png">



- 서버로부터 반환된 JSON 데이터는 다음과 같은 구조체 형태를 띕니다.

```Swift
{
	"by":"python_kiss",
	"descendants":0,
	"id":1000,
	"score":4,
	"time":1172394646,
	"title":"How Important is the .com TLD?", "type":"story", 		  "url":"http://www.netbusinessblog.com/2007/02/19/how-important-is-the-dot-com/"
}
```

- *Codable*프로토콜은 준수하는 Story는 위의 값들을 저장하고 있습니다.
- 첫 번째 API 타입 메서드가 완성되었고, 이제 네트워크 호출, JSON decoding과 같은 개념을 연습해보았습니다.





### Multiple stories via merging publishers

- 여러 story들을 동시에 가져오기 위해 custom publisher를 만들어 지금까지 학습한 개념들을 몇가지 더 다루어보도록 하겠습니다.
- 새로운 메서드인 *mergedStories(ids:)* 는 주이진 story id 각각에 대한 story publisher를 얻고 이를 모두 합칠 것 입니다.

```Swift
func mergedStories(ids storyIDS: [Int]) -> AnyPublisher<Story, Error> {
		
}
```

- 이 메서드가 기본적으로 해야 할 일은 주어진 ID 각각에 대해 *story(id:)* 를 호출하고 그 결과의 출력 값을 단일 stream으로 flatten 하는 것입니다.
- 먼저, 네트워크 호출  수를 줄이려면 목록에서 첫 번째 *maxStories id*  만 가져옵니다.

```Swift
let storyIDs = Array(storyIDs.prefix(maxStories))

// 조건을 만족하지 못하면 다음 플로우가 실행되지 않습니다.
precondition(!storyIDs.isEmpty)
		
let initialPublisher = story(id: storyIDs[0])
let remainder = Array(storyIDs.dropFirst())
```

- *story(id:)* 를 사용하여 리스트의 첫 번째 ID로 스토리를 가져오는 *initialPublisher* publisher를 만들었습니다.
- 그리고, *reduce(_:_:)* 를 사용하여 각 다은 story publisher를 다음과 같이 initialPublisher로 합칠 것 입니다.

```Swift
return remainder.reduce(initialPublisher) { (combined, id) -> Result in

}
```

- *reduce()* 는 initial publisher에서 시작하여 나머지 매열의 각 ID를 처리할 클로저를 제공합니다.

<img width="465" alt="스크린샷 2020-11-02 오전 9 44 21" src="https://user-images.githubusercontent.com/48345308/97820130-fd750c00-1cef-11eb-9e44-caad756d47e6.png">

- 최종 결과는 각 publisher가 성공적으로 가져온 story를 내보내고 각각의 publisher가 부딪치는 오류들을 무시하게 됩니다.



<img width="640" alt="스크린샷 2020-11-02 오전 9 48 07" src="https://user-images.githubusercontent.com/48345308/97820232-8429e900-1cf0-11eb-8509-3333b1d91df7.png">

- 이제 코드를 실행하면 위에 같이 통신이 잘 되고 있는 것을 볼 수 있습니다.
- 위의 예시를 토애서 여러개의 publisher를 하나의 것으로 축소하는 메소드를 작성해보았습니다. *merge* operator의 경우 최대 8개까지 publisher를 합칠 수 있으므로 굉장히 유용합니다. 그러나 얼마나 많은 publisher가 필요한지 모르는 상황도 종종 존재합니다.



### Getting the latest stories

- 이번에는 최신 story 리스트를 가져오기 위해 multiple story method를 재사용할 것 입니다.

```Swift
func stories() -> AnyPublisher<[Story], Error> {
	return Empty().eraseToAnyPublisher()
}
```

- 이전과 같이 컴파일 오류를 방지하기 위해 *Empty* 객체를 리턴하도록 하겠습니다.
- 하지만 이전과는 다르게, publisher의 반환은 story의 배열 입니다.
- 서버에서 응답이 오는 경우 각 중간 상태에서 여러 개의 스토리를 가져와 배열에 넣도록 publisher를 디자인하도록 하겠습니다.
- 이 동작은 다음 챕터에서 이 새로운 publisher를 List UI Control에서 직접 바인딩할 수 있게 하며, 이것은 서버로부터 들어오는 story에 자동으로 업데이트 됩니다.



- 서버에서 오는 JSON 응답은 아래와 같은 형태를 띄기 때문에 아래와 같이 리스트의 정수 배열을 파싱하고 성공하면 ID를 사용하여 일치하는 story를 가져올 수 있습니다.

```Swift
// [1000, 1001, 1002, 1003]

.decode(type: [Int].self, decoder: decoder)
```



- 이번에는 오류 처리에 관한 내용으로 가보겠습니다. 하나의 story로 받아올 때, 우리는 error를 무시했습니다. 그러나 *stories()* 는 여기서 조금 더 해보도록 하겠습니다.
- *API.Error* 는 *stories()* 에서 발생하는 오류를 제한하는 오류 타입입니다. 열거형 케이스로 정의된 두 가지 오류가 있습니다.

<img width="675" alt="스크린샷 2020-11-02 오전 10 00 49" src="https://user-images.githubusercontent.com/48345308/97820622-49c14b80-1cf2-11eb-9a4e-30253eae559a.png">

1) *invalidResponse* : 서버의 응답이 디코딩할 수 없는 경우

2) *addressUnreachable(URL)* : URL의 endpoint에 도달하지 못하는 경우

- 우리의 *stories()* subscription code는 두 가지 타입의 에러를 던집니다.

  1) *dataTaskPublisher(for:)* : 네트워크 문제가 발생했을때 다양한 종류의 URLError를 던집니다,

  2) *decode(type:decoder:)* : JSON이 예상되는 타입과 맞지 않는 경우에 decoding error를 던집니다.

- 우리의 다음 작업은 이러한 오류를 반환된 publisher의 예상 오류와 일치하는 오류 타입으로 단일 API.Error를 매핑하는 것입니다.

```Swift
.mapError { (error) -> API.Error in
	switch error {
		case is URLError:
			return Error.addressUnreachable(EndPoint.stories.url)
		default:
			return Error.invalidResponse
	}
}
```

- *mapError* 는 업스트림에서 발생하는 모든 오류를 처리하며 이를 단일 오류 타입으로 매핑합니다. 이는 ouput 타입을 변경하는데 map을 사용했던 방식과 유사합니다.

  1) *error* 타입은 URLError 이므로 stories의 server endpoint에 도달하려고 시도하는 동안에 발생하며 이것은 *.addressUnreachable(_)* 을  반환합니다.

  2) *.invalidResponse* 의 경우는 다른 오류들이 발생했을 경우에 발생합니다. 만약에 성공적으로 가져온다면 네트워크 응답은 JSON 데이터를 디코딩할 것입니다.

- 위의 에러 타입을 통해서 *stories()* 에 예상되는 오류 타입을 일치시키기고 API consumer에게 맡겨 다운스트림 오류를 처리할 수 있게 해줍니다.

- 지금까지 현재 subscription은 JSON API에서 리스트를 가져오지만 그 외에 것은 아직 하지 않고 있습니다.
- 그 다음으로는, 원하는 내용을 필터링하고 id 목록을 실제 story에 매핑하기 위해 몇 개의 operator를 사용해보도록 하겠습니다.



```Swift
.filter { !$0.isEmpty }
```

- 이것은 다운스트림 operator가 적어도 하나의 요소가 있는 story id의 리스트를 받도록 보장하기 위함입니다.

```Swift
.flatMap { (storyIDs) in
	return self.mergedStories(ids: storyIDs)
}
```

- *mergedStories(ids:)* 를 사용하고 스토리 세부 정보를 가져오기 위하여 *flatMap* operator를 추가하여 모든 스토리 publisher를 평평하게 만들었습니다.
- 모든 publisher를 하나의 downstream으로 통합하면 story의 값들이 연속적인 stream으로 만들어지며 이것들은 네트워크에서 가져오는 순간 즉시 방출합니다.

![스크린샷 2020-11-02 오전 10 22 22](https://user-images.githubusercontent.com/48345308/97821312-4da29d00-1cf5-11eb-88c0-b0eb8f17997e.png)



- 현재 subscription을 그대로 둘 수 있지만 API를 List UI control에 쉽게 바인딩 할 수 있도록 디자인하겠습니다.
- 이것을 통해 counsumer가 *stories()* 를 간단하게 subscribe하고 그 결과를 UIKit에서는 자신의 viewcontrollers나 SwiftUI의 view에 [Story] 프로퍼티를 쉽게 할당할 수 있게 해줍니다.
- 그러기 위해서, 반환된 Story의 값들을 집계하고 subscription을 단일 스토리 값이 아닌 계족 증가하는 배열을 반환하도록 매핑해야 합니다. 이떄 중요한 연산자가 `scan` 입니다!

```Swift
.scan([]) { stories, story -> [Story] in
	return stories + [story]
}
```

- *scan()* 을 빈 배열로 내보내면 새로운 story가 나올 때 마다 stories 배열에 [Story] 를 통해 집계된 결과에 추가하는 형태를 띄고 있습니다. 이를 통해 작업중인 batch에서 새 스토리를 가져올 때마다 추가하도록 제공합니다.

![스크린샷 2020-11-02 오전 10 29 01](https://user-images.githubusercontent.com/48345308/97821561-3adc9800-1cf6-11eb-95fd-31fd63ff961c.png)



- 마지막으로, output을 내보내기 전에 story를 분류하는 것이 좋습니다. story가 *Comparable* 을 준수하므로 사용자가 이를 custom하게 구현할 필요는 없습니다.

```Swift
extension Story: Comparable {
	public static func < (lhs: Story, rhs: Story) -> Bool {
		return lhs.time > rhs.time
	}
}
```

```Swift
.map { $0.sorted() }
```



<img width="400" alt="스크린샷 2020-11-02 오전 10 32 37" src="https://user-images.githubusercontent.com/48345308/97821704-bc342a80-1cf6-11eb-91cd-36660f1f2729.png">

- 이 코드는 *api.stories()* 에 subscribe 하고 반환된 출력 및 완료 이벤트를 프린트하고 있습니다.
- 플레이 그라운드를 다시 실행하면, Hacker News story의 최신을 볼 수 있습니다.

- Hacker News 웬 사이트는 라이브 데이터를 가져오므로 몇 분마다 더 많은 story가 추가되므로 콘솔의 내용은 달라지게 됩니다.



### Challenge

- 여기에선는 완선된 API 클라이언트를 사용하여 테이블 뷰에 최신 story를 표시하는 iOS 앱을 구축해보는것입니다.

<img width="488" alt="스크린샷 2020-11-02 오후 1 47 35" src="https://user-images.githubusercontent.com/48345308/97830944-f8c14f80-1d11-11eb-88de-a1698fdf2312.png">

