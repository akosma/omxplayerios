# omxplayerios

Client application for [omxplayernode][omxplayernode] communicating
through [socket.io][socketio] to drive [omxplayer][omxplayer] on a
[Raspberry Pi][raspi].

This project replaces completely [omxplayerphp][omxplayerphp].

## Features

The iOS application allows users to:

- See the list of movies on a [Raspberry Pi][raspi] unit in the local
  network, as well as the current amount of free space in the root
  filesystem.
- Select a movie for playback.
    - If another person selects a movie in the local network, your own
      application is notified of this automatically.
- Pause, move forwards and backwards, toggle subtitles, and stop the
  current movie.
    - If another person stops a movie, all clients in the local network
      are automatically notified of this.

NOTE: this application violates App Store regulations, and as such it is
not suitable for submission.

## Requirements

The following requirements apply:

- This project uses Swift 1.2 and was created with Xcode 6.4.
- This project uses [Cocoapods][cocoapods] to manage dependencies.

## Installation

To build this application, follow these instructions:

1. Run `pod install` on the command line.
2. Open the `Movies.xcworkspace` file at the root of the project.
3. Select `Product / Build` in Xcode.

## Credits

Special thanks for:

- Icons: [Oxygen Team][oxygen]
- socket.io library: [Socket.IO-Client-Swift][client]

## License

Check the LICENSE file for details.


[client]:https://github.com/socketio/socket.io-client-swift
[cocoapods]:https://cocoapods.org
[omxplayer]:http://www.raspberry-projects.com/pi/software_utilities/omxplayer
[omxplayernode]:https://github.com/akosma/omxplayernode
[omxplayerphp]:https://github.com/akosma/omxplayerphp
[oxygen]:http://www.iconarchive.com/artist/oxygen-icons.org.html
[socketio]:http://socket.io

