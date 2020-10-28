# Chpater 1: Hello, Combine



- 이 책은 Combine 프레임워크를 소개하며 Swift 애플 플랫폼에서 선언적이고 반응형 앱을 작성한는 법을 소개합니다.
- 애플은 **"컴바인은 앱의 이벤트 실행에 따라 어떻게 *delarative* 한 접근이 가능한지를 제공한다."** 라고 말했습니다.
- *delegate* 나 *completion handler closure* 를 사용하는 것보다 각각의 자원에 주어진 실행 체인을 생성하는 것이 좋다고 합니다.
- delcarative의 반대말은 imperative(명령어)라고 할 수 있습니다.
- 콜백함수는 다른 곳에서 이 콜백 함수를 부름. (iOS에서도 콜백을 부르는 객체는 어떤것인가?)



### Asynchronous programming

- 단일 스레드 언어에서, 프로그램은 한줄 한줄 순서대로 실행합니다.
- 동기식의 코드는 이해하기 쉬우며 특히 데이터 상태에 대해서 알기 쉽습니다.
- 단일 스레드 실행해서 현재 데이터의 상태가 어떤지 확실히 알 수 있습니다.
- 멀티 스레드 언어에서 비동기로 iOS처럼 실행되는 것이 있다고 상상해보겠습니다.

```Swift
-- Thread 1 --
begin
	var name = "Tom"
	print(name)

-- Thread 2 --
	name = "BIlly Bob"

-- Thread 1 --
	name += "Harding"
	print(name)
end
```

- 이 코드에서 이름의 값을 "Tom"으로 설정했다가 "Harding"을 마지막에 추가합니다. 그러나 다른 스레드가 동시에 실행됐기 때문에 "Billy Bob"과 같은 다른 이름으로 설정되었을 수도 있습니다.
- 코드가 다른 코어에서 동시에 실행된다면 어떤 공유된 상태가 바뀌었는지를 알기가 어렵습니다.
- 어플리케이션의 *mutable state* 을 관리하는 것은 비동기식 코드를 실행하면 loaded task가 됩니다.



### Foundation and UIKit/AppKit

- 애플은 몇년동안 그들의 플랫폼에서 비동기적인 프로그래밍을 발전시켜왔습니다.

- 비동기식 코드를 작성하고 실행하기 위해 시스템 레벨마다 우리가 사용할 수 있는 메카니즘이 있습니다.

  1) **NotificationCenter** : 사용자가 디바이스의 방향을 변경하거나 키보드가 화면에 표시되거나 숨길 때와 같이 관심 이벤트가 발생할 때 코드가 	실행됩니다.

  2) **The delegate pattern** : 다른 객체가 대신하거나 다른 객체와 함께하는 것을 정의할 수 있습니다. 예를 들어 app delegate에서 우리는 remote notification이 도착하거나 할때 어떻게 해야할 지를 정의합니다. 그러나 이 코드가 어떻게 실행되거나 몇 번이 실행되는지에 대해서는 알지 못합니다.

  3) **Grand Central Dispatch** and **Operations** : 어떠한 작업의 실행을 추상화할 수 있도록 도와줍니다. 일련의 queue에서 순차적으로 실행되도록 코드를 예약하거나 다른 여러 queue에서 여러 작업을 동시에 할 수 있게 해줍니다.

  4) **Closures** : 코드의 묶음을 만들어 우리의 코드로 전달합니다. 따라서 객체는 실행하고 싶을때를 결정할 수 있으며 어떠한 문맥에서 몇번을 실행할지 결정할 수 있습니다.

- 전형적인 코드에서 UI 이벤트는 비동기적으로 실행되기 때문에 앱 코드 전체를 실행할 순서를 추측하는 것은 불가능 합니다.

- 불행하게도, 비동기적인 코드와 공유자원은 고치기 쉽지 않고, 추적하기 쉽지 않은 몇 가지 문제점이 있습니다.

- 이러한 문제의 원인 중 하나는 *solid* 인데 이는 앱이 비동기식 API를 모두 사용한다는 사실입니다.

![스크린샷 2020-10-27 오후 9 48 48](https://user-images.githubusercontent.com/48345308/97303785-34859080-189e-11eb-94d5-c0b9d4e8540d.png)



- Combine의 목표는 Swift의 비동기식 프로그래밍 세계의 혼란에서 순서 있는 생산성을 제공하기 위함입니다.
- Apple은 Combine API를 Timer, NotificationCenter 그리고 CoreData에 통합시켜 놓았습니다.
- **또한 애플은 새로운 UI Framework인 SwiftUI가 Combine가 쉽게 통합되도록 디자인하였습니다.**

![스크린샷 2020-10-27 오후 9 51 48](https://user-images.githubusercontent.com/48345308/97304083-9f36cc00-189e-11eb-9155-306ee5b16bab.png)



### Foundation of Combine

- *Declarative* 하고 반응형 프로그래밍은 새로운 개념이 아닙니다. 이것은 꽤 오래전부터 나왔으며, 지난 10년동안 눈에 띄는 복귀를 했습니다.
- 애플 플랫폼에서, RxSwift 같은 반응형 프레임워크가 있습니다. 
- Combine은 Rx와 다르지만 유사한 표준인 *Reactive Stream* 을 구현합니다. *Reactive Stream* 은 Rx와 몇 가지 주요 차이점이 있지만, 둘 다 대부분의 핵심 개념은 동일합니다.
- iOS 13/macOS 카탈리나에서 애플은 내장된 시스템 프레임워크인 Combine을 통해서 반응형 프로그래밍을 지원하는 것을 소개했습니다. 
- Combine은 iOS 13 이상만을 지원합니다. 



### Combine basics

- Combine에서 3가지의 핵심은 ***Publishers && Operators && Subscribers*** 입니다. 이것들은 함께일때 더 좋은 효과를 냅니다.



### Publishers

- *Publisher* 는 *Subscriber* 와 같이 하나 이상의 당사자에서 시간 경과에 따라 가치를 낼 수 있는 타입니다.

- 수학 계산, 네트워킹, 사용자 이벤트 처리 등 거의 모든 것이 될 수 있는 publisher의 내부 로직에 관계없이 모든 Publisher는 다음가 같은 3가지 타입의 이벤트를 내보낼 수 있습니다.

  1) 결과 값은 publisher의 제네릭 Output 입니다.

  2) 성공적인 결과

  3) publisher의 실패 타입에 따른 에러 

- publisher는 0또는 그 이상의 출력 값을 낼 수 있으며, 만약 그것이 성공적 또는 실패로 인해 끝난다면, 다른 이벤트도 내지 않게 됩니다.

- 아래의 이미지는 publisher가 Int 값을 어떻게 시간에 따라 발산 하는지를 보여줍니다.

![스크린샷 2020-10-27 오후 10 05 32](https://user-images.githubusercontent.com/48345308/97305528-8a5b3800-18a0-11eb-9f38-144fe17c3031.png)

- 파란색 박스는 timeline에 따라 주어진 시간에 어떤 값을 내는지를 보여주는 것이고 숫자는 emit된 값입니다. 
- 세 가지의 가능한 사건의 당신의 프로그램에서 어떤 종류의 동적 데이터를 나타내는지 보여줍니다.
- publisher의 좋은 기능 중 하나는 오류를 핸들링 할 수 있다는 것입니다.
- *Publisher protocol* 은 2개의 타입의 제네릭입니다.
  1. *Publisher.Output* : publisher의 결과 값의 타입이며. publisher가 Int라면 이것은 String 이나 Data 값은 방출할 수 없습니다.
  2. *Publisher.Failure*는 실패가 발생할 때 던지는 에러의 타입입니다. publisher가 실패하지 않는다면 *Never* 실패 타입을 선언할 수 있습니다.



### Operators

- *Operator* 는 Publisher 프로토콜에 선언되어 있으며 같거나 새로운 Publisher를 리턴하는 메소드입니다.
- 여러 개의 opeartor를 차례로 호출하여 효과적으로 연결시킬 수 있개 때문에 매우 유용합니다.
- *operator* 라고 불리는 이러한 방법들은 디커플링과 구성성이 높기 때문에, 하나의 구독을 실행하는 것에 대해 매우 복잡한 논리를 구현하기 위해 결합 할 수 있습니다.

<img width="543" alt="스크린샷 2020-10-28 오전 1 01 58" src="https://user-images.githubusercontent.com/48345308/97328261-301aa100-18b9-11eb-84c3-b5978d5d5f91.png">