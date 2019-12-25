# Observable

Provides a simple observable binding for implementing MVVM-style architectures. This is inspired by approaches like [`LiveData`](https://developer.android.com/topic/libraries/architecture/livedata) from the Android Architecture components.

Ultimately you will want to consider using the Combine framework which provides a first party implementation of Rx patterns but this is only available in iOS 13 and later. This provides some of the benefits but with a much smaller footprint than RxSwift.

## Usage

```
struct NameViewModel {
    let firstName = Observable("")
}

// To observe changes
bindObservable(nameViewModel.firstName) { oldValue, newValue in
    println("Changed from \(oldValue)")
    nameLabel.text = newValue
}
```

There are a few additional options available to you.

To be given the initial value after binding has been completed:

```
bindObservable(nameViewModel.firstName, initial: true) { oldValue, newValue in
    // oldValue and newValue are equal
    println("Initial value is \(oldValue)")
}
```

To be given the value on a different `DispatchQueue` (useful if you have some more heavy lifting to do):

```
bindObservable(nameViewModel.firstName, dispatchQueue: 
DispatchQueue.global(qos: .background)) { oldValue, newValue in
    // Do some computationally intensive work here
}
```

## License

This library is released under the terms of the ISC License. For more details see the [LICENSE.md](LICENSE.md) file.
