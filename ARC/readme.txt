
TO DO LIST:

1. Create welcome screen
2. add objects to the ar screen
3. remove objects from screen
4. capture user touch inputs
5. user ui stuff

and probably want a bunch of other stuff that we will figure out later

really late things to do
1. get the webserver connected
2. get a database to store info
3. have our app read/write to the data base



KNOWN BUG LIST:
when swithcing to ar screen from main camera goes black, tap function and cube making functions still occur and work as expected you just can see anything, ok so thus just fixed itself somehow not sure how, might break again

GPS coordinates are currently not working on aidans phone, restricted somehow, it should work but getting error "The operation couldn't be completed. (kCLErrorDomain error 1.)'" supposedly it is because authorization in plist is not allowed but i checked and it is allowed. Maybe test on different phone to see if it is just a one phone bug?


TO DO BY APRIL 23:
1. get the coordinate debuged and working (error code we are getting is "Location error: The operation couldn't be completed. (kCLErrorDomain error 1.)")
2. get so multiple object appear in screen and react to touches, add variety to touches
3. keep track of what objects are picked up
4. work on user interface
5. start work on the database
6. stretch goal connect database to program
7. add score tracking



TO DO LIST IN ORDER:
1. multiple objects appear on screen, currently being worked on having a bit of trouble figuring out how we are seperating objects, for some reason cubes can appear but when i try other objects they do not appear for some odd reason
2.  XX add score tracking, basic function done, remember when calling the function sometimes it has to be parent.increaseScore()
3.  XX keep track of what objects are picked up, this is currently completed at the moment
4. get coordinate junk debuged
5. work on the database stuff
