Software requirements:

* Ruby version: 2.3.1

* Rails version: 5.0.0.1

System dependencies: See gemfile

To run, download this folder, navigate to it and run 

* bundle install

* rake db:migrate

* rake db:seed

* rails server

This app is deployed at: https://nameless-journey-10600.herokuapp.com/

Default credentials: admin2@ncsu.edu

Password: admin01

NOTE TO REVIEWERS: PLEASE DO NOT CHANGE THE DEFAULT ADMIN PASSWORD. If you are reviewing this app and cannot login as admin, it is because another reviewer has changed the password. Please contact me at <github username> at <gmail> dot <com> to make a new admin so you can login.

Number of reviewers inconvenienced by password changes: 1

To use:
Login as admin. Here you can create new admins, rooms and library members. As admin, you can book rooms for other members as well. You can also cancel bookings, provided the booking start time has not passed. 
You may create users as admin or sign up from the login page to create regular library users who can book rooms for themselves. As a user, you can view your own booking history and cancel booking, provided the start time has not elapsed. All bookings can be done for two hour slots only. This was assumed based on the requirements.

To test: rake test
