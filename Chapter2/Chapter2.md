# Chpater 2: Publisher & Subscribers



- 지난 챕터에서 Combine의 기본적인 개념에 배웠다면 이번에는 Combine의 핵심 요소를 직접 실행해 보며 배워보겠습니다.



### Getting started

- 이번 챕터에서는 먼저 Combine을 사용하기 위해 import를 합니다.

```Swift
var subscriptions = Set<AnyCancellable>()

public func example(of description: String, action: () -> Void) {
	print("\n --- Example of:", description, "---")
	action()
}
```

- 이 책 전체에서 사용할 몇 가지 예를 캡슐화할 때 이 함수를 사용하게 될 것입니다.



### Hello Publisher

- Combine의 핵심은 *Publisher* 프로토콜입니다. 이 프로토콜은 하나 이상의 *subscriber* 에게 시간 경과에 따라 일련의 값을 전송할 수 있는 타입에 대한 요건을 정의합니다.
- 다른 말로, publisher는 관심 있는 값을 포함하는 사건을 알려주는 것입니다.
- UIKit으로 따졌을 때 publisher는 *NotificationCenter* 와 비슷한 종류입니다. 사실 *NotificationCenter* 는 *publisher(for:object:)* 라는 메소드를 가지고 있으며 이것은 publisher 타입을 전체의 publisher에게 알려줍니다.

```Swift
example(of: "Publisher") {
	// 1
	let myNotification = Notification.Name("MyNotification")
	
	// 2
	let publisher = NotificationCenter.default
		.publisher(for: myNotification, object: nil)
}
```

1) notification 이름을 생성합니다.

2) NotificationCenter의 default에 접근하고 *publisher(for:object:)* 메서드를 호출하여 리턴된 값을 constant에 할당합니다.

![스크린샷 2020-10-28 오전 1 19 51](https://user-images.githubusercontent.com/48345308/97330527-af10d900-18bb-11eb-8564-6fcf0d74924c.png)

- 위에서 볼 수 있듯이 *publisher(for: object:)* 메서드는 *Publisher* 를 리턴하는 것을 알 수 있습니다. 

- 그렇다면 NotificationCenter가 publisher가 없이 알림을 브로드캐스트 할 수 있을 때 알림을 publish 하는 이유는 무엇일까요?

- Publisher는 2가지의 이벤트를 알려줍니다.

  1) element가 가리키고 있는 값

  2) 완료된 이벤트

- publisher는 0개 이상의 값을 알릴 수 있지만, 완료 이벤트는 하나만 내보낼 수 있으며 이것은 정상적인 이벤트이거나 에러일 수 있습니다.

- publisher가 한번 완료 이벤트를 내보니면, 이것은 끝났고 더 이상 이벤트를 내보낼 수 없습니다.

- 더 이상 알림을 받고 싶지 않을 떄 그 observer를 취소 할 수 있습니다.

```Swift
// 3
let center = NotificationCenter.default
	
// 4
let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { (notification) in
	print("Notification received!")
}
	
// 5
center.post(name: myNotification, object: nil)
	
// 6
center.removeObserver(observer)
```

3) default notification center를 다루기 위해서 생성

4) 이전에 이름과 함께 만들었던 notification에게 알림을 받을 observer를 생성합니다.

5) 이름과 함께 notification에서 post 합니다.

6) notification center로부터 observer를 제거합니다.

- 실행해 보면 아래와 같이 출력이 일어납니다.

![스크린샷 2020-10-28 오전 1 30 05](https://user-images.githubusercontent.com/48345308/97331790-1e3afd00-18bd-11eb-8a69-0a5a1930445d.png)





### Hello Subscriber

- *Subscriber* 는 publisher로부터 input을 받을 수 있는 타입을 요구하는 프로토콜입니다.

```Swift
example(of: "Subsriber") {
	let myNotification = Notification.Name("MyNotification")
	let publisher = NotificationCenter.default .publisher(for: myNotification, object: nil)
	let center = NotificationCenter.default
}
```

- notification을 지금 post 하면 publisher는 아무것도 내보내지 않을 것입니다. publisher는 적어도 한 명의 subsriber가 있을 때만 이벤트를 내보냅니다.



### Subscribing with sink()

![스크린샷 2020-10-28 오전 1 34 36](https://user-images.githubusercontent.com/48345308/97332389-bf29b800-18bd-11eb-9051-3170d6db0ad8.png)

1) publisher에서 sink를 호출하며 subscription을 생성합니다.

2) notification을 post합니다.

3) subscription을 취소합니다.

- sink 메서드의 이름의 모호함에 따라 가라 앉는 듯한 느낌을 갖으면 안됩니다.
- 이것은 단순히 subscriber와 publisher로부터의 출력을 다루는 클로저를 붙일 수 있는 가장 쉬운 방법을 제공합니다.
- 이 예시에서처럼 notification을 받을 때 이 클로저를 무시하고 오직 message를 프린트 하는 것도 가능합니다.
- *sink operator* 는 publisher가 내보내는 만큼의 값을 받을 것입니다.
- 위에서는 프린트문만을 사용했지만 sink operator는 사실 두 클로저를 제공합니다. (완료 이벤트 수신을 처리하는 것이고, 하나는 수신된 값을 처리하는 것입니다.)

```Swift
example(of: "Just") {
	// 1
	let just = Just("Hello World")
	
	// 2
	_ = just
		.sink(receiveCompletion: {
			print("Received completion", $0)
		}, receiveValue: {
			print("Received value", $0)
		})
}
```

1) *Just* 라는 publisher를 생성하고 원시 값을 이용하여 바로 생성하였습니다.

2) publisher로부터 구독을 생성하고 이벤트를 받을 때 메세지를 출력합니다.

![스크린샷 2020-10-28 오전 1 43 51](https://user-images.githubusercontent.com/48345308/97333545-095f6900-18bf-11eb-808d-c7fa85d3cf6f.png)



- *Just* 의 설명을 보자면 각 subscriber에게 출력을 한 번씩 보낸 다음에 이것은 끝나게 됩니다.
-  wmr subscriber에게 output을  한번만(just once) 출력한 다음 완료하는 것입니다!



### Subscribing with assign(to: on:)

- *sink* 외에도 내장된 *assign(to: on:)* operator는 수신된 값을 KVO를 준수하는 객체의 프로퍼티에 할당할 수 있도록 합니다.
- 주어지는 값이 무조건 있어야 하기 때문에 *sink* 와는 다르게 publisher의 failure 타입이 *Never* 일때만 사용 가능합니다!

```Swift
example(of: "assign(to:on:)") {
	// 1
	class SomeObject {
		var value: String = "" {
			didSet {
				print(value)
			}
		}
	}
	
	// 2
	let object = SomeObject()
	
	// 3
	let publisher = ["Hello", "World"].publisher
	
	// 4
	_ = publisher
		.assign(to: \.value, on: object)
}
```

1) didSet observer 프로퍼티를 가지고 있는 클래스를 정의하며 새로운 값을 출력합니다.

2) class의 인스턴스를 생성합니다.

3) string 배열로부터 publisher를 생성합니다.

4) publisher를 구독하고 수신된 값을 각 객체의 프로퍼티에 할당합니다.

![스크린샷 2020-10-28 오전 1 50 56](https://user-images.githubusercontent.com/48345308/97334380-06b14380-18c0-11eb-8ee9-53f862165ec4.png)



### Hello Cancellable

- subscriber가 끝나고 더 이상 publisher로 부터 값을 받고 싶지 않을 때, subscription의 자원을 자유롭게 하고 네트워크 통신과 같이 해당 활동이 다시 발생하지 않도록 취소하는 것이 좋습니다.
- *Subscription은 AnyCancellable 인스턴스를  cancellation token 으로 반환하므로 subscription이 완료되면 취소하는 것이 가능합니다*. *AnyCancellable* 프로토콜은 *Cancellable* 프로토콜을 준수하며, *cancel()*  메서드는 해당 목적을 위해 요구하게 됩니다.

```Swift
center.post(name: myNotification, object: nil)
subscription.cancel()
```

- 첫 번째 코드는 Notification을 보냅니다
- subscription을 취소합니다. *cancel()* 메서드를 호출할 수 있습니다. 왜냐하면 *Subscription* 프로토콜은 *Cancellable* 로부터 상속되기 때문입니다.
- 만약에 *cancel()* 메서드를 호출하지 않으면 publisher가 완료될 때까지 또는 일반적인 메모리 관리 인해 subscription이 초기화 되지 않을 때까지 계속됩니다.



### Understanding what's going on

- 이번에는 이미지를 통해서 직접 보면서 어떤 식으로 동작하는지에 대해 알아보겠습니다.

![스크린샷 2020-10-28 오전 9 43 47](https://user-images.githubusercontent.com/48345308/97376949-16517c00-1902-11eb-90dc-1044d6b88b6c.png)

1. subscriber는 publisher를 subscribe 합니다.
2. publisher는 subscription을 생성하고 그것을 subscriber에게 보냅니다.
3. subscriber는 값을 요청합니다.
4. publisher는 값을 보냅니다.
5. publisher는 완료를 보냅니다.



![스크린샷 2020-10-28 오전 9 48 55](https://user-images.githubusercontent.com/48345308/97377203-ccb56100-1902-11eb-8a63-74b525d2448c.png)

- *Publisher* 프로토콜과 이것의 extension을 보도록 하겠습니다.

  1) publisher가 생성할 수 있는 타입의 값들 입니다.

  2) publisher가 생성할 수 있는 에러의 타입이며 *Never* 라면 error를 생성하지 않는 것을 보장합니다.

  3) subscriber가 *subscribe(_:)* 을 호출하여 publisher에게 붙입니다.

  4) *subscribe(_:)* 의 실행은 *receive(subsriber:)* 를 호출할 것이고 subscriber를 publisher에게 붙여 subscription을 생성합니다.



![스크린샷 2020-10-28 오전 9 54 32](https://user-images.githubusercontent.com/48345308/97377517-95937f80-1903-11eb-9bf9-f466f689aff0.png)

- *Subscirber* 프로토콜에 대해서 알아보도록 하겠습니다.

  1) subsriber가 받을 수 있는 타입입니다.

  2) subscriber가 받을 수 있는 에러의 타입이며 *Never* 라면 에러를 받지 않습니다.

  3) publisher는 subscriber에게 subscription을 주기위해 *receive(subscription)* 을 호출합니다.

  4) publisher는 *receive(_:)* 을 subscriber에게 호출하고 새로운 값을 보냅니다.

  5) publisher는 *receive(completion:)* 을 호출하여 정상적이거나 오류로 인해 값을 생산하는 것이 끝났다는 것을 알립니다.



- *Publisher* 와 *Subscriber* 의 연결은 **subscription** 을 통해 일어납니다.

![스크린샷 2020-10-28 오전 9 58 46](https://user-images.githubusercontent.com/48345308/97377794-2d916900-1904-11eb-9e97-b5b84d3482d7.png)

- *subscriber* 는 *request(_:)* f를 호출하여 값을 더 받을지 최대 몇개의 값을 받거나 무한정 받을지를 알려줍니다.
- *Subscriber* 에게 통지가 요구 되어지는 *receiver(_:)* 을 보냅니다. subscriber가 처음에 *subscription.request(_:)* 를 호출할 때 수신하고 싶은 최대값 수가 지정을 하더라도 새로운 값을 받을 때마다 최대값을 조젛아는 것이 가능합니다.



### Creating a custom subscriber

```Swift
example(of: "Custom Subscriber") {
	// 1
	let publisher = (1...6).publisher
	
	// 2
	final class IntSubscriber: Subscriber {
		
		// 3
		typealias Input = Int
		typealias Failure = Never
		
		// 4
		func receive(subscription: Subscription) {
			subscription.request(.max(3))
		}
		
		// 5
		func receive(_ input: Int) -> Subscribers.Demand {
			print("Received value", input)
			return .none
		}
		
		// 6
		func receive(completion: Subscribers.Completion<Never>) {
			print("Received completion", completion)
		}
	}
}
```

​	1) publisher를 int로 생성하고 publisher 프로퍼티의 범위를 지정해줬습니다.

​	2) custom subscriber를 정의하엿습니다.

​	3) *type aliase* 를 통해서 subscriber가 받을 수 있는 int 입력과 error를 받지 않을 것이라는 것을 지정하였습니다.

​	4) 요구되는 메서드이며 *publisher*에 의해 호출되는 *receive(subscription:)* 을 구현하였고 이 메서드는 *.request(_:)* 를 통    해 subscriber가 최대 3개의 		값을 받을 의향이 있음을 명시하였습니다.

​	5) 각각의 받는 값들을 프린트하고 subscriber가 요구를 조정하지 않는 *.none* 을 리턴하였습니다. (.none은 .max(0)과 동일합니다.)

​	6) 완료된 이벤트를 출력합니다.



- publisher가 publish하기 위해서는 subscriber가 필요합니다.

```Swift
let subscriber = IntSubscriber()
publisher.subscribe(subscriber)
```

<img width="266" alt="스크린샷 2020-10-28 오전 10 09 28" src="https://user-images.githubusercontent.com/48345308/97378433-ac3ad600-1905-11eb-9a9e-009ba8d2deca.png">

- 이것은 completion event는 받지 않습니다. 왜냐하면 publisher는 값의 갯수를 정해놓았기 떄문입니다. 여기서는 *.max(3)* 으로 명시되어 있습니다.

<img width="415" alt="스크린샷 2020-10-28 오전 10 11 14" src="https://user-images.githubusercontent.com/48345308/97378553-ead09080-1905-11eb-81c1-73a0e87133a2.png">

- 위와 같이 바꾸면 아래와 같이  completion이 끝났다는 메세지를 보는 것이 가능합니다.

<img width="270" alt="스크린샷 2020-10-28 오전 10 11 38" src="https://user-images.githubusercontent.com/48345308/97378573-f91eac80-1905-11eb-81f7-50247f0e731f.png">



### Hello Future

- subscriber에게 단일 값을 내보낸 다음 완료를 위해 publisher를 만드는 것은 *Just* 와 비슷하며, Future를 사용하여 단일 결과를 비동기적으로 만든 다음에 완료하는 것이 가능합니다.

```Swift
example(of: "Future") {
	func futureIncrement( integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
			Future<Int, Never> { promise in DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
				promise(.success(integer + 1)) 
      }
		}
	}
}
```

- 정수를 방출하고 절대 실패하지 않는다는 뜻의 함수를 만들었습니다.
- 또한 이 예시를 subscrib할 subscription들을 추가해야 합니다.
- 함수 안의 의미는 지연이 있는 후에 정수를 증가시킬 것이며 함수의 호출자가 지정된 값을 사용해 실행하겠다는 약속의 의미입니다.
- 미래의 publisher는 결국 단일 값을 생성하여 완성하거나 실패할 수 있습니다. 
- 여기서 *promise* 는 미래에서 publish한 단일 값 또는 오류를 포함하는 결과를 수신하게 되는 closure를 말합니다.

<img width="858" alt="스크린샷 2020-10-28 오전 10 26 09" src="https://user-images.githubusercontent.com/48345308/97379369-00df5080-1908-11eb-88d8-3ab45e986f84.png">

​	1) 위에서 만들었던 함수를 사용하여 future를 만들고 증가할 int를 명세하고 3초에 한번씩 int를 넘깁니다.

​	2) subscribe하고 받은 값과 completion 이벤트를 출력하며 subscription을 *subscription set* 에 저장합니다. (나중에 이에 대한 내용을 더 배울 예정)



- 위의 코드를 실행시켜보면 3초간의 딜레이 뒤에 아래와 같이 출력되는 것을 알 수 있습니다.

![스크린샷 2020-10-28 오전 10 30 02](https://user-images.githubusercontent.com/48345308/97379626-8a8f1e00-1908-11eb-8a34-ab75d011d764.png)



### Hello Subject

- 우리는 publisher와 subscriber가 어떻게 동작하는 지를 배웠으며 custom subscriber를 어떻게 생성하는지도 알아보았습니다.
- subjects 는 Combine이 아닌 Combine subscriber에게 값을 보낼 수 있도록 하는 중간자 역할을 합니다.

```Swift
example(of: "PassthroughSubject") {
	
	// 1
	enum MyError: Error {
		case test
	}
	
	// 2
	final class StringSubscriber: Subscriber {
		typealias Input = String
		typealias Failure = MyError
		
		func receive(subscription: Subscription) {
			subscription.request(.max(2)) 
    }
		
		func receive(_ input: String) -> Subscribers.Demand { print("Received value", input) {		
			// 3
			return input == "World" ? .max(1) : .none
		}
                                                         
		func receive(completion: Subscribers.Completion<MyError>) {
			print("Received completion", completion)
		}
	}
	// 4
	let subscriber = StringSubscriber()
}
```

1) custom 에러 타입을 정의합니다.

2) custom subscriber를 정의하고 string 값을 받으며 MyError를 error로 받습니다.

3) reive한 값을 기반으로 하여 요구사항에 적용합니다,

4) custom subscriber의 인스턴스를 생성합니다.

- 입력이 "World" 이면 *receive(_:)* 에서 .max(1) 을 반환하고 있습니다.
- Custom 오류를 정의하고 받은 값을 사용하여 요구를 조정하는 것 외에는 새로운 항목이 현재 없습니다.



```Swift
// 5
let subject = PassthroughSubject<String, MyError>()

// 6
subject.subscribe(subscriber)

// 7
let subscription = subject .sink(
    receiveCompletion: { completion in
      print("Received completion (sink)", completion)
    },
    receiveValue: { value in
      print("Received value (sink)", value)
    }
)
```

5) String과 MyError 타입인 *PassthroughSubject* 인스턴스를 생성합니다. 

- CurrentValueSubject와 다르게 PassthroughSubject는 초기 값이 없습니다.

6) subscriber는 subject를 subscribe 합니다.

7) *sink* 를 사용하여 다른 subscription을 생성합니다.



- *Passthrough* 를 사용하면 필요에 따라 새로운 값을 publish 합니다. 이것들은 값과 완료 이벤트를 쉽게 전달하는 것이 가능합니다.
- 다른 publisher와 마찬가지로, 보내줄 값과 error의 타입을 미리 선언해야 합니다.
- 위의 코드를 실행하게 되면 다음과 같이 출력되는 것을 알 수 있습니다.

<img width="783" alt="스크린샷 2020-10-28 오전 10 56 54" src="https://user-images.githubusercontent.com/48345308/97381368-4c93f900-190c-11eb-8453-20d760c34daf.png">

- 각각의 subscriber들은 publish 된 값을 수신합니다.

```Swift
// 1
subscription.cancel()
subject.send("Still there?")

subject.send(completion: .finished)
subject.send("How about another one?")
```

1) subscription을 취소하고 다른 값을 보냅니다.

<img width="539" alt="스크린샷 2020-10-28 오전 10 59 52" src="https://user-images.githubusercontent.com/48345308/97381575-b57b7100-190c-11eb-8287-9be6ff16c1fa.png">

- 코드를 실행해보면 다음과 같이 출력되는 것을 알 수 있습니다. 
- 하지만 "How about another one?" 은 출력되지 않았습니다 왜냐하면 그것은 그 값이 전송되기 전에 완료 이벤트를 받았기 때문입니다. 
- 첫 번째 subscriber는 이전에 취소되었기 때문에 완료 이벤트나 값을 받지 못합니다.
- 또한 error는 첫 번째 subscriber가 수신하지만, 오류 이후 completion event가 전송된 것은 수신되지 않습니다.



```Swift
example(of: "CurrnetValueSubject") {
	// 1
	var subscriptions = Set<AnyCancellable>()
	
	// 2
	let subject = CurrentValueSubject<Int, Never>(0)
	
	// 3
	subject
		.sink { print($0) }
		// 4
		.store(in: &subscriptions)
}
```

1) subscription set를 만들었습니다.

2) Int와 Never 타입의 *CurrentValueSubject* 를 생성하였으며 이것은 integer를 publish하고 error는 publish하지 않습니다. 또한 초기값은 0입니다.

3) subsription을 subject에게 생성하고 받는 값들을 print 합니다.

4) subsription을 *subscriptions set* 에 저장합니다.

- 초기값을 현재의 subject 의 값으로 초기화 해야 합니다. 신규 subscriber들은 즉시 그 값을 받아오고 subject가 발생한 최신 값을 얻게 됩니다.

<img width="444" alt="스크린샷 2020-10-28 오전 11 09 20" src="https://user-images.githubusercontent.com/48345308/97382148-09d32080-190e-11eb-8b99-fc91236bc2c2.png">

- 초기에는 0을 프린트하고 subject가 보내는 것에 따라 프린트문에 출력되는 것을 볼 수 있습니다.
- *Passthrough subject* 와는 달리 언제든지 subject의 현재 값을 요청하는 것이 가능합니다.

```Swift
subject
		.sink(receiveValue: { print("Second subscription: ", $0) })
		.store(in: &subscriptions)
```

- 위와 같은 코드를 새로 추가한다면, 여기에서는 subsription을 생성하고 받은 값들을 출력합니다. 또한 *subsription set* 에 subscription을 저장합니다.
- 위에서 subscription set는 자동으로 취소된다고 하였는데, 한번 출력해보도록 하겠습니다. 아래와 같이 출력이 됩니다.

<img width="406" alt="스크린샷 2020-10-28 오전 11 16 24" src="https://user-images.githubusercontent.com/48345308/97382580-068c6480-190f-11eb-8bcc-3ee8384dca93.png">

- 각각의 이벤트들은 subscription handler의 값과 함께 프린트되며 subject의 value 값도 함께 프린트 됩니다.
- *subscription set* 은 이 example의 범위 내에서 정의되었기 때문에 수신 취소 이벤트는 출력됩니다.  deinit될 시에 포함된 subscription을 취소하게 됩니다.
- *CurrentValueSubject* 의 값 프로퍼티는 다음 것을 위한 것이므로 완료 이벤트는 *send(_:)* 를 사용하여 전송되어야 합니다. 



### Dynamically adjusting demand

- *CurrentValueSubject* 의 값 프로퍼티는 값을 위한 것입니다. 완료 이벤트는 *send()* 를 이용하여 전송되어야 합니다.
- 앞에서 *Subscriber.receive()* 에서 수요를 조정하는 것이 부가적이라는 것을 알게 되었고 이것을 조금 더 자세하게 알아보도록 하겠습니다.

```Swift
example(of: "Dynamically adjusting Demand") {
	final class IntSubscriber: Subscriber {
		
		typealias Input = Int
		typealias Failure = Never
		
		func receive(subscription: Subscription) { subscription.request(.max(2)) }
		
		func receive(_ input: Int) -> Subscribers.Demand { print("Received value", input)
			switch input {
			case 1:
				return .max(2) // 1
			case 3:
				return .max(1) // 2
			default:
				return .none
			}
		}
		
		// 3
		func receive(completion: Subscribers.Completion<Never>) {
			print("Received completion", completion)
		}
	}
	
	let subscriber = IntSubscriber()
	let subject = PassthroughSubject<Int, Never>()
	subject.subscribe(subscriber)
	
	subject.send(1)
	subject.send(2)
	subject.send(3)
	subject.send(4)
	subject.send(5)
	subject.send(6)
}
```

- 대부분의 코드는 지금 챕터에서 해왔던 코드입니다 대신 *receive()* 메소드에 집중을 하겠습니다. custom subscriber의 요구를 지속적으로 조정해보겠습니다.

1) 새로운 max는 4가 됩니다. (원래의 max 2 + 새로운 max 2)

2) 새로운 max는 5가 됩니다. (원래의 4 + 새로운 1)

3) 계속해서 5가 됩니다. (원래의 4 + 새로운 0)

- 예상했듯이 5까지만 출력이 되고 6은 출력이 되지 않습니다.
- 여기서 알아야 하는 중요한 사실이 하나 있습니다. 바로 publisher의 세부정보는 subscriber에게는 숨겨질 수 있다는 것입니다.

<img width="347" alt="스크린샷 2020-10-28 오전 11 32 36" src="https://user-images.githubusercontent.com/48345308/97383581-494f3c00-1911-11eb-98ec-584b530c0fdc.png">



### Type erasure

- subscriber가 publisher에 대한 추가 세부 정보를 접근할 수 없는 상태에서 publisher로부터 이벤트를 수신하도록 허용하려는 경우가 있을 수 있습니다.

```Swift
example(of: "Type erasure") {
	// 1
	let subject = PassthroughSubject<Int, Never>()
	
	// 2
	let publisher = subject.eraseToAnyPublisher()
	
	// 3
	publisher
		.sink(receiveValue: { print($0) }) .store(in: &subscriptions)
	
	// 4
	subject.send(0)	
}
```

1) *Passthrough subject* 를 생성합니다.

2) *type- earsed publisher* 를 subect로 부터 생성합니다.

3) *type- earsed publisher* 를 subscribe합니다,

4) *passthorugh subject* 를 사용하여 새로운 값을 보냅니다.

- *AnyPublisher*는 *Publisher* 프로토콜을 준수하는 구조체 입니다.  *Type erasure* 는 subscriber 또는 publisher에게 노출하지 않으려는 publisher에 대한 세부 정보를 숨기는 것이 가능하며 이 내용은 다음 섹션에서 확인하겠습니다.
- *AnyCancellable* 은  *Cancellable* 을 준수하는 type-erased 클래스로, 호출자가 subscription에 접근하지 않고 subscription을 취소하여 더 많은 항목을 요청하는 등의 작업을 수행할 수 있습니다.
- 우리는 이미 다른 type 삭제 타입을 이미 봤었습니다. 바로 AnyCancellable 입니다. 이 또한 type 삭제된 class로 Cancellable 을 따릅니다. subscriber가 더 많은 값을 요청하는 등의 작업을 수행하기 위해 기본 subscription에 엑세스하지 않고도 subscription을 취소할 수 있습니다.
- AnyCancellable은 취소 되었을 때, 제공된 closure를 실행하는 *type-erasing cancellable object* 라고 할 수 있습니다.
- publisher에 대한 *type-eraser* 를 사용하는 경우는 public 및 private 프로퍼티를 사용하려는 경우,  프로퍼티가 개인 publisher에게 값을 보낼 수 있도록 허용하고 외부 호출자가 subscribe를 이용해 public publisher에게만 접근하도록 하면서 값을 보낼 수는 없는 경우입니다.
- *AnyPublisher* 는 *send(_:)* operator를 가지지 않기 때문에 publisher에 새로운 값을 추가하는 것이 불가능합니다.
- *eraseToAnyPublisher* operator는 AnyPublisher의 인스턴스인 publisher를 받으며, publisher가 사실 *PassthroughSubject* 인것을 숨깁니다.



### Key points

- *Publisher* 는 동기식 또는 비동기식으로 하나 이상의 *subscriber* 에게 시간 경과에 따라 일련의 값을 전송합니다.
- **subscriber** 는 publisher를 subscribe하고 값을 받을 수 있지만, subscriber의 입력과 error 타입에 일치해야 합니다.
- publisher를 subsribe하는데는 두 가지의 내장 연산자 *sink()* 와 *assign(to:on)* 이 있습니다.
- subscriber는 가치를 받을 때마다 받은 가치에 대한 수요를 늘릴 수는 있지만 줄일 수는 없습니다.
- 자원을 확보하고 원치 않는 부작용을 방지하려면, 작업을 마친 뒤에 subsription을 취소하는게 좋습니다.
- 또한 subscription을 *AnyCancelable* 의 인스턴스 또는 collection에 저장하여 초기화 시 자동 취소를 받을 수 있습니다.
- *future* 는 나중에 비동기적으로 단일 값을 받는 데 사용할 수 있습니다.
- *Subject* 는 외부 호출자가 시작 값 유무에 관계없이 subscriber에게 여러 값을 비동기적으로 보낼 수 있는 것을 말합니다.
- *Type earsure* 는 호출자가 추가 세부 정보에 접근할 수 없도록 막습니다.

