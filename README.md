Singals
=======

Signals is a micro-framework for creating and observing events.

Make events on a class observable by creating one or more signals:
```
class NetworkLoader {

    // Creates a number of signals that can be subscribed to
    let onData = Signal<(data:NSData, error:NSError)>()
    let onProgress = Signal<Float>()
    
    ...
    
    func receivedData(receivedData:NSData, receivedError:NSError) {
        // Whenever appropriate, fire off any of the signals
        self.onProgress.fire(1.0)
        self.onData.fire(data:receivedData, error:receivedError)
    }
}
```

Subscribe to these signals from elswhere in your application

```

let networkLoader = NetworkLoader("http://artman.fi")

networkLoader.onProgress.listen(self) { (progress) in
    println("Loading progress: \(progress*100)%")
}

networkLoader.onData.listen(self) { (data, error) in
    // Do somethign with the data
}
```

Adding listeners to signals is a fire-and-forget operation. If your listener is deallocated, the Signal removes the listener from it's list of listeners. If the Signal emitter is deallocated, so is the closure that was supposed to fire on the listener, so you don't need to explicitly manage the removal of listeners.

Singals aren't restricted to one listener, so multiple objects can listen on the same Signal.


Installation
------------
1. Copy the Signal.swift file over to your project. 
2. Done.

Become more productive
----------------------

Where delegates and notifications are too cumbersome and contain too much boilerplate, Signals is simple and modern.

Would you rather do this to implement a delegate:
- Create a protocol that defines what is delegated
- Create a delegate property on the class that wants to provide delegation
- Mark each class that wants to become a delegate as comforming to the delegate protocol
- Implement the delegate methods on the class that want to become a delegate
- Set the delegate property to become a delegate of the instance
- Check that you're delegate implements each delegate method before invoking it

Or do the same thing with Signals:
- Create a signal for the class that wants to provide an event
- Subscribe to the signal as a listener from any instance you want

