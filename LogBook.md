#  Jules Gribble Log Book
> ***Note*** signitures for logbook are on sheet related to each week. Contact Jules Gribble to see sheet
## Week 1
- Research on ARKit and how it could be used
- Research existing apps using ARKit and benifits of these apps.
## Week 2
- Map ARKit example – (use this as a base of what the overlay should look like) [YouTube](https://www.youtube.com/watch?v=6Lo0Z7CkMWw) & [GitHub](https://github.com/ProjectDent/ARKit-CoreLocation/blob/master/ARKit%2BCoreLocation/ViewController.swift)
- Created a simple class for assets in swift to enable access of the data relating to one record.
- Positiong ARKit in correct Heading
- Working out how to position objects in relation to GPS location in AR View. [Link](https://www.raywenderlich.com/146436/augmented-reality-ios-tutorial-location-based-2 ) to help
### To do next week
- Satrt work on API setting up connection with app

## Week 3
- Set up simple NodeJS server [project](https://github.com/jagribble/AssetServer)
- Encountered eslint errors while trying to comply with ES6
### To do next week
- Fix eslint Error 
- Connect database to server
- show connection from API to app

## Week 4
- Added Heroku Postgres database to staging application
- Connected it to code and created a simple asset table
- Created insert POST method
- Made function on IOS app to get asset data `getAssets()` from `/selectAsset`
### To do next week
- Create data model for database
- Create visual for AR

## Week 5
- Database design
- Look out how to add 3D object in AR
### To do next week
- Make sure endpoints are ReSTful

## Week 6 
- Ajusted databse to match data model
- Endpoints changed to match ReSTful paradigm
- Assets related to Organisation making it multi-tenant
### To do next week
- finish off endpoints
- Design UI

## Week 7 
- Changed data model to get rid of redundant data between dataTypes and assets
- Endpoints match new data model
### To do next week 
- Start working on web app
- Look at Oauth2.0

## Week 8 
- Looked up OAuth2.0 addons for heroku. [AuthO](https://elements.heroku.com/addons/auth0) addon provides a free 0Auth workflow for free.
- Work on server implementation of AuthO

### To do next week
- Think about QRCode/image recognition objects
- Continue on Auth flow

## Week 9 
- Tried to implement AuthO integration in server
- Revert back to pre-authentication due to server not working

### To do next week
- fix Auth flow

## Week 10
- `Error: Grant type 'http://auth0.com/oauth/grant-type/password-realm' not allowed for the client.` Error fixed via allowing grant type on client 'password' to allow password realm

### To do next week
- Admin dashboard

## Week 11
- Created React adminstration dashboard homepage
- Google API Key aquired
- npm package not working as expected for google maps

### To do next week
- Fix Google maps
- Asset Detail page

## Week 12
- Used 'google-maps-react' to implement google maps 
- Created asset detail page (based off home page)
- react-charts-js-2 used to add a chart to show the data

### To do next week
- User page
- Users to have organisation in the iOS App

## Week 13
- Created users page allowing admin to assign user to organisation
- iOS app has context of organisation
- If no organisation user locked from actions
