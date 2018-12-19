# ARKit-SCNPath

Navigation seems to be a strong point for people making AR apps. So here's a class to easily create a path in AR along a set of centre points.

I'll be releasing a full tutorial shortly after Xmas on my [Medum page](https://medium.com/@maxxfrazer) on how I made the examples in the below gifs using this Pod and about 30 lines of non boilerplate code.

Please feel free to use and contribute this library however you like.
I only ask that you let me know when you're doing so, so I can see some cool uses of it!

It's as easy as this to make a node with this path as a geometry:
```
let pathNode = SCNPathNode(path: [
	SCNVector3(0,-1,0),
	SCNVector3(0,-1,-1),
	SCNVector3(1,-1,-1)
])
```

The y value is set to -1 just as an example that assumes the origin of your scene graph is 1m above the ground. Use plane detection to actually hit the ground correctly.


Here's some basic examples of what you can do with this Pod:

![Path Example 1](https://github.com/maxxfrazer/ARKit-SCNPathNode/blob/master/media/path-example-1.gif)
![Path Example Texture Repeating](https://github.com/maxxfrazer/ARKit-SCNPathNode/blob/master/media/path-example-2.gif)
![Path Example Creating](https://github.com/maxxfrazer/ARKit-SCNPathNode/blob/master/media/path-example-3.gif)
