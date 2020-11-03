# Chapter 19: Testing Combine Code



- 테스트를 작성하는 것은 새로운 기능을 개발하고 있는 앱에서 의도한 기능을 보장할 수 있는 좋은 방법이며, 특히 기능 이후 최신 작업이 정상적으로 작동하는 이전 코드가 잘 작성되었다는 것을 확인할 수 있습니다.
- 이번 챕터에서는 Combine 코드에 대한 unit test를 작성하는 방법을 소개하며, 그 과정에서 재미를 느낄 수 있을 것입니다.

![스크린샷 2020-11-02 오후 8 40 41](https://user-images.githubusercontent.com/48345308/97864286-adc42e00-1d4b-11eb-8766-163ae904bece.png)

- *ColorCalc* 는 SwiftUI와 Combine을 사용하여 개발 되었습니다. 지금 이것은 몇 가지의 문제점이 있습니다.
- 이러한 문제를 찾고 해결하는데 도움이 되는 몇 가지의 unit test를 작성할 것입니다.



### Getting started

- 이 프로젝트는 빨강, 초록, 파랑, 투명도로 디자인 되어 있습니다. 또한 16진수에 맞게 배경색을 조정하고, 가능한 경우에는 색의 이름을 부여할 수 있습니다.
- 또한 입력된 16진수의 값으로 색상을 가져올 수 없는 경우, 배경은 흰색으로 설정됩니다.
- 지금 현재는 몇 가지 문제점이 있는데 이러한 문제를 해결할 뿐만 아니라 올바른 기능을 검증하기 위해 몇 가지 테스트를 작성함으로서 개발-QA 프로세스를 처리해보겠습니다.



#### Issue1 

- *Action* : 앱을 실행한다

- *Expected* : name 라벨이 aqua라고 보인다.

- *Actual* : name label이 Optional로 보인다.

  

#### Issue2

- *Action* : (<-)버튼을 탭한다.
- *Expected* : hex 디스플레이서 마지막 문자가 제거된다.
- *Actual* : 마지막 2개의 문자가 제거된다.



#### Issue3

- *Action* : (<-)버튼을 실행한다
- *Expected* : 배경이 하얀색으로 바뀐다.
- *Actual* :  배경이 빨간색으로 빠귄다.



#### Issue4

- *Action* : (x) 버튼을 탭한다.
- *Expected* : 16진수 값이 #로 지워진다.
- *Actual* :  16진수 값이 변하지 않는다.



#### Issue5

- *Action* : 16진수 006636을 입력한다.
- *Expected* : 빨간색, 초록색, 파랑색 불투명도가 0, 102, 54, 255가 보인다.
- *Actual* :  빨간색, 초록색, 파랑색 불투명도가 0, 62, 32, 155가 보인다.



### Testing Combine operators

- 이번 챕터 동안에 테스트 논리를 구성하기 위해서 **Given-When-Then** 패턴을 사용할 것입니다.

1) **Given** : 조건

2) **When** : 액션이 언제 실행되는가

3) **Then** : 예상되는 결과



- 시작하기에 앞서 subscription을 저장할 *subscriptions* 프로퍼티를추가하고 여기에 빈 배열인 *tearDown()* 을 설정하겠습니다.

```Swift
var subscriptions = Set<AnyCancellable>()
	
// Provides an opportunity to perform cleanup after each test method in a test case ends.
override func tearDown() {
	subscriptions = []
}
```



### Testing collect()

- 첫 번째로는 *collect()* operator을 사용해보겠습니다. 
- 이 operator는 업스트림 게시자가 내보내는 값을 버퍼링하고 완료되기를 기다린 후에 다운스트림 값을 포함하는 배열을 내보냅니다.
- **Given - When - Then** 패턴에 의해서, 아래의 test 메서드를 추가하겠습니다.

<img width="465" alt="스크린샷 2020-11-03 오전 10 12 36" src="https://user-images.githubusercontent.com/48345308/97935858-1a2b4580-1dbd-11eb-8035-7df01a55711f.png">

- Given : 이 코드를 통해서 정수 배열을 만들고 있고 그 배열에 publisher를 설정했습니다.
- When: *collect* operator를 사용하고 있으며 output값을 subscribe하고 output과 value가 같으면 subscriptions에 *store* 하고 있습니다.

- Xcode에서 test를 실행하는 몇 가지 방법이 있습니다.

  1) 단일 테스트를 진행하기 위해서 메소드가 정의되어 있는 옆의 다이아몬드를 클릭하면 됩니다.

  2) 단일 테스트의 클래스안의 테스트들을 진행하기 위해서는 class 정의 옆에 다이아몬드를 클릭하면 됩니다.

  3) 프로젝트 안에 test target에 있는 모든 테스트를 실행하기 위해서는 *Command-U* 를 누르면 됩니다. 하지만 각 테스트 대상에는 여러 테스트를 포함할 수 있는 여러 테스트 클래스가 존재합니다,

  4) 또는 *Product - Perform Action - Run "TestClassName"* 이나 *Command-Control-Option-U* 를 누르면 됩니다.

- *test_collect()* 옆에 있는 다이아몬드 버튼을 클릭하면 테스트가 실행됩니다.  그리고 테스트가 성공한다면 아래와 같은 것을 볼 수 있습니다. 또한 다이아몬드는 초록색으로 바뀌고 체크마크가 포함 될 것입니다.

<img width="247" alt="스크린샷 2020-11-03 오전 10 33 27" src="https://user-images.githubusercontent.com/48345308/97936789-033a2280-1dc0-11eb-92d2-54ea6443fc07.png">



- 또한 *View - Debug Area - Acrivate - Console* 을 통해 Console을 통해서 볼 수 있으며 *Command - Shift - Y* 를 누르면 결과에 대한 자세한 값을 볼 수 있습니다.
- 이 테스트를 정확하게 검증하기 위해서 코드를 조금 수정해보겠습니다.

<img width="1059" alt="스크린샷 2020-11-03 오전 10 37 20" src="https://user-images.githubusercontent.com/48345308/97936955-8fe4e080-1dc0-11eb-8722-71572e0fc66b.png">

- *collect()* 에서 내보낸 배열과 비교 중인 값 배열과 메세지에서 보낸 값에 1을 추가하였습니다.
- 테스트를 실행해보면 이것은 실패했다고 나오고 *XCTAssertTrue failed - Result was epected to be [0, 1, 2, 1] but was [0, 1, 2]* 다음과 같은 메세지가 출력됩니다. 
- 이것은 꽤 간단한 테스트였고 이제 조금 복잡한 operator를 테스트 할 것 입니다.



### Testing flatMap(maxPublishers:)

- Chapter 3에서 배웠던 것 처럼 *flatMap* operator는 upstream publisher를 단일 publisher로 flatten 하는데 사용됩니다. 그리고 이것은 원하는 경우에 받거나 flatten할 최대 publisher를 지정할 수 있습니다.

<img width="751" alt="스크린샷 2020-11-03 오전 10 46 26" src="https://user-images.githubusercontent.com/48345308/97937369-d4bd4700-1dc1-11eb-8337-1a6d313cada6.png">

1) *PassthroughSubject* 의 3개의 인스턴스를 생성하고 Int 타입을 값을 받습니다.

2) currentValueSubject는 PassthroughSubject Int 를 받아들이는 현재 value subject이며, 첫 번째 integer subject로 초기화됩니다.

3) 예상되는 결과 및 실제 결과를 저장할 배열입니다.

4) publisher의 subscription은 *flatMap*을 사용하여 최대 2개의 publisher를 사용할 수 있습니다. handler에서 result 배열에 수신받은 각각의 값을 추가합니다.



<img width="295" alt="스크린샷 2020-11-03 오전 11 04 56" src="https://user-images.githubusercontent.com/48345308/97938298-6af26c80-1dc4-11eb-8486-fb2f6156fedd.png">

- publisher는 current value subject이기 때문에 이것은 current value를 새로운 subscriber에게 응답합니다.

5) 새로운 값을 첫 번째 integer publisher에게 보냅니다.

6) current value subject를 통해 2번째 integer subject를 보내고 새로운 값을 subject에게 보냅니다.

7) third integer subject에게 이전의 단계를 반복하며 2개의 값을 보냅니다.

8) current value subject에게 completion event를 보냅니다.



<img width="443" alt="스크린샷 2020-11-03 오전 11 08 27" src="https://user-images.githubusercontent.com/48345308/97938503-e81de180-1dc4-11eb-8dca-b4f692ec6088.png">

- 테스트를 실행해보면 이것은 성공하는 것을 볼 수 있습니다.
- 만약 이전에 reactive programming에 경험이 있었다면 테스트 시간을 기반으로 하여 세부적으로 제어할 수 있는 가상 시간 스케줄러인 test scheduler를 작성하는 것이 익숙할 수 있습니다.
- Combine은 형식적인 test scheduler를 제공하지는 않습니다. *Entwine* 이라는 test scheduler 오픈 소스를 사용하는 것이 가능하며 이것은 형식적인 test schedulder를 제공합니다.

https://github.com/tcldr/Entwine

![스크린샷 2020-11-03 오전 11 17 49](https://user-images.githubusercontent.com/48345308/97938995-37184680-1dc6-11eb-8c7b-ca8ed8c25426.png)



### Testing publish(even:on :in)

- 다음으로는 *Timer* publisher를 테스트 해보겠습니다.
- Chapter 11을 보면 Timers publisher는 반복되는 Timer를 생산할 수 있습니다. 이것을 테스트 하기 위하여, *XCTest*의 예상 API를 사용하여 비동기 작업이 완료될 때 까지 기다리도록 하겠습니다.

<img width="438" alt="스크린샷 2020-11-03 오전 11 22 56" src="https://user-images.githubusercontent.com/48345308/97940136-ee14c200-1dc6-11eb-8b6d-32c81c171788.png">

1) 소수점 1자리를 반올림하여 시간 간격을 정규화하는데 도움을 주는 메서드를 정의합니다.

2) 현재 시간 간격을 저장합니다.

3) 비동기 작업이 완료될 때까지 기다리는데 사용된느 기대치를 생성합니다.

4) 예상되는 결과와 실제로 저장되는 배열을 정의합니다.

5) auto-connect되는 timer publisher를 생성하고 타이머가 내보내는 처음 세 값만 가져옵니다.



<img width="570" alt="스크린샷 2020-11-03 오전 11 26 42" src="https://user-images.githubusercontent.com/48345308/97942080-74310880-1dc7-11eb-8c57-fbaa770186e7.png">

- 위의 subscription handler는 helper function을 사용하여 각 방출되는 날짜의 시간 간격의 정규화된 버저을 가져오고 다음 결과 배열에 추가하고 있습니다.
- 이것이 끝나면 publisher가 일을 하고 끝낸 다음에 기다렸다가 검증을 하게 될 것입니다.



<img width="570" alt="스크린샷 2020-11-03 오전 11 29 21" src="https://user-images.githubusercontent.com/48345308/97943491-d427af00-1dc7-11eb-986d-d47aecba3bbd.png">

6) 최대 2초를 기다립니다.

7) 실제 결과에 예상되는 결과가 같은지 확인합니다.



- 테스트를 실행하면 성공할 것입니다. 지금까지는 Combine에 내장된 operator를 테스트해보았습니다. 
- 다음으로는 custom operator를 테스트해보도록 하겠습니다.



### Testing shareReplay(capacity:)

- 이 operator는 일반적으로 필요한 기능을 제공합니다.
- publisher의 ouput을 여러 subscriber들과 공유하면서 마지막 N 값의 버퍼를 새 subscriber에게 다지 재생하려면 다음과 같이 해야 합니다.
- 이 operator는 rolling buffer의 크기를 지정하는 *capacity* 파라미터를 사용합니다.

<img width="570" alt="스크린샷 2020-11-03 오전 11 37 20" src="https://user-images.githubusercontent.com/48345308/97944781-f110b200-1dc8-11eb-9644-c3337abdf810.png">

1) integer 값을 보내는 subject를 생성합니다.

2) subject에서 publisher를 생성하고 *shareReplay* 를 사용하여 capacity를 2로 설정합니다.

3) 예상되는 결과와 실제 실제 결과를 저장하는 배열을 생성합니다.



<img width="570" alt="스크린샷 2020-11-03 오전 11 41 32" src="https://user-images.githubusercontent.com/48345308/97944998-89a73200-1dc9-11eb-827f-93235138fd82.png">

4) publisher에게 subscription을 생성하고 방출하는 값을 저장합니다.

5) subject를 통해서 몇 개의 값을 보내고 publisher와 값을 공유합니다.

6) 다른 subscription을 생성하고 또한 방출하는 값들을 저장합니다,

7) subject를 통해서 한 개의 값을 더 보냅니다.

- 이것을 끝내고 나서 남은 것은 operator가 최신 정보를 얻을 수 있는지 확인합니다. 아래와 같으 코드를 추가하겠습니다.

```Swift
XCTAssert(
  results == expected,
  "Results expected to be \(expected) but were \(results)"
)
```

- 이 테스트를 실행하면 통과할 것이고 이 작은 종류의 Combine operator를 테스트하는 방법을 배움으로, 당신은 Combine에게 던질 수 있는 모든 것을 테스트 하는 기술을 얻게 되었습니다.
- 다음으로는 ColoarCalc 앱에 테스트하면서 적용해 보는 방법을 배우겠습니다.



### Testing production code

- 프로젝트는 MVVM 패턴으로 이루어져 있으며 우리는 앱의 view model인 *CalculatorViewModel* 을 고치도록 테스트 해야 합니다.

<img width="372" alt="스크린샷 2020-11-03 오후 12 48 26" src="https://user-images.githubusercontent.com/48345308/97948107-dfcca300-1dd2-11eb-97a6-23b118b7d349.png">

- 위와 같이 viewModel 프로퍼티를 선언하고 메소드를 변경하겠습니다.



### Issue 1: Incorrect name displayed

<img width="658" alt="스크린샷 2020-11-03 오후 12 51 25" src="https://user-images.githubusercontent.com/48345308/97948231-49e54800-1dd3-11eb-9cf6-c7f49c1b41a0.png">

1) 예상되는 이름 라벨의 text를 저장합니다. 

2) view model의 *name* publisher를 subscribe 하고 받은 값을 저장합니다.

3) 예상되는 결과의 트리거 작업을 수행합니다..

4) 예상되는 값과 실제 결과가 맞는지 확인합니다.

- 이 테스트를 실행하면 이것은 *XCTAssertTrue failed - Name expected to be rwGreen 66% but was -----------* 이런 메세지와 함께 실패할 것입니다.
- *CalculatorViewModel* 의 파일에는 *configure*() 이라는 메서드가 있고 이것은 view model의 subscription이 설정되는 뿐입니다. 



<img width="597" alt="스크린샷 2020-11-03 오후 1 01 53" src="https://user-images.githubusercontent.com/48345308/97948732-c0cf1080-1dd4-11eb-95f4-775c3ec275f2.png">

- 오직 ColorName의 local *name* 만 nil이 아닌 것을 체크하는 것이 아니라 non-nil 값에 대해서 옵셔널 바인딩을 해줘야 합니다. 따라서 아래의 코드에서 위의 코드로 수정을 하겠습니다.
- 그렇게 되면 이 테스트는 성공하게 됩니다. 수정 사항을 확인하기 위해 프로젝트를 수정하고 다시 실행하는 것 대신에, 이제 테스트를 실행할 때마다 코드가 예상되로 작동하는지 테스트 할 수 있습니다.



### Issue 2: Tapping backspace deletes two characters

<img width="531" alt="스크린샷 2020-11-03 오후 1 08 13" src="https://user-images.githubusercontent.com/48345308/97949025-a34e7680-1dd5-11eb-8ea6-bd7699e5f9c4.png">

1) 예상되는 결과와 실제 결과를 저장할 변수를 생성하고 설정합니다.

2) viewModel.$hexText을 subscribe하고 value를 받는 동안 droping 한 값을 받고 저장합니다.

3) *viewModel.process(_:)* 를 호출하고 <- 를 나타내는 상수 문자열을 전달합니다.

4) 예상되는 결과와 실제 결과가 같은지 확인합니다.

- 테스트를 실행하면 메세지는  *XCTAssertTrue failed - Hex was expected to be #0080F but was #0080* 와 같이 출력되면 실패할 것입니다.
- ViewModel의 *process* 메서드를 살펴보도록 하겠습니다.

```swift
case Constant.backspace:
	if hexText.count > 1 {
		hexText.removeLast(2)
}
```

- 지금 끝에서 2개를 지우고 있기 때문에 이것을 *removeLast()* 로 바꿔야 합니다.



### Issue 3: Incorrect background color

<img width="514" alt="스크린샷 2020-11-03 오후 1 15 27" src="https://user-images.githubusercontent.com/48345308/97949342-a5650500-1dd6-11eb-9098-45a41a125962.png">

- 이번에는 viewModel.hexText가 rwGreen으로 설정되어 있을 때 색상의 16진수 값이 rwGreen일 것으로 예상하면서 이번에는 viewModel의 $color publisher를 사용하여 테스트 해보도록 하겠습니다.

- 테스트를 실행하면 이것은 통과할 것입니다. 하지만 테스트를 작성하는 것은 조금 더 반응적이지 않더라도 사전적이어야 합니다. 
- 입력된 16진수에 대해 올바른 색상이 수진되었는지 확인하는 테스트가 수행되어야 합니다.
- (<- ) 버튼을 눌렀을 때 올바른 색상이 수신되었는지를 확인하는 테스트를 추가하도록 하겠습니다.



<img width="531" alt="스크린샷 2020-11-03 오후 1 23 46" src="https://user-images.githubusercontent.com/48345308/97949694-ced26080-1dd7-11eb-8012-cbbc46389bc0.png">

1) 예상되는 값과 실제 값을 위한 local value를 생성하고 이전과 같이 *viewModel.$color* 를 subscribe 합니다.

2) 명시적으로 16진수 text를 이전과 같이 설정하지 않고 이번에는 백스페이스 입력 처리를 해보겠습니다.

3) 예상과 실제 결과가 맞는지 확인합니다.

<img width="424" alt="스크린샷 2020-11-03 오후 1 25 58" src="https://user-images.githubusercontent.com/48345308/97949793-1eb12780-1dd8-11eb-81e3-444e2e730491.png">

- 그럼 위와 같은 메세지와 함께 테스트가 실패하게 됩니다. 마지막에 색이 흰색이 아니라 빨간색이라는 것이 중요합니다.



<img width="490" alt="스크린샷 2020-11-03 오후 1 27 57" src="https://user-images.githubusercontent.com/48345308/97949891-65068680-1dd8-11eb-95dc-3d4b29f07b6b.png">

- 배경을 빨간색으로 설정한 것이 의도한 값으로 대체되지 않았기 때문일 것입니다.
- 이 설계에서는 현재 16진수의 값에서 색상을 도출할 수 없을 경우 배경이 흰색이 되어야 하기 때문에 위에 코드에서 아래처럼 배경을 흰색으로 바꿔줘야 합니다.
- 이렇게 한다면 테스트는 통과할 것입니다.
- 지금까지는 테스트를 긍정적인 조건들을 테스트하는 것에 초점을 맞췄다면 다음에는 부정적인 상태에 대한 테스트를 진행해보겠습니다.



### Testing for bad input

- 이 앱의 UI를 사용하면 사용자가 16진수 값에 대해 안좋은 데이터를 입력할 수 없습니다.
- 그러나 상황은 변할 수 있습니다. 예를 들어 16진수 텍스트가 언젠가 TextField로 변경되어서 값을 붙여넣을 수도 있습니다.
- 그렇기 때문에 hex value에 대해 안좋은 데이터가 들어왔을 때 어떤 결과가 나오는지에 대한 검증을 하는 테스트를 추가하는 것은 좋은 생각입니다.

<img width="514" alt="스크린샷 2020-11-03 오후 1 33 47" src="https://user-images.githubusercontent.com/48345308/97950128-35a44980-1dd9-11eb-9e7f-8429aada17ee.png">

- 이 테스트는 이전의 것과 거의 동일합니다. 다른 한가지는 이번에는 hexText의 안좋은 데이터를 전달했습니다.
- 이 테스트를 실행하면 통과할 것입니다. 그러나 잘못된 데이터가 16진수 값에 입력될 수 있도록 논리가 추가되거나 변경되는 경우 테스트는 사용자의 손에 들어가기 전에 문제를 발견할 것입니다.



### Key points

- Unit Test는 당신의 코드가 초기 개발 동안에 예상대로 작동하고 차후에 코드가 퇴행하지 않을 수 있도록 도와줍니다.
- 당신이 테스트할 business logic과 UI 테스트할 presentation logic을 분리하기 위해 코드를 구성해야 합니다. MVVM은 이러한 목적에서 매우 적합한 디자인 패턴입니다.
- **Given - When - Then** 과 같은 패턴은 테스트 코드를 작성하고 조직화하는데 도움을 줍니다.
- 기대값을 사용하여 test time-based 비동기 코드를 테스트할 수 있습니다.
- 긍정적인 조건 외에도 부정적인 조건을 테스트하는것은 중요합니다.