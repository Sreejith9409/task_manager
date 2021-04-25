## Description
Task Manager is a sample Rails application designed using Object Oriented Programming approach.

## Problem Statement
This application is built to manage tasks of multiple projects  

Here you can create projects and tasks under each projects.  

Each task will have 3 states  
**Backlog** - **In Progress** - **Complete**  

User must signup first. Later he can signin from the same email and create projects/tasks. User can assign task to different user and also give estimation points. Once the assigned user starts the task, time starts and he should complete within the given hours of time. An alert email will be trigerred to assigned user if its not completed.

This app also sends a google calendar reminder notification to user. This will be created when task is moved to inprogress. Calendar start time is set to completion time - 1 hour. End time is completion time.

## Dependencies
Ruby Version: ruby 2.6.6  
Rails Version: Rails 6.0.3.6  

## Run the code
To get emails we need to configure CommonUtils.alert_user_about_time_lapse in Cron Jobs  

We need to configure it 2 times one in daily job and one in hourly job. Under hourly Job it has to be configured as CommonUtils.alert_user_about_time_lapse(true) and in daily job it can be configured as CommonUtils.alert_user_about_time_lapse  

