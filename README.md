# VirtualTourist
Select, download and save collections of Flickr photos from around the world. Uses AlamoFire for network calls.

# Project Overview
The app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were at stops on a tour. Users are able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin.
+ Use URLSessions to interact with a public restful API
+ Create a user interface that intuitively communicates network activity and download progress
+ Store media on the device file system
+ Use Core Data for local persistence of an object structure

# Specifications
+ The app uses a managed object model created in the Xcode Model Editor. A .xcdatamodeld model file is present.
+ The object model contains both Pin and Photo entities.
+ The object model contains a one-to-many relationship between the Pin and Photo entities, with an appropriate inverse.
+ The app contains a map view that allows users to drop pins with a touch and hold gesture.
+ When a pin is tapped, the app transitions to the photo album associated with the pin.
+ When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
+ When a Photo Album View is opened for a pin that does not yet have any photos, it initiates a download from Flickr.
+ The code for downloading photos is in its own class, separate from the PhotoAlbumViewController.
+ Images display as they are downloaded. They are shown with placeholders in a collection view while they download, and displayed as soon as possible.
+ The specifics of storing an image is left to Core Data by activating the “Allows External Storage” option.
+ Once all images have been downloaded, the user can remove photos from the album by tapping the image in the collection view. Tapping the image removes it from the photo album, the booth in the collection view, and Core Data.
+ The Photo Album view has a button that initiates the download of a new album, replacing the images in the photo album with a new set from Flickr. The new set should contain different images (if available) from the ones previously displayed. One way this can be achieved is by specifying a random value for the page parameter when making the request.
+ If the Photo Album view is opened for a pin that previously had photos assigned, they are immediately displayed. No new download is needed.
