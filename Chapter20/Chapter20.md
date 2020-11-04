# Chapter 20: In Practice: Building a Complete App



- Apple은 프레임워크 전반에 걸쳐서 Combine을 도입하고 통합함으로써 다음과 같은 점을 분명하게 말했습니다.
  - "Swift에서 선언적이고 반응적인 프로그래밍은 그들의 플랫폼을 위해 앞으로 가장 훌륭한 앱을 개발하는 방법이 될 것입니다."
- 지난 섹션까지는 우리는 Combine의 놀라운 기술에 대해서 배웠습니다.
- 또한 Core Data를 Combine과 어떻게 사용하는지 배우고 재미있는 농담들을 저장해보도록 하겠습니다.



### Getting started

- 이 프로젝트는 SwiftUI를 사용하였습니다. 

<img width="320" alt="스크린샷 2020-11-03 오후 3 43 33" src="https://user-images.githubusercontent.com/48345308/97956173-55dd0400-1deb-11eb-8fdd-36573553d20a.png">

1) *ChuckNorrisJokes* 는 메인 타켓이며 UI 코드를 가지고 있습니다.

2) *ChuckNorrisJokesModel* 은 모델과 서비스를 정의하고 있습니다. 모델을 자체 타켓으로 분리하는 것은 main target에 대한 접근을 관리하는 동시에 테스트 타켓이 internal 접근으로만 메서드에 접근할 수 있도록 하는 훌륭한 방법입니다.

3) *ChuckNorrisJokesTests* : 몇개의 unit test를 이 타켓에서 작성하였습니다.



<img width="352" alt="스크린샷 2020-11-03 오후 3 46 57" src="https://user-images.githubusercontent.com/48345308/97956367-cf74f200-1deb-11eb-99be-6df0d7f58310.png">

- preview를 보면 iPhone XS Max의 light 모드와 iPhone SE의 dark 모드를 볼 수 있습니다.
- preview 옆의 resume 버튼을 클릭하면 앱을 실행하여서 인터렉션이 가능합니다.



### Setting goals

- 사용자로서 다음과 같은 작업을 수행하려고 합니다.

  1) 농담을 싫어했거나 좋아했다는 것을 알려주기 위해 농담 카드를 왼쪽이나 오른쪽으로 swipe 할 때 indicator를 보여줘야 합니다.

  2) 나중에 익숙하게 읽을 수 있도록 농담을 저장할 수 있게 합니다.

  3) 농담 카드의 색을 왼쪽 또는 오른쪽으로 스와이프 하냐에 따라 빨간색 혹은 초록색으로 배경색을 보여줍니다.

  4) 현재 농담을 좋아햐냐 싫어하냐에 따라 새로운 농담을 가져옵니다.

  5) 새로운 농담을 가져올 때 indicator를 보여줍니다.

  6) 농담을 가져올 때 문제가 생기면 알림을 보여줍니다.

  7) 저장된 농담 목록을 작성합니다.

  8) 저장된 농담을 삭제할 수 있습니다.

- 또한 Unit test를 작성해야 합니다.



### Implementing JokesViewModel

- 이 앱은 농담을 가져오거나 저장된 농담을 번역하는 UI Component들의 상태를 관리하기 위해 단일 view model을 사용합니다.

```Swift
import UIKit
import Combine
import SwiftUI

// JokesViewModel.swift
public final class JokesViewModel {
	public enum DecisionState {
		case disliked, undecided, liked
	}
	
	private static let decoder = JSONDecoder()

	public init(jokesService: JokeServiceDataPublisher? = nil) {
		
	}
	
	public func fetchJoke() {
		
	}
	
	public func updateBackgroundColorForTranslation(_ translation: Double) {
		
	}
	
	public func updateDecisionStateForTranslation(
		_ translation: Double, andPredictedEndLocationX x: CGFloat, inBounds bounds: CGRect) {
		
	}
	
	public func reset() {
		
	}
}
```

- Combine과 SwiftUI를 import 하였습니다.
- *DecisionState* 를 enum 타입으로  가지고 있습니다.
- *JsonDecoder* 인스턴스를 가지고 있습니다.
- 빈 이니셜라이저와 몇 개의 빈 메서드가 있습니다.



### Implementing State

- SwiftUI는 뷰를 어떻게 렌더링 할 지 결정하는 state를 위해 몇 가지를 사용합니다. 아래의 코드를 추가하도록 합니다.

```Swift
@Published public var fetching: Bool = false
@Published public var joke: Joke = Joke.starter
@Published public var backgroundColor = Color("Gray")
@Published public var decisionState: DecisionState = .undecided
```

- 여기에는 몇 가지의 *@Published* 프로퍼티를 생성하여 각각에 대한 publisher와 합칠 것 입니다.
- @Published로 생성된 프로퍼티의 경우 접두사 `$` ($fetching) 을 사용하여 이러한 프로퍼티에 대한 publisher에 접근하는 것이 가능합니다. 그렇기 때문에 이것들의 명명은 그들의 목적을 가리킬 수 있게 해야 합니다. 



### Implementing services

```Swift
// JokesService.swift

import Foundation
import Combine

public struct JokesService {
	private var url: URL {
		urlComponents.url!
	}
	
	private var urlComponents: URLComponents {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "api.chucknorris.io"
		components.path = "/jokes/random"
		components.setQueryItems(with: ["category": "dev"])
		return components
	}
	
	public init() { }
}
```

- 우리는 chucknorris.io 데이터베이스에서 임의의 농담을 가져오는데 *JokesService* 를 사용할 것입니다. 이것은 또한 fetch 하여 반환된 데이터를 publisher에게 제공할 것입니다.
- 나중에 unit test에서 이 서비스를 가짜의 데이터로 체크하려면, publisher의 요구 사항을 정의하는 프로토콜 정의를 해야 합니다.

```Swift
// JokeServiceDataPublisher.swift

import Foundation
import Combine

public protocol JokeServiceDataPublisher {
	func publisher() -> AnyPublisher<Data, URLError>
}
```



<img width="498" alt="스크린샷 2020-11-03 오후 4 19 28" src="https://user-images.githubusercontent.com/48345308/97958336-59bf5500-1df0-11eb-9aa8-68dbeefa15e8.png">

- 이제 위와 같이 *JokesService* 에서 JokeServiceDataPublisher 프로토콜을 준수하고 프로토콜 안의 메서드를 구현합니다.



<img width="528" alt="스크린샷 2020-11-03 오후 4 22 43" src="https://user-images.githubusercontent.com/48345308/97958571-ce928f00-1df0-11eb-9474-25fc8e621bb2.png">

- *MokeJokesService* 에서도 JokeServiceDataPublisher 프로토콜을 준수하고 프로토콜 안의 메서드를 구현합니다.

  1) mock pulisher를 생성하고 *Data value* 를 방출하고 만약 실패시에는 URLError를 방출합니다. mock service안에 있는 data 프로퍼티를 가져와서 초기화 합니다.

  2) 제공되는 error 또는 또는 subject를 통해 데이터 값을 전달합니다.

  3) type-erased publisher를 리턴합니다.

- *DispatchQueue.asyncAfter(deadline:)* 를 사용하여 데이터를 가져오는데 약간의 지연을 시뮬레이션 할 수 있습니다.



### Finish implementing JokesViewModel

```Swift
// JokesViewModel.swift

private let jokesService: JokeServiceDataPublisher

public init(jokesService: JokeServiceDataPublisher = JokesService()) {
	self.jokesService = jokesService
  
  $joke
		 .map { _ in false }
		 .assign(to: &$fetching)
}
```

- view model은 기본 구현을 사용하는 반면에 unit test는 이 서비스의 모의 버전을 사용할 수 있습니다.
- 기본 구현을 사용하도록 이니셜라이저를 업데이트하도록 하겠습니다.
- $joke publisher에 subscription을 추가합니다.



### Fetching jokes

- 먼저 *fetchJoke()* 메서드를 구현하도록 하겠습니다.

<img width="418" alt="스크린샷 2020-11-03 오후 4 40 36" src="https://user-images.githubusercontent.com/48345308/97959724-4e215d80-1df3-11eb-8045-7be146571018.png">



1) *fetching* 프로퍼티를 true로 설정합니다.

2) jokesService publisher에 대해 subscription을 시작합니다.

3) 만약에 fetch에서 오류가 발생하면 한번 더 시도합니다.

4) publisher에게 전달 받은 data를 *decode* operator에 전달합니다.

5) 에러를 *Joke* 인스턴스로 변환하고 에러 메세지를 보여줍니다.

6) main queue에서 결과를 받습니다.

7) 수신한 joke를 해당 publisher에게 할당합니다.



### Changing the background color

- *updateBackgroundColorForTranslation(_:)* 메서드는 농담 카드 보기 위치에 따라서 backgroundcolor를 업데이트 합니다.

```Swift
public func updateBackgroundColorForTranslation(_ translation: Double) {
		switch translation {
		case ...(-0.5):
			backgroundColor = Color("red")
		case 0.5...:
			backgroundColor = Color("Green")
		default:
			backgroundColor = Color("gray")
		}
}
```

- 위의 코드를 통해 translation을 통해 -0.5(-50%) 까지는 빨간색을, 0.5(50%) 까지는 녹색, 그 외로는 회색을 반환하게 됩니다.
- 또한 농담 카드 뷰의 위치를 사용하여 사용자가 농담을 좋아하는지 여부를 결정하므로 *updateDecisionStateForTranslation(_:andPredectedEndLocationX:inBounds:)* 를 구현해야 합니다.



<img width="683" alt="스크린샷 2020-11-03 오후 4 50 35" src="https://user-images.githubusercontent.com/48345308/97960373-b45ab000-1df4-11eb-9612-0b1b8c40f8f0.png">

- 이 메소드는 translation과 x값을 이용하고 있습니다. 만약에 퍼센트가 -60인지 +60인지에 따라서 사용자의 결정으로 생각합니다.
- *x* 와 *bounds.width* 값을 사용하여 사용자의 의사결정 상태 영역 내에서 맴도는 경우 의사결정 상태의 변화를 방지하고 있습니다.
- 다시 말해서, 이러한 값을 초과하는 최종 위치를 예측하는 속도가 충분하지 않다면, 아직 결정을 내리지 않은 것이고 속도가 충분하다면 결정을 완료했다는 신호로 보고 있습니다.



### Preparing for the next joke

```Swift
public func reset() {
	backgroundColor = Color("gray")
}
```

- 사용자가 농담을 좋아하거나 싫어할 때, 농담 카드는 리셋되며 그 결과 다음 농담을 준비해야 합니다.
- 우리가 reset에서 다뤄야 할 부분은 배경색을 회색으로 바꾸는 것입니다.



### Making the view model observable

- 다음 단계로 넘어가기 전에 해야 할 일은, 앱 전체에서 observe할 수 있도록 이 view model을 *ObservableObject* 를 준수하게 하는 것입니다.
- ObservableObject는 자동으로 *objectWillChange* publisher를 가지고 있습니다.
- view model이 이 프로토콜을 준수하게 만들면 SwiftUI view는 view model의 *@Published* 프로퍼티를 subscribe할 수 있으며 프로퍼티가 변경되면 body를 업데이트 하는 것이 가능합니다.
- 아래와 같이 view model이 *ObservableObject* 를 준수하게 만듭니다!

```Swift
public final class JokesViewModel: ObservableObject
```



### Writing JokesViewModel up to the UI

- 앱의 메인 스크린에는 JokeView와 JokesCardView 두 개의 View component가 존재합니다.
- 두 view 모두 언제 업데이트 할 것인지, 무엇을 표시할 것인지를 결정하기 위해 view model를 참조할 필요가 있습니다.

<img width="418" alt="스크린샷 2020-11-03 오후 5 08 31" src="https://user-images.githubusercontent.com/48345308/97961741-34821500-1df7-11eb-8551-2790d9cc81aa.png">

- view model을 다루기 위해서 다음과 같이 *JokesViewModel* 타입의 프로퍼티를 선언했습니다.
- 이 프로퍼티는 *@ObservedObject* property wrapper와 함께 선언되었습니다. *ObservedObject* 와 함께 선언되어 이제 *objectWillChange* publisher를 받을 수 있게 되었습니다.
- 현재 이니셜라이저에 view model 파라미터가 없어서 오류가 발생하기 때문에 이것을 해결하도록 하겠습니다.

```Swift
struct JokeCardView_Previews: PreviewProvider {
	static var previews: some View {
		JokeCardView(viewModel: JokesViewModel())
			.previewLayout(.sizeThatFits)
	}
}
```

<img width="748" alt="스크린샷 2020-11-03 오후 5 18 27" src="https://user-images.githubusercontent.com/48345308/97962468-98f1a400-1df8-11eb-9039-7d076679f184.png">

- 위와 같이 변경을 한다면 스타터 농담을 사용하는 것에서 view model의 publisehr의 현재 값으로 전환됩니다.



### Setting the joke card's background color

<img width="600" alt="스크린샷 2020-11-03 오후 5 24 34" src="https://user-images.githubusercontent.com/48345308/97962902-73b16580-1df9-11eb-8b96-a4ee7a2d779e.png">

- view model이 농담 카드 뷰의 배경색을 결정하게 합니다.
- view model에서 배경 색은 translation에 따라서 색을 결정했습니다.



### Indicating if a joke was liked or disliked

- 그 다음으로는, 사용자가 농담을 좋아하는지 안좋아하는지에 대한 시각적인 것을 설정할 것입니다.

<img width="641" alt="스크린샷 2020-11-03 오후 5 29 05" src="https://user-images.githubusercontent.com/48345308/97963232-14078a00-1dfa-11eb-9aad-44752885d3fa.png">

- 위의 코드를 통해 liked 및 disliked 상태에 대한 올바른 이미지를 표시할 수 있으며, 상태가 undecision 될 때는 이미지를 표시하지 않습니다.



### Handling decision state changes

```Swift
private func updateDecisionStateForChange(_ change: DragGesture.Value) {
		viewModel.updateDecisionStateForTranslation(translation, andPredictedEndLocationX: change.predictedEndLocation.x, inBounds: bounds)
}

private func updateBackgroundColor() {
		viewModel.updateBackgroundColorForTranslation(translation)
}
```

- 위의 메소드는 view model의 *updateDecisionStateForTranslation()* 을 호출합니다.
- 이것은 농담 카드 view와 사용자의 상호작용을 기반으로 view에서 얻은 값을 전달합니다.
- 아래의 메서드는 view model의 메소드를 통해서 호출하며 농담 카드 view에서의 사용자 인터렉션을 기반으로 획득한 *translation* 값을 전달하고 있습니다.



### Handling when the user lifts their finger

- *handle(_:)* 메서드는 사용자가 손가락을 들어올릴때(터치하면서 위로 올릴 때)의 처리를 담당합니다.
- 만약에 사용자가 결정되지 않은 상태에서 터치하면서 올리면 joke view의 카드 위치가 재설정 됩니다.
- 마찬가지로, 사용자가 decided 상태에서 손가락을 위로 올리면 liked거나 disliked 거나 이것은 view model로 가서 reset 하고 새로운 농담을 가져옵니다.

<img width="781" alt="스크린샷 2020-11-03 오후 5 47 28" src="https://user-images.githubusercontent.com/48345308/97964776-a6109200-1dfc-11eb-8078-c27ac831d4f1.png">

1) view model의 현재 decisionState를 local에 새로운 프로퍼티로 복사하여 사용하도록 합니다.

2) 만약에 결정 상태가 *.undecided* 라면, *cardTranslation* 을 0으로 만들고 view model에게 reset하라고 알리며, 다시 배경 색을 회색으로 바꿉니다.

3) *.liked* 나 *.dliked* 의 경우에는 새로운 offset과 농담 view와 이것의 state를 기반으로 한 translation을 결정하고, 일시적으로 농담 카드 뷰를 숨깁니다.

4) 농담 카드 보기를 숨긴 다음 원래 다시 위치로 이동하는 *reset()* 을 호출하여 view model에 새로운 농담을 가져오라고 말한 다음 다음 농담 카드를 보여줍니다.



- 이 코드에는 아직 영향을 미치지 못하는 것이 2가지 있습니다.

  1) *cardTranslation* 프로퍼티는 농담 카드 view의 현재 translation을 추적합니다. 이 값과 현재의 화면 넓이로 변환을 계산한 다음에 다음 여러 영역의 view model에 결과를 전환하는 *translation* 과 혼동하면 안됩니다.

  2) 농담 카드 view의 초기 y의 offset 값은 -bounds 입니다. 이것은 보이는 바로 위에 위치하여 보여질 때 위에서 애니메이션으로 만드는 것이 가능합니다. (bound를 사용하여 animation 구현이 가능합니다.)



### Trying out your app

- 이제 스와이프 해서 왼쪽이나 오른쪽으로 움직일 수 있으며, 농담을 좋아하거나 싫어할 수 있습니다.



### Your progress so far

- 위의 문제에 대해 이러한 기능을 구현하는 곳을 살펴봅니다.

  1) 농담을 좋아하거나 혹은 싫어했다는 것을 보여주기 위해 농담 카드를 왼쪽이나 오른쪽으로 swipe할때 indicator를 확인합니다.

  3) 농담 카드를 오른쪽 왼쪽으로 swipe 했을 때 배경색이 빨간색과 초록색으로 잘 변하는지 확인합니다.

  4) 농담을 좋아하거나 싫어하고 난 후 새로운 농담을 가져옵니다.

  5) 새로운 농담을 가져올 때 indicator를 확인합니다.

  6) 농담을 가져오는 동안 문제가 생겼을 떄 어떻게 되는지 indicator를 봅니다.

- 이제 아래의 issue가 남았습니다.

  2) 나중에 보기위해 농담을 저장하기

  8) 저장된 농담을 보여주기

  9) 저장된 농담을 삭제하기



### Implementing Core Data with Combine

- Core Data stack을 설정하는 과정은 훨씬 쉬워졌으며, 새로 도입된 Combine과의 결합은 SwiftUI의 앱에서 데이터를 지속하기 위한 선택으로 굉장히 매력적입니다.



### Review the data model

- data model은 이미 생성되어 있습니다. 

<img width="589" alt="스크린샷 2020-11-03 오후 6 05 04" src="https://user-images.githubusercontent.com/48345308/97966370-1b7d6200-1dff-11eb-9e24-ccca12259b58.png">

- ID 속성에 대한 고유한 제약 조건과 함께 다음과 같이 어트리뷰트가 정의되어있는 것을 볼 수 있습니다.
- Core Data는 *JokeManagedObject* 에 대한 클래스 정의를 자동으로 생성합니다. 
- 그 다음으로, *JakeManagedObject* 의 컬렉션의 확장에 몇 가지 도움을 줄 수 있는 메서드를 만들어 농담을 저장하고 삭제할 수 있게 하겠습니다.



### Extending JokeManagedObject to save jokes

```Swift
// 1
import Foundation
import SwiftUI
import CoreData
import ChuckNorrisJokesModel

// 2
extension JokeManagedObject {
	// 3
	static func save(joke: Joke, inViewContext viewContext: NSManagedObjectContext) {
		// 4
		guard joke.id != "error" else { return }
		
		// 5
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>( entityName: String(describing: JokeManagedObject.self))
		
		// 6
		fetchRequest.predicate = NSPredicate(format: "id = %@", joke.id)
		
		// 7
		if let results = try? viewContext.fetch(fetchRequest),
		   let existing = results.first as? JokeManagedObject {
			existing.value = joke.value
			existing.categories = joke.categories as NSArray
		} else {
			
			// 8
			let newJoke = self.init(context: viewContext)
			newJoke.id = joke.id
			newJoke.value = joke.value
			newJoke.categories = joke.categories as NSArray
		}
		
		// 9
		do {
			try viewContext.save()
		} catch {
			fatalError("\(#file), \(#function), \(error.localizedDescription)")
		}
	}
}
```

1) Core Data, SwiftUI 그리고 model 모듈을 import 합니다.

2)  *JokeManagedObject* 클래스를 확장합니다.

3) 전달되는 view context을 사용하여 전달되는 농담을 저장하는 static 메서드를 생성합니다. Core Data에 익숙하지 않다면 view context를  Core Data 의 메모지라고 생각할 수 있습니다. 

4) 문제가 발생하는 시기를 나타내는 error joke에는 ID가 있습니다. 그 농담을 저장할 이유는 없으니, error가 발생한 농담이 저장되는 것을 조심해야 합니다.

5) *JokeManagedObject* 의 엔티티 이름을 가져오기 위한 요청입니다.

6) 전달된 농담으로 동일한 ID를 사용하여 농담을 가져오게 하기 위하여 요청을 설정합니다. 

7) fetch 요청을 위하여 *viewContext* 를 사용합니다. 성공하면 해당 농담이 이미 존재하므로 전달된 농담의 값으로 업데이트 합니다.

8) 그렇지 않다면, 아직 농담이 존재하지 않는 경우 전달된 농담의 값을 사용하여 새로운 농담을 만들게 됩니다.

9) *viewContext* 를 저장하기 위한 시도 입니다.



### Extending collections of JakeManagedObject to delete jokes

- 삭제하는 것을 쉽게 하기 위하여 *Collections* 에  *JokeManagedObject* 을 추가하겠습니다.

```Swift
extension Collection where Element == JokeManagedObject, Index == Int {
  // 1
  func delete(at indices: IndexSet, inViewContext viewContext: NSManagedObjectContext) {
    
	// 2
	indices.forEach { index in
	  viewContext.delete(self[index])
	}
	
	// 3
	do {
	  try viewContext.save()
	} catch {
	  fatalError("\(#file), \(#function), \(error.localizedDescription)")
	}
 }
```

1)  전달된 viewContext를 사용하여 index에서 객체를 삭제하는 메서드를 구현합니다.

2) indices를 순환하고 *viewContext* 에서 delete 메서드를 호출하여 자신의 각 요소를 전달합니다.

3) context를 저장하려는 시도를 합니다.



### Create the Core Data Stack

- Core Data Stack을 설정하는 것에는 몇 가지 방법이 있습니다.
- access 제어를 이용하여 *SceneDelegate* 만이 접근 할 수 있는 stack을 생성하겠습니다.

```Swift
// 1
private enum CoreDataStack {
	
	// 2
	static var viewContext: NSManagedObjectContext = {
		let container = NSPersistentContainer(name: "ChuckNorrisJokes")
		
		container.loadPersistentStores { _, error in
			guard error == nil else {
				fatalError("\(#file), \(#function), \(error!.localizedDescription)")
			}
		}
		
		return container.viewContext
	}()
	
	// 3
	static func save() {
		guard viewContext.hasChanges else { return }
		
		do {
			try viewContext.save()
		} catch {
			fatalError("\(#file), \(#function), \(error.localizedDescription)")
		}
	}
}
```

1) CoreDataStack을 private enum으로 정의합니다. enum을 사용하는 것은 CoreDataStack은 인스턴스화 하지 않고 namespace 역할만을 하기 때문에 유용합니다.

2) 영구적인 container를 생성합니다. 관리되어지는 object context, 영구 저장소 coordinator 및 관리되는 object model을 캡슐화하는 실제 Core Data Stack 입니다. 우리는 SwiftUI의 *Environment API* 를 사용할 것이고 앱 전체에서 이 context를 공유할 수 있습니다.

3) scenedelegate 에서 context를 저장하는데 사용할 수 있는 static save 메서드를 생성합니다. 저장 작업을 시작하기 전에 context가 변경되었는지 확인하는 것은 좋은 생각입니다.



<img width="925" alt="스크린샷 2020-11-03 오후 6 42 31" src="https://user-images.githubusercontent.com/48345308/97970092-5766f600-1e04-11eb-96a1-df3976a841ec.png">

- *environment* 를 사용하여 Core Data Stack의 view context를 추가하였고 어디서든지 사용할 수 있게 되엇습니다.
- 앱이 background로 이동하려고 할 때 viewContext를 저장하는 경우에 따로 작업을 하지 않으면 모든 작업이 손실됩니다.
- *sceneDidEnterbackground(_:)* 메서드에서 저장해주는 작업이 필요합니다.

```Swift
CoreDataStack.save()
```



### Fetching jokes

```Swift
// JokeView.swift

@Environment(\.managedObjectContext) private var viewContext
```

- *environment* 로부터 viewContext를 다루기 위해 다음과 같이 프로퍼티를 정의합니다.

<img width="605" alt="스크린샷 2020-11-03 오후 6 46 35" src="https://user-images.githubusercontent.com/48345308/97970453-e8d66800-1e04-11eb-80fa-e2d7be119088.png">

- 위와 같이 사용자가 농담을 좋아하는 것을 확인하고 그렇다면, 해당 메서드를 통해서 environment에서 얻은 view context를 사용하여 이를 저장하도록 합니다.



### Showing saved jokes

<img width="550" alt="스크린샷 2020-11-03 오후 6 49 19" src="https://user-images.githubusercontent.com/48345308/97970713-4965a500-1e05-11eb-958d-fb0149e239e8.png">



- 다음과 같이 *sheet*  modifier를 통해서 NavigationView의 코드 블럭에 추가합니다.
- 이 코드은 $presentedSavedJokes가 새로운 값을 내보낼때마다 트리거 됩니다.
- 값이 true가 되면, 저장된 농담 보기 인스턴스화해서 표시하고, 해당 view context를 전달합니다.



### Finishing the saved jokes view

```Swift
// SavedJokesView.swift

@Environment(\.managedObjectContext) private var viewContext
```

- 위의 파일에 똑같이  프로퍼티를 선언해줍니다.

<img width="500" alt="스크린샷 2020-11-03 오후 6 55 31" src="https://user-images.githubusercontent.com/48345308/97971290-27b8ed80-1e06-11eb-9eb5-6a7ced535d0a.png">

- 가져온 객체를 정렬하고 업데이트 하기 위해서 *sortDescription* 배열을 사용하고 있으며 지정된 애니메이션과 함께 목록을 표시합니다.
- 영구 저장소가 변경될 때마다 자동으로 가져오기를 수행해서 view를 트리거하고 업데이트 된 데이터로 다시 렌더링 하는 것이 가능해집니다.
- *FetchResult* 의 이니셜라이저를 변경하여 이전에 만든 것과 같이 FetchRequest를 전달하는 것이 가능합니다. 



### Deleting jokes

<img width="600" alt="스크린샷 2020-11-03 오후 7 00 38" src="https://user-images.githubusercontent.com/48345308/97971760-de1cd280-1e06-11eb-93dd-d32639821ab1.png">

1) 농담을 보여주고 농담이 없다면 "N/A" 를 보여줍니다.

2) 앞에서 정의한 *delete(at: inviewContext:)*  메서드를 호출하여 삭제를 합니다.



- 앱을 실행해보면 몇 가지의 농담이 있으며, *Show Saved* 버튼을 클릭하면 저장되어 있는 농담들을 보여줍니다. 
- 왼쪽으로 스와이핑하면 농담을 삭제하는 것이 가능합니다. 



### Challenge : Write unit tests against JokesViewModel

- 샘플 농담을 검증할 수 있는 *test_createJokesWithSampleJokeData* 라는 unit test를 만들어 보는 것입니다.

```Swift
func test_createJokesWithSampleJokeData() {
		// Given
		guard let url = Bundle.main.url(forResource: "SampleJoke", withExtension: "json"),
			  let data = try? Data(contentsOf: url)
		else {
			return XCTFail("SampleJoke file missing or data is corrupted")
		}
		
		let sampleJoke: Joke
		
		// When
		do {
			sampleJoke = try JSONDecoder().decode(Joke.self, from: data)
		} catch {
			return XCTFail(error.localizedDescription)
		}
		
		// Then
		XCTAssert(sampleJoke.categories.count == 1, "Sㄴㄴample joke categories.count was expected to be 1 but was \(sampleJoke.categories.count)")
		XCTAssert(sampleJoke.value == "Chuck Norris writes code that optimizes itself.", "First sample joke was expected to be \"Chuck Norris writes code that optimizes itself.\" but was \"\(sampleJoke.value)\"")
}
```







