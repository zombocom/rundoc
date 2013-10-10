This quickstart will get you going with a Java and Play Framework application that uses a WebSocket, deployed to Heroku. For general information on how to develop and architect apps for use on Heroku, see [Architecting Applications for Heroku](https://devcenter.heroku.com/articles/architecting-apps).

>note
> Sample code for the [demo application](https://github.com/heroku/play-ws-test) is available on GitHub. Edits and enhancements are welcome. Just fork the repository, make your changes and send us a pull request.

## Prerequisites

* Java, Play Framework 2.x, Git, and the Heroku client (as described in the [basic Java quickstart](java))
* A Heroku user account.  [Signup is free and instant](https://api.heroku.com/signup/devcenter).

## Create a Play Framework Java app that uses a WebSocket

The sample application provides a simple example of using a WebSocket with Java and Play. You can clone the sample and follow along with the code as you read. If you'd rather write the app yourself you can add the sample code to a new Play app as you go.

### Option 1. Clone the sample app

If you want to get going more quickly you can just clone the sample app:

```term
$ git clone git@github.com:heroku/play-ws-test.git
Cloning into 'play-ws-test'...
remote: Counting objects: 31, done.
remote: Compressing objects: 100% (24/24), done.
remote: Total 31 (delta 0), reused 31 (delta 0)
Receiving objects: 100% (31/31), 38.33 KiB | 0 bytes/s, done.
Checking connectivity... done
```

### Option 2. Create a new Play app

```term
:::- $ play help
:::= repl play new play22test
mywebsocketapp
2

:::= $ cd play22test
```

Choose an application name and Java as the language.

## The sample application

The sample application renders a simple web page that will open a WebSocket to the backend. The server will send a payload containing the time over the WebSocket once a second. That time will be displayed on the page.

There are 3 important pieces to the interaction that takes place here: a controller method that returns a WebSocket object, a JavaScript method that opens that WebSocket, and an Akka actor that sends the payload across that WebSocket every second. Let's explore each.

### Returning a WebSocket from a controller method

You can [return a WebSocket](http://www.playframework.com/documentation/2.2.x/JavaWebSockets) from a Play controller method.

There is an example in `Application.java` in the sample application:

```java
:::= write app/controllers/Application.java
package controllers;

import static java.util.concurrent.TimeUnit.SECONDS;
import models.Pinger;
import play.libs.Akka;
import play.libs.F.Callback0;
import play.mvc.Controller;
import play.mvc.Result;
import play.mvc.WebSocket;
import scala.concurrent.duration.Duration;
import views.html.index;
import akka.actor.ActorRef;
import akka.actor.Cancellable;
import akka.actor.Props;

public class Application extends Controller {
    public static WebSocket<String> pingWs() {
        return new WebSocket<String>() {
            public void onReady(WebSocket.In<String> in, WebSocket.Out<String> out) {
                final ActorRef pingActor = Akka.system().actorOf(Props.create(Pinger.class, in, out));
                final Cancellable cancellable = Akka.system().scheduler().schedule(Duration.create(1, SECONDS),
                                                   Duration.create(1, SECONDS),
                                                   pingActor,
                                                   "Tick",
                                                   Akka.system().dispatcher(),
                                                   null
                                                   );

                in.onClose(new Callback0() {
                  @Override
                  public void invoke() throws Throwable {
                    cancellable.cancel();
                  }
                });
            }

        };
    }

    public static Result pingJs() {
        return ok(views.js.ping.render());
    }

    public static Result index() {
        return ok(index.render());
    }
}
```

This method returns a new [WebSocket](http://www.playframework.com/documentation/2.0/api/java/play/mvc/WebSocket.html) object that has a String as its payload. In the WebSocket object we define the onReady method to talk to an actor via the Akka scheduler. The work of sending data over the socket will occur in that actor.

The other methods will render our `js` and `html` templates.


We'll also need a route to be set up for these methods in our `routes` file:

```
:::= write conf/routes
# Home page
GET     /                           controllers.Application.index()
GET     /pingWs                     controllers.Application.pingWs()
GET     /assets/javascripts/ping.js controllers.Application.pingJs()

# Map static resources from the /public folder to the /assets URL path
GET     /assets/*file               controllers.Assets.at(path="/public", file)
```

### Sending data over a WebSocket

In the controller example you'll notice that we pass around the `in` and `out` streams of the WebSocket. In our actor we're able to read from and write to these streams just like any other IO stream. Here's the code for the `Pinger` actor:

```java
:::= write app/models/Pinger.java
package models;

import play.*;
import play.mvc.*;
import play.libs.*;

import scala.concurrent.duration.Duration;
import java.util.concurrent.TimeUnit;
import akka.actor.UntypedActor;
import java.util.Calendar;
import java.text.SimpleDateFormat;

public class Pinger extends UntypedActor {
    WebSocket.In<String> in;
    WebSocket.Out<String> out;

    public Pinger(WebSocket.In<String> in, WebSocket.Out<String> out) {
        this.in = in;
        this.out = out;
    }

    @Override
    public void onReceive(Object message) {
        if (message.equals("Tick")) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Calendar cal = Calendar.getInstance();
            out.write(sdf.format(cal.getTime()));
        } else {
            unhandled(message);
        }
    }
}
```

You'll notice that this actor counts on the schedule defined in the controller method to send it a "Tick" message every second. When that happens it sends the current date and time over the WebSocket.

### Connecting to a WebSocket

The final piece is the client code that will call the WebSocket. For this our sample application uses Scala js and HTML templates called `ping.scala.js` and `index.scala.js` respectively.

`index.scala.js` provides a `div` to display the data in and references the JavaScript:

```java
:::= write app/views/index.scala.html
@main("Welcome to Play") {

    <strong>Stats</strong><br>
    <div id="ping"></div>

   <script type="text/javascript" charset="utf-8" src="@routes.Application.pingJs()"></script>
}
```

`ping.scala.js` connects to our WebSocket and defines the `receiveEvent` method to populate the dates into the displayed `div` as they come across:

```javascript
:::= write app/views/ping.scala.js
$(function() {
    var WS = window['MozWebSocket'] ? MozWebSocket : WebSocket
    var dateSocket = new WS("@routes.Application.pingWs().webSocketURL(request)")

    var receiveEvent = function(event) {
        $("#ping").html("Last ping: "+event.data);
    }

    dateSocket.onmessage = receiveEvent
})
```

## Deploy the application to Heroku

### Store your app in Git

If you haven't done so already put your application into a git repository:

```term
:::= $ git init
:::= $ git add .
:::= $ git commit -m "Ready to deploy"
```

### Create the app

```term
#:::= $ heroku create
```

### Deploy your code

```term
#:::= $ git push heroku master
#:::- $ heroku labs:enable websockets
#:::- $ heroku restart
```

Congratulations! Your web app should now be up and running on Heroku.
