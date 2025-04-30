
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
    
    currently it is calling the cube specific tapping function and not the orb tapping function maybe something with the coordinators?







2.  XX add score tracking, basic function done, remember when calling the function sometimes it has to be parent.increaseScore()
3.  XX keep track of what objects are picked up, this is currently completed at the moment
4.  XX get coordinate junk debuged got this figured out so far derek was able to trouble shoot it luckily
5. work on the database stuff



plans for before demo:
get fixed location working
maybe get it so items are blocked by structures


coords for first row in class room:47.75391312,-117.41612673   ALT: 588.2369567041552
latitude = 111,111 meters
longitude = 111,111 * cos(latitude)

so plan for placing objects in fixed location is given the users coordinates and alitidue we figure out where to place the object based off the relative location of the phone and the distance from the fixed location

so like for latitude and longitude we do fixed location minus relative location of the phone, same for altitude and then from that we have how far from the phone we want to place the object

will want to convert from lat and long units to meters maybe

Home table coords
+47.63730776,-117.42897956 ALT:661.4756752904505


upstairs room coords
+47.63721840,-117.42898652, ALT:662.7344210334122


backyard coords
+47.63728471,-117.42908024, ALT:665.6621078665383
