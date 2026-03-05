public func echoInt(_ value: Int) -> Int {
  value
}

public func echoInt32(_ value: Int32) -> Int32 {
  value
}

public func negate(_ value: Bool) -> Bool {
  !value
}

public func scale(_ value: Double) -> Double {
  value * 2.0
}

public func greet(_ name: String) -> String {
  "Hello, \(name)!"
}

public func noReturn(_ value: Int) {
  _ = value
}
