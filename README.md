# ARKit-SCNPathNode

Navigation seems to be a strong point for people making AR apps. So here's a class to easily create a path in AR along a set of centre points.

Please feel free to use and contribute this library however you like.
I only ask that you let me know when you're doing so, so I can see some cool uses of it!

It's as easy as this to make a path:
```
let pathNode = SCNPathNode(path: [
	SCNVector3(0,-1,0),
	SCNVector3(0,-1,-1),
	SCNVector3(1,-1,-1)
])
```


<!-- Here's some basic examples of what you can do with this Pod: -->

<!-- ![Path Example 1](https://github.com/maxxfrazer/ARKit-SCNPathNode/blob/master/media/SCNPathNode-example1.gif) -->
<!-- ![Path Example 2](https://github.com/maxxfrazer/ARKit-SCNPathNode/blob/master/media/SCNPathNode-example2.gif) -->
