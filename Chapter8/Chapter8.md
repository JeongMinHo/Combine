# Chapter 8: In Practice: "College"



- 이전에 챕터에서 우리는 *publisher, subscriber, operator* 들에 대해서 배웠습니다.
- 이번에는 실제 iOS 앱을 가지고 이런 기술들을 다루는 시간을 가지도록 하겠습니다.
- 이 프로젝트는 Collage라고 불리며 사용자에게 자신의 사진으로 간다한 콜라주를 만들 수 있도록 해주는 iOS 앱입니다.



1) Combine publisher를 UIKit view controller에서 사용할 것입니다.

2) Combine으로 사용자 이벤트를 다룰 것 입니다.

3) publisher를 통해서 view controller 끼리 데이터를 주고 받을 것입니다.

4) 다양한 operator를 사용해서 앱의 로직에 실행하는 다른 subscription을 생성할 것입니다.

5) 존재하는 Cocoa API를 wrapping해서 Combine 코드에 사용하기 쉽게 할 것입니다.



### Getting started with "Collage"

- 프로젝트는 간단합니다. 
- 콜라주를 미리보고 생성할 수 있는 main view controller가 있고 사용자가 사진을 선택해서 현재의 콜라주를 추가하나 view controller가 있습니다.

<img width="462" alt="스크린샷 2020-10-28 오후 4 45 33" src="https://user-images.githubusercontent.com/48345308/97406713-00ad7800-193d-11eb-83ab-c8de227f47dc.png">

- 현재 이 프로젝트에는 앞에서 언급했던 어떠한 로직도 없습니다. 그러나 여기에는 이미 이용할 수 있는 코드가 있기 때문에  Combine과 관련된 코드에만 집중하면 됩니다.

<img width="576" alt="스크린샷 2020-10-28 오후 4 47 45" src="https://user-images.githubusercontent.com/48345308/97406943-4ff3a880-193d-11eb-9559-b77dd095710b.png">

- 위와 같이 MainViewController에 Combine을 import 하고 2개의 private 프로퍼티를 만들었습니다.
- *subscriptions* 는 현재 view controller의 life cycle에 연결된 UI subscription을 저장하는 컬렉션입니다.
  - 이러한 subscription은 현재 뷰 컨트롤러의 life cycle에 연결하여 필요로 하는 UI control을 바인딩하기 위해 필요한 것 입니다.-
  - 현재는 view controller가 navigation stack에서 pop 되거나 dismiss 되면 모든 UI subscription들은 취소 됩니다.
- 우리는 사용자가 콜라주에서 사진을 선택했음을 알리기 위해 *image* 를 사용합니다. UI control에 데이터를 바인드 할 때, *PassthroughSubject* 대신에 *CurrentValueSubject* 를 자주 사용하고는 합니다.
  - *PassthroughSubject* 의 경우 *send()* 를 통해 필요에 따라 새로운 값을 게시합니다. 이때 broadcast 하기 때문에 해당 subject를 subscribe하고 있는 모든 subscriber에게 값을 보내게 됩니다.
  - CurrentValueSubject는 subscription에서 적어도 하나의 값이 전송되고(초기값과 함께 생성되야 하기 때문에) UI가 정의되지 않은 상태가 되지 않도록 보장해주기 때문입니다.

<img width="623" alt="스크린샷 2020-10-28 오후 4 54 42" src="https://user-images.githubusercontent.com/48345308/97407619-4880cf00-193e-11eb-96df-2bb5ee85724a.png">

- 위와 같이 button을 클릭하면 이미지를 얻어서 collage에 추가해주는 코드를 작성해보았습니다.
- 이렇게 되면 사용자가 + 버튼을 누르면 Asset에 있는 "IMG_1907.jpg" 파일을 찾게 됩니다.
- 현재 선택한 사진을 지우기 위해서는 *actionClear()* 에 다음과 같이 추가하면 됩니다.

```Swift
images.send([])
```

<img width="582" alt="스크린샷 2020-10-28 오후 5 00 26" src="https://user-images.githubusercontent.com/48345308/97408164-1459de00-193f-11eb-9972-ea3a6a93efff.png">

1) 현재 photos의 collection에서 subscription을 시작합니다.

2) *map* 을 사용하여 각각의 *UIImage.collage(image:size:)* 를 단일 콜라주로 만들었습니다.

3) *assign(to:on)* subscriber를 사용하여 결과 콜라주 이미지를 디바이스의 중앙에 있는 이미지 뷰인  *imagePrevie.image* 에 바인딩하였습니다.

4) 마지막으로 subscription의 결과를 subscriptions 에 저장하여 controller 보다 일찍 취소되지 않은 경우에는 해당 것은 view controller와 연결하였습니다.

<img width="280" alt="스크린샷 2020-10-28 오후 5 07 41" src="https://user-images.githubusercontent.com/48345308/97408880-196b5d00-1940-11eb-9e74-a87c3edacee0.png">

- 그 결과 클릭을 할 때마다 사진들이 추가되는 것을 볼 수 있습니다.
- 간단하게 바인딩을 할 수 있는 *assign* 을 통해서 photos collection을 얻어와 이것을 image view에 할당할 수 있게 해주는 것입니다.
- 하지만 보통은 하나의 UI Control이 아닌 몇 개를 업데이트 해야 합니다. 따라서 각각의 바인딩마다 분리된 subscription을 생성하는 것은 때때로는 지나칠 수 있습니다.
- 이번에는 단일 배치로 여러 가지 업데이트를 수행할 수 있는 방법에 대해서 알아보도록 하겠습니다.

```Swift
// MainViewController.swift

private func updateUI(photos: [UIImage]) {
		buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
		buttonClear.isEnabled = photos.count > 0
		itemAdd.isEnabled = photos.count < 6
		title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
}
```

- 다양한 UI 업데이트를 하고 있으며 현재 선택 항목에 홀수 사진이 포함되어 있으면 버튼을 비활성화하고, 콜라주 등이 진행 중일 때는 지우기 버튼을 활성화 하는 코드입니다.
- *updateUI(photos:)* 를 사용자가 콜라주에 사진을 추가할때마다 호출하기 위해서 우리는 *handleEvents operator* 를 사용할 것입니다.

![스크린샷 2020-10-29 오후 3 06 17](https://user-images.githubusercontent.com/48345308/97531799-5135db80-19f8-11eb-8a44-a9fa13a55d87.png)

- *handleEvents* 의 경우에는 publisher event가 발생할 때마다 수행되기 때문에 UI 업데이트, 로깅 등의 부작용을 수행할 때마다 사용할 수 있는 opeartor입니다.

<img width="462" alt="스크린샷 2020-10-28 오후 5 15 45" src="https://user-images.githubusercontent.com/48345308/97409574-38b6ba00-1941-11eb-9018-a4306ed5d351.png">

- 프로젝트를 다시 실행해 보면 2개의 버튼이 비활성화 되어 있는 것을 볼 수 있습니다.
  - 사진을 추가하고 짝수의 사진을 추가해야지만 2개의 버튼이 모두 활성화 되게 됩니다.
  - 이 버튼들은 사진을 현재 콜라주에 추가할때마다 state가 바뀌게 됩니다.

<img width="313" alt="스크린샷 2020-10-28 오후 5 18 50" src="https://user-images.githubusercontent.com/48345308/97409874-a6fb7c80-1941-11eb-8e8b-3062988a0a1f.png">



### Talking to other view controllers

- UI의 데이터를 *subject* 를 통해서 얼마나 쉽게 스크린의 control과 binding을 할 수 있는지에 대해 보았습니다.
- 이제는 새로운 뷰 컨트롤러를 표시하고 사용자가 이 controller를 사용한 후에 데이터를 복구하는 작업을 수행해 보도록 하겠습니다.
- 두 view controller 사이에 데이터를 교환한다는 일반적인 생각은 view controller에서 *subject* 를 사용하여 subscribing 하는것과 같습니다.

```Swift
let photos = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
navigationController!.pushViewController(photos, animated: true)
```

- 위와 같은 코드를 통해 PhotosViewController를 네비게이션 스택에 push하는 것이 가능합니다.

<img width="708" alt="스크린샷 2020-10-28 오후 5 37 34" src="https://user-images.githubusercontent.com/48345308/97411972-4588dd00-1944-11eb-9b92-56dd361b2116.png">

- PhotosViewContorller의 viewDidLoad에 보면 카메라 롤에서 사진을 로드하고 이것을 collectionView 보여주는 코드가 이미 작성되어 있습니다.
- 그 다음 작업은 *subject* 를 view controller에 추가하고 Camerawomen Roll list에서 사용자가 탭을 하는 이미지를 보내는 것입니다.

<img width="601" alt="스크린샷 2020-10-28 오후 5 42 27" src="https://user-images.githubusercontent.com/48345308/97412457-f3948700-1944-11eb-879d-1d637c773d23.png">

- 이 코드는 현재 타입에서  *selectedPhotosSubject* 를 사용하여 값을 보내는 반면에 selectedPhotos는 *type-erased* 으로 subscribe할때 접근만할 수 있게 해줍니다.

  - 이번에는 collection view delegate와 이 subject를 연결해보도록 하겠습니다.

  ```Swift
  // UICollectionViewDelegate안의 didSelectItemAt 메서드
  
  self.selectedPhotosSubject.send(image)
  ```

  - delegate 메서드에서 탭으로 표시된 collection cell을 날린 다음에 다음 디바이스 라이브러리에서 사진  asset을 fetch 합니다.
  - 위의 코드를 추가하여 사진이 준비가 되면 subject를 사용하여 subscriber들에게 이미지를 보낼 수 있습니다.

- 다른 타입들에게 subject를 노출하고 있기 때문에 외부의 subscription을 해제하기 위해 view controller가 dismiss 하는 경우 완료 이벤트를 명시적으로 보내도록 하겠습니다.

- 아래와 같이 view controller가 사라질 시에 코드를 추가하면 됩니다.

<img width="442" alt="스크린샷 2020-10-28 오후 5 49 33" src="https://user-images.githubusercontent.com/48345308/97413286-f17ef800-1945-11eb-9ba0-57c9b99883a8.png">



<img width="472" alt="스크린샷 2020-10-28 오후 5 53 12" src="https://user-images.githubusercontent.com/48345308/97413718-74a04e00-1946-11eb-9f4b-d313f25af7c0.png">

1) 현재 선택된 이미지들의 리스트를 가져와 새로운 이미지를 추가해줍니다.

2) *assign* 을 사용하여 images subject를 통해 업데이트 된 이미지를 보냅니다.

3) subsriptions에 새로운 subscription을 저장합니다. 그러나 subscription은 보여지는 view controller라 사용자가 dismiss할때마다 등록이 종료됩니다.

<img width="228" alt="스크린샷 2020-10-28 오후 6 07 35" src="https://user-images.githubusercontent.com/48345308/97415375-7703a780-1948-11eb-97a0-7a931fd9de18.png">

- 앱을 실행하고 + 버튼을 누르면 다음과 같이 사진첩에 접근할 수 있는지를 물어보는 화면이 뜨게 됩니다.

<img width="280" alt="스크린샷 2020-10-28 오후 6 08 29" src="https://user-images.githubusercontent.com/48345308/97415440-969ad000-1948-11eb-9641-f1b8f770eb7f.png">

- collection view를 reload하고 iOS simulator의 default 사진들이 보이게 됩니다.
- 사진을 선택하면 아래와 같이 사진이 콜라주에 추가되는 것을 볼 수 있습니다.

<img width="305" alt="스크린샷 2020-10-28 오후 6 11 47" src="https://user-images.githubusercontent.com/48345308/97415850-0c9f3700-1949-11eb-867b-4f877c022751.png">



### Wrapping a callback function as a future

- 이번에는 custom publisher를 어떻게 생성하는지에 대해서 알아보겠습니다.  그러나 많은 경우에서  Cocoa 클래스에 존재하는 subject를 추가하는 것은 Combine 워크플로우에 충분합니다.
- 이 챕터에서는 새로운 custom type인 PhotoWriter과 함꼐 사용자의 콜라주를 저장할 수 있게 해보도록 하겠습니다.
- 콜백 기반의 사진 API를 사용하여 저장을 할 수 있으며 future는 다른 타입이 operation 결과에 subscribe 할 수 있도록 할 것입니다.

```Swift
// PhotoWritier.swift

import Foundation
import UIKit
import Photos
import Combine

class PhotoWriter {
	enum Error: Swift.Error {
		case couldNotSavePhoto
		case generic(Swift.Error)
	}
	
	static func save(_ image: UIImage) -> Future<String, PhotoWriter.Error> {
		return Future { resolve in

		}
	}
}
```

- 위의 함수는 주어진 이미지를 디스크에 비동기적으로 저장하여 이 API의 소비자가 subscribe할 future를 반환하려는 함수입니다.

- 위의 파일에 다음과 같이 코드를 추가하도록 하겠습니다.

<img width="674" alt="스크린샷 2020-10-28 오후 6 19 53" src="https://user-images.githubusercontent.com/48345308/97416740-2e4cee00-194a-11eb-8fc8-42b9fb4e039f.png">

- 여기에서 *PHPotoLibrary.perfomrChangesAndWiat()* 을 사용하여 photo library에 동기적으로 접근하고 있습니다. 

- *future* 클로저는 그 자체로 비동기적으로 실행되기 때문에 메인 스레드를 차단할 염려는 없습니다.

  1) store image를 요청을 생성하였습니다.

  2) reqeuset의 identifier를 통해서 새로 생성된 것을 가져오려고 시도하고 있습니다.

  3) 생성이 실패한다면 assetId를 다시 가져오지 못했고 *PhotoWiriter.Error.couldNotSavePhoto* 에러를 리턴하고 있습니다.

  4) *savedAssetID* 를 찾았을 경우에는 가져오는 것을 성공한 것입니다.



- 이번에는 사용자가 save 버튼을 클릭했을 때 현재의 콜라주를 저장하기 위하여 아래와 같이 구현하겠습니다.

<img width="734" alt="스크린샷 2020-10-28 오후 6 29 33" src="https://user-images.githubusercontent.com/48345308/97417879-8801e800-194b-11eb-94a8-574721f8f894.png">

1) *PhotoWriter.save* 를 subscribe하고 *sink(receiveCompletion: receiveValue:)* 를 사용하였습니다.

2) completion이 실패했을 경우에는 *showMessage()* 를 통해서 alert를 스크린에 보여줍니다.

3) 새 asset id를 받은 경우에는 *showMessage* 를 통해 콜라주가 성공적으로 저장되었음을 알립니다.

- 성공시에 아래와 같이 alert가 뜨는 것을 볼 수 있습니다.

<img width="280" alt="스크린샷 2020-10-28 오후 6 33 46" src="https://user-images.githubusercontent.com/48345308/97418392-1ecea480-194c-11eb-8416-0951801770df.png">



### A note on memory management

- Combine 코드가 비동기적으로 실행되는 많은 클로저를 처리해야 되며, 그러한 클로저는 항상 클래스들을 다룰 때 번거롭다는 것을 알 수 있습니다.
- custom Combine 코드를 작성할 때 주로 구조체를 사용하여 처리할 수 있으므로, 클로저에서 값을 캡처할 때 명시적으로 보여줄 필요는 없습니다.
- 하지만 UIViewContoller 등과 같은 UI 코드를 다룰때는 클래스로 작업을 해야 합니다.
- 만약 PhotosViewController 처럼 메모리에서 해제될 수 있는 객체를 캡처하는 경우에는, 다른 객체에서 캡처할 때 [weak self]와 변수를 캡처할때 self를 명시해야 합니다.
- 만약 캡처링 하는 객체가 해제 되지 않는다면 Main view controller처럼, 우리는 [unowned self]를 사용하는 것이 좋습니다. 예를들어 항상 보여지므로 navigation stack에서 해제 되지 않는 경우에!



### Presenting a view controller as a future

- 이미 두 작업은 완료 되었습니다.

  1) UI 없는 콜백 함수는 *future* 로 wrap 하기

  2) 수동으로 view controller를 present하고 publisher 중 하나의 subscribed 하기

- 이번에는 *future* 를 사용하여 새로운 view controller를 present 하고 사용자가 future를 끝낼때 까지 기다리도록 하겠습니다.

```swift
import UIKit
import Combine

extension UIViewController {
	func alert(title: String, text: String?) -> AnyPublisher<Void, Never> {
		let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
	}
}
```

- 위의 메서드는 사용자가 Close를 탭하면 값을 반환하는데에는 관심이 없고 완료에만 관심이 있으므로 *AnyPublisher<Void, Never>* 를 리턴합니다 
- 이제 alert를 화면에 보여주고 future가 완료되면 이것을 dismiss 합니다.

```Swift
import UIKit
import Combine

extension UIViewController {
	func alert(title: String, text: String?) -> AnyPublisher<Void, Never> {
		let alertVC = UIAlertController(title: title,
										message: text,
										preferredStyle: .alert)
		
		return Future { resolve in
			alertVC.addAction(UIAlertAction(title: "Close",
											style: .default) { _ in
				resolve(.success(()))
			})
			self.present(alertVC, animated: true, completion: nil)
		}
		.handleEvents(receiveCancel: {
			self.dismiss(animated: true)
		})
		.eraseToAnyPublisher()
	}
}
```

- Future를 생성하여 Close 버튼을 subscription에 추가하고 alert를 스크린에 보여줍니다. 
- 사용자가 버튼을 탭한다면 success를 future를 해결합니다.
- 이 코드를 테스트해보기 위해 *showMessage* 안에 아래와 같은 코드를 추가합니다.
  <img width="656" alt="스크린샷 2020-10-28 오후 6 58 56" src="https://user-images.githubusercontent.com/48345308/97421239-a2d65b80-194f-11eb-8aae-48af99d6ba8f.png">

- 위와 같이 해도 이전과 같이 행동하는 것을 볼 수 있으며. 이것은 Combine 코드로 변경된것입니다.



### Sharing subscriptions

- actionAdd의 코드로 돌아가 보면 PhotosViewController에서 사용자가 선택한 이미지들로 몇 가지 더 많은 것을 할 수 있습니다.
- 만약에 똑같은 사진을 여러번 photos.selectedPhotos에 subscribe 하면 다른 일을 하는가?
  - 같은 publisher에 subscribe 하는 것은 side effect가 생길 수 있습니다.
  - subscribe하고 나면 publisher가 무엇을 하는지 모를 것입니다.
  - 새로운 자원을 만들거나, 네트워크 요청을 하거나 다른 무언가를 할 수도 있습니다.

<img width="484" alt="스크린샷 2020-10-28 오후 10 50 48" src="https://user-images.githubusercontent.com/48345308/97444933-06708100-1970-11eb-97ef-165fd21294f7.png">

- 동일한 publisher에 여러 subscription이 생길 때 올바른 방법은 publisher는 *share()* operator를 사용해 원래 publisher를 공유하는 것입니다.
- 이것은 publisher를 클래스로 감싸고, 따라서 이것은 여러 subscriber에게 안전하게 내보낼 수 있습니다.
- 아래와 같이 수정을 해보도록 하겠습니다.

![스크린샷 2020-10-28 오후 10 53 20](https://user-images.githubusercontent.com/48345308/97445238-636c3700-1970-11eb-9ac3-6224316fcdbd.png)

<img width="527" alt="스크린샷 2020-10-28 오후 10 54 10" src="https://user-images.githubusercontent.com/48345308/97445335-7ed74200-1970-11eb-98ff-2dbfb4552823.png">

- 위와 같이 수정을 하게 되면 이제 여러 subscription에 대하여 side effect가 일으킬 걱정 없이 *newPhotos* subscribe를 여러 개 만드는 것이 안전합니다.
- 만약 2개의 subscription을 *share()* 에 가지고 있고, source publisher가 동시에 subscribing을 방출하는 경우에, 두 번째 subscriber가 subscribe할 기회를 가지기 전에 첫 번째 subscriber에게만 초기 출력 값을 전송하게 됩니다. (만약 source publisher가 비동기적으로 발산했다면 문제가 되지 않았을 것입니다.)
- 그 문제에 대한 해결책은 새로운 subscriber가 subscribe할 때 과거의 값을 다시 보내거나 재생하는 *sharing operator* 를 만드는 것입니다.
- 나만의 operator를 만드는 것은 복잡하지 않습니다. 이것은 18장에서 배우도록 하겠습니다..



### Publishing properties with @Published

- Combine 프레임워크는 swift 5.1에서 도입된 새로운 기능인 *property wrapper* 를 도입했습니다. *property wrapper* 는 단순히 해당 선언에 @를 추가함으로써 property에게 동작을 추가할 수 있습니다.
- Combine은 두 가지의 property wrapper를 제공합니다. *@Published and @ObservedObject*
- *@Published* property wrapper는 property의 값이 변경될 때마다 새로운 값을 보내 publisher를 자동으로 추가할 수 있습니다.
- 아래와 같이 선언할 수 있습니다. SwiftUI에서 이용해보았습니다!

```Swift
struct Person {
  @Published var age: Int = 0
}
```

- 이것은 평범한 프로퍼티와 똑같이 행동합니다. 값을 가져오거나 값을 명령적으로 설정할 수 있습니다.
- $age는 에러를 내지 않는 publisher로 age 프로퍼티와 같은 타입의 결과 입니다. 이 age 값을 변경할 때마다, $age는 새로운 값을 보냅니다.
- publisher를 자동으로 생산하는 것은 API의 사용자에게 실시간으로 데이터의 변화를 subscribe 할 수 있는 기능을 쉽게 제공합니다.

```Swift
var selectedPhotoCount = 0

self.selectedPhotoCount += 1

@Published var selectedPhotoCount = 0
```

- 만약에 다음과 같이 프로퍼티를 설정하고 collectionView의 delegate 메서드인 *didSelectItemAt()* 이 클릭될때마다 이 값을 1 증가시킨다면 이것을 *subscribe* 할 수는 없을 것입니다.
- 만약에 마지막 같이 선언한다면 컴파일러는 publisher에게 *$selectedPhotosCount* 라는 프로퍼티를 호출하게 할 것입니다.

![스크린샷 2020-10-28 오후 11 20 34](https://user-images.githubusercontent.com/48345308/97448617-30c43d80-1974-11eb-863e-a020ee1f7783.png)

- 위와 같이 *photos.$selectedPhotosCount* 를 subscribe 하고 view controller의 title프로퍼티에 이름 바인딩 합니다.
- *"binding"* 이라는 명사는 subscription의 본질을 잘 설명하고 있으며 "assigning" 보다는 좋은 표현입니다. 
- publisher의 output을 특정 인스턴스 속성에 바인딩 합니다. 

- 그 결과 아래와 같이 title이 변하는 것을 알 수 있습니다.

<img width="359" alt="스크린샷 2020-10-28 오후 11 24 56" src="https://user-images.githubusercontent.com/48345308/97449225-cc55ae00-1974-11eb-989c-5d9909592e75.png">



### Updating the UI after the publisher completes

- 현재 일부 사진을 누르면 main view controller의 title에 몇 개의 사진을 선택했는지 표시하게 합니다.
- 이것은 유용하지만 콜라주에 실제로 얼마나 많은 사진이 추가되었는지 보여주는 title이 있으면 편리합니다.

![스크린샷 2020-10-28 오후 11 28 19](https://user-images.githubusercontent.com/48345308/97449672-45550580-1975-11eb-8db9-ed1fb21c504b.png)

1) *ignoreOutput()* 은 내보내는 값을 무시하며 subscriber에게 completion event만 제공합니다.

2) *delay(for:scheduler:)* 은 지정된 시간을 기다립니다. 이렇게 하면 몇 초 후에 "() photos selected" 라는 이전의 메세지를 제공하며 선택한 총 사진의 양으로 전화하기 전에 사용자에게 얼마나 많은 사진을 선택했는지 알려줍니다.

3) *sink(receiveCompletion)* 은 updateUI(photos:) 를 호출하며 기본 controller title로 업데이트 합니다.

<img width="329" alt="스크린샷 2020-10-29 오후 3 27 06" src="https://user-images.githubusercontent.com/48345308/97533246-37e25e80-19fb-11eb-8bc8-5c86b12fc4cc.png">



### Accepting values while a condition is met

![스크린샷 2020-10-28 오후 11 34 17](https://user-images.githubusercontent.com/48345308/97450447-1ab77c80-1976-11eb-9442-a3fd312d3e54.png)

- 강력한 Combine의 필터링 operator 중 하나로서 *prefix(while:)* 을 배웠으며 이를 사용하고 있습니다.
- 이 코드는 selectedPhotos의 subscription을 유지하면서 수가 6개 미만인 경우에 계속 활성화 합니다.
- *share()* 을  *prefix(while:)* 이전에 추가하면 newPhotos에 subscribe 하는 모든 subscriptions에 대해 값들을 필터링 할 수 있습니다.
- 이제 앱을 실행하고 나면 6장 이후에는 view controller가 더 이상 수용하지 않는 것을 알 수 있습니다.



### Challenge 1: Try more operators

- 제공된 콜라주 기능을 구현하면 세로 사진 추가를 제대로 처리하지 못하므로, newPhotos publisher의 *addAction()* 에 filter를 추가하여 모든 이미지를 세로로 필터링 합니다.
- filter opertor를 사용하여 *image.value* 에서 선택한 총 이미지의 현재 수가 5인 경우에 사용합니다.
- *flatMap* 을 사용하여 사용자에게 최대 사진 개수에 도달했음을 알리는 alert를 표시하고 닫기 버튼을 탭할때 까지 기다립니다.
- *sink* 메서드를 사용하여 네비게이션 스택에 photos view controller를 pop 합니다.

```swift
photos.selectedPhotos
			.filter { [weak self] _ in
				self?.images.value.count == 5 }
			.flatMap { [weak self] _ in
				(self?.alert(title: "Limited reached", text: "To add more than 6 photos please purchase Collage Pro"))!
			}
			.sink { [weak self] _ in
				self?.navigationController?.popViewController(animated: true)
			}
			.store(in: &subscriptions)
```

<img width="328" alt="스크린샷 2020-10-29 오후 1 13 03" src="https://user-images.githubusercontent.com/48345308/97524631-7e7a8d80-19e8-11eb-8172-0cc8f09eb1ed.png">



### Challenge 2: PHPhotoLibrary authorization publisher

<img width="280" alt="스크린샷 2020-10-29 오후 1 35 46" src="https://user-images.githubusercontent.com/48345308/97526052-a7505200-19eb-11eb-9919-26026a8565b2.png">

- 이번 challenge 에서는 PHPhotoLibray에 isAuthorized라는 static property를 추가합니다. 이 프로퍼티는 Future<Bool,Never> 타입이며 PhotoLibrary Authroization status에 subscribe할 수 있도록 하면 됩니다.
- 현재는 앱의 사진을 가져올 수 없는 상태가 되면 다음과 같이 빈 화면이 뜹니다. 이를 해결해보도록 하겠습니다.

```Swift
static var isAuthorized: Future<Bool, Never> {
		return Future { resolve in
			self.fetchAuthorizationStatus { status in
				resolve(.success(status))
			}
		}
	}
```

- 다음과 같이 isAuthorized다른 static 프로퍼티를 만들었고 Future<Bool, Never> 타입입니다.

```Swift
// PhotosViewController.swift

PHPhotoLibrary.isAuthorized
		  .sink { [weak self] isAuthorized in
			if isAuthorized {
			  self?.photos = PhotosViewController.loadPhotos()
			  self?.collectionView.reloadData()
			} else {
			  self?.showErrorMessage()
			}
		  }
		  .store(in: &subscriptions)
```

- PhotosViewController에 viewDidLoad에 다음과 같이 subscriber와 publisher를 연결합니다. 그래서 isAuthorized 값이 true라면 photos를 받아와 collectionview에 load 해주고 아니라면 alert를 통해 errormessage를 보여주게 만듭니다.

  <video src="/Users/user/Library/Application Support/typora-user-images/화면 기록 2020-10-29 오후 1.48.28.movd= d"></video>

