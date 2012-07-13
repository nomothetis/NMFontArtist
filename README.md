# NMFontArtist - Fancy iOS Text

This library tries to provide some code to create effects such as embossing and engraving that go
beyond the simple "add a shadow" approach of most applications. Because the effects are heavily
graphical, they go beyond what NSAttributedString and others can do. For similar reasons, instead of
giving clients the option of drawing a string, most methods return a UIImage of the string; this
allows for optimizations by UIImageView that will greatly improve rendering at runtime.
