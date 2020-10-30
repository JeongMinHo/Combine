# Chapter 11: Timers



- 반복되거나, 되지 않던 타이머는 코딩에서 굉장히 유용합니다.
- 코드를 비동기적으로 실행하는것 외에도, 언제 또는 어떻게 작업을 반복해야할지 정해야 할 때가 있습니다.
- *Dispatch* 프레임워크가 가능하기 이전에, 개발자들은 동시에 실행할 비동기 작업들을 *RunLoop* 에 의존했습니다.
- *Timer(NSTimer in Objective C)* 는 타이머를 생성하는 것이 가능합니다.
- 그리고 *Dispatch* 가 나오면서 *DispatchSourceTimer* 도 함께 나왔습니다.

<img width="500" alt="스크린샷 2020-10-30 오전 9 42 59" src="https://user-images.githubusercontent.com/48345308/97646911-4df02d80-1a94-11eb-9f6b-65cbdba28b11.png">

- 타이머를 기반으로 해서 event handler 블럭을 제공하는 Dispatch source라고 합니다.
- 이 프로토콜을 객체에 채택하는 대신에 *makeTimerSource(flags:queue:)* 메서드를 사용하여 이 프로토콜을 채택하는 객체를 만들어야 한다고 합니다.

![스크린샷 2020-10-30 오전 9 46 41](https://user-images.githubusercontent.com/48345308/97647129-d2db4700-1a94-11eb-827d-f021baa8c7ca.png)

- 타이머 이벤트를 모니터링하는 새 dispatch source 객체를 생성하는 메서드라고 합니다.
- 파라미터로는 동작을 가리키는 flag와 handler를 실행할 디스패치 큐를 받습니다. 
- 리턴 값은 DispatchSourceTimer 프로토콜을 준수하는 Dispatch Source 객체입니다!
- 이 메서드를 통해서 한 번 실행되거나 여러 번 실행되는 타이머를 예약할 수 있으며 타이머가 실행될 때마다 Dispatch source는 event handler를 호출합니다.

```Swift
var timer: DispatchSourceTimer?

private func startTimer() {
		let queue = DispatchQueue(label: "TimerExample", attributes: .concurrent)

		timer = DispatchSource.makeTimerSource(queue: queue)
		timer?.schedule(deadline: .now(), repeating: .seconds(2), leeway: .milliseconds(100))
		timer?.setEventHandler { [weak self] in
			print(Date())
		}

		timer?.resume()
	}
```



### Using RunLoop

- 메인 스레드나 내가 생성한 스레드나 Thread class를 사용하는 것은 자체 RunLoop를 가질 수 있습니다.
- *한가지 중요한 점은 RunLoop class 는 **thread-safe** 하지 않다는 것입니다*. 현재 스레드에서 runLoop를 호출하기 위한 메서드는 한 번만 호출해야 합니다.
  Mutex, Semaphore

```Swift
let subscription = runLoop.schedule(after: runLoop.now, interval: .seconds(1), tolerance: .milliseconds(100)) {
	print("Timer fired")
}
```

- 위의 타이머의 경우는 어떤 값도 전달하지 않으며 publisher도 생성하지 않습니다. 이 값은 지정된 간격과 허용오차를 이전 매개변수에 지정된 날짜에 실행됩니다. 
- Combine과 관련하여 이것의 유용성은 이것이 반환하는 Cancellable이 타이머를 멈출 수 있게 한다는 것입니다.

```Swift
runLoop.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) {
  cancellable.cancel()
}
```

- 하지만 모든 것을 고려해 볼 때, RunLoop는 타이머를 만드는 것은 최선이 아니고 Timer 클래스를 사용하는 것이 나을 것이다.
- 참고로 RunLoop 객체를 다른 스레드에서 호출하는 메서드를 생성시에는 문제가 발생할 수 있으므로 절대 안된다고 합니다.



### Using the Timer class

- *Timer* 는 macOS의 이름이 바뀌기 전인 Mac OS X 부터 사용가능했던 오래된 것입니다.
- 이것은 delegate pattern과 Run Loop의 긴밀한 관계 때문에 사용하기 까다로웠습니다.
- Combine은 모든 사전 작업 앖이도 바로 publisher로 직접 사용할 수 있는 현대적인 변화를 가지고 왔습니다.

```Swift
let publisher = Timer.publish(every: 1.0, on: .main, in: .common)
```

- 위 메서드의 *on* 파라미터의 경우 타이머가 메인 스레드의 RunLoop에 붙었음을 의미하며 *in* 파라미터는 타이머가 실행되는 run loop mode가 무엇인지를 결정합니다. 여기서는 default 모드입니다.

- *Run Loop* 는 macOS에서 비동기 이벤트를 처리를 위한 기본 메커니즘이지만 API는 다소 다루기 힘듭니다.

- 타이머가 반환하는 publisher는 *ConnectablePublisher* 입니다. 이것은 *connect()* 메서드를 명시적으로 부를 때 까지 subscription을 시작을 하지 않겠다는 특별한 종류입니다.

- 또한 *autoConnect()* operator를 사용하여 첫 번째 subscriber가 subscribe할 때 자동으로 연결되게 할 수 있습니다.

  - 그렇기 때문에, publisher를 생성하는 가장 좋은 방법은 subscription을 시작할 시 타이머를 시작하게 하는 방법입니다.

  ```Swift
  let publisher = Timer.publish(every: 1.0, .main, in: .common).autoConnect()
  ```

- *Timer.publish()* 의 *tolerance* 라는 파라미터는 요청한 기간으로부터 허용 가능한 편차를 시간으로 명시하는 의미입니다.



### Using DispatchQueue

- dispatch queue를 이용하여 타이머 이벤트를 생성했습니다.
- Dispatch Framework에는 *DispatchTimerSource* 가 있지만, Combine은 그것에 타이머 인터페이스를 제공하지 않습니다. 대신에 다른 방법을 사용해서 queue에 타이머 이벤트를 생성해볼 계획입니다.

```Swift
let queue = DispatchQueue.main

// 1 
let source = PassthroughSubject<Int, Never>()

// 2 
var counter = 0

// 3 
let cancellable = queue.schedule(
	after: queue.now, 
  interval: .seconds(1)
) {
  source.send(counter)
  counter += 1
}

// 4 
let subsription = source.sink {
  print("Timer emitted \($0)")
}
```

1) timer 값을 보낼 Subject를 생성했습니다.

2) counter 프로퍼티를 만들고 타이머가 시작하고 값을 증가시킵니다.

3) 매초마다 선택한 queue에서 반복적인 작업을 작업하고. action은 즉시 시작하는 형태입니다.

4) subject의 subscriber들은 값을 얻습니다.



### Key points

- *Timer.publish* 를 사용하여 지정된 RunLoop에서 지정된 간격으로 값을 생성하는 publisher를 획득했습니다.
- dispatch queue에서 이벤트를 보내는 현대 타이머인 *DispatchQueue.schedule* 을 사용해보았습니다.