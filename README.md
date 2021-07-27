<p align="center">
    <img src="https://diegolaballos.com/files/images/flutter-icon.jpg" alt="Logo" width=72 height=72>
  </a>

  <h3 align="center">Storify</h3>

  <p align="center">
    Storify is a beutiful social media app where users can share their own stories with other users.
    <br>
    You can follow other users, chat, reading and writing stories and even more!
    <br>
    More details will be on each main screen!
    <br>
  </p>
</p>

# Main screens of the app

## Login Screen
![log in](https://user-images.githubusercontent.com/69850880/127154036-379d3b54-c10d-4c28-9a0e-e78b41eaddc7.PNG)

In this screen the user can decided in which platform he wants to login to our app - Google or Facebook.
<br>
If we don't have a user yet, we can create one with a Google or Facebook account.
<br>
All your data will be safe and secured in our database, we are using Firebase
<br>
We implemented Google Firebase Cloud Firestore, Storage and Authentication to provide database and authentication services to the application
<br>

## Home page
![image](https://user-images.githubusercontent.com/69850880/127155061-eb696752-6910-49e7-9327-12c0e8747a1f.png)
Your homepage! 
Every user have is own dynamic homepage.
If we want to see more stories we can swipe right in the middle of the screen.
At the main page, we have 4 sections: Feed, All, Top and Categories:
    Feed - Showing us the stories of people we follow (newest stories will be first)
    All - Showing us all of the current stories in our app - this section help us know new people ( newest stories will be first)
    Top - Most high rated stories of our app
    Categories - Filter only the "Top" and "All" sections - we decide which category we want the app to show us
We will explain more about the details in each story in "Stories page"
