# Feedme: iOS part

## Abstract
The quest for an optimal indoor climate has led to automatic systems that adjusts the indoor climate based on scientific factors. The systems interpret measurable values such as temperature, air-humidity, CO2 level and takes action accordingly. However, it is hard to create a system that fits everyone --- different people have different needs and thus their perception of the indoor climate cannot be simplified as such. This leads to the creation of Feedme, a system with the vision of giving the users more control and influence on how the indoor climate is regulated in the room they are located in. The idea is to automatically determine the users' location, by installing Bluetooth Low Energy beacons in buildings and ask them questions about their experience of the conditions of the room they are located in. The system can take action accordingly based on the users' feedback, thus shifting decision-taking towards their needs and comfort rather than plain scientific factors.

The system consists of three main components. A web server written in NodeJS running on a virtual machine communicating with a MongoDB database. **An iOS application with the purpose of listening to BLE beacons and giving the opportunity for users to provide feedback accordingly**. A ReactJS website that gives building administrators a way to manage the buildings that need to be regulated. 

To determine users' location, a modification of the K-Nearest Neighbors algorithm has been implemented, where the BLE beacons' signal strength are used. The success rate of the algorithm varies a lot depending on the setup, with the lowest success rate being picking random rooms and the highest success rate of 100\%. The time it takes to determine users' location is roughly two seconds. The whole system has been developed with an agile approach, so the system can be further developed and the experiments are documented, such that they can be reproduced. The actual implementation allows it to be used as a general feedback application thus expanding its use case and potential significantly.

------------------------------------------------------------------------------------------------------------------------

web server written in NodeJS: https://github.com/DTUFeedme/feedme-server

To read the whole thesis, please see https://github.com/christianhjelmslund/feedme-iOS/blob/master/thesis_and_images/bachelors_thesis.pdf.

I would highly recommend Chapter 5 (Software Handbook), before reading the specifics about the iOS app, which are Section 7.1 (Design - System Overview), 7.3 (Design - Mobile Application Architecture), 8.1 (Implementation - Mobile Application) and 9.2 (Testing - Mobile Application). You might have to download it and open it with a PDF-reader such as Adobe acrobat.

If you want to know more, please don't hesitate to reach out or if you are interested in forking this project. I would gladly help you in the right direction and provide an introduction to the project setup (it's in the thesis too, but I understand that 100 pages can look a bit scary at first sight). I will not go more in depth of the usage, but I can suggest you to read the introduction and maybe section 4.3 (Analysis - User Stories) if you want to get a brief feeling about the purpose of this project.

------------------------------------------------------------------------------------------------------------------------
# Short and brief description

The application is currently in-use at Borgerskolen in Høje Taastrup in Denmark, where it is deployed through TestFlight. I won't describe the images, because you can read a more detailed description in the thesis. The pictures used below are from the version of when the thesis was handed it. There have been some updates since then, including UI changes. 

Main libraries used:

CoreLocation: https://developer.apple.com/documentation/corelocation/ (Apple)

AlamoFire: https://github.com/Alamofire/Alamofire (3rd party)

Charts: https://github.com/danielgindi/Charts (3rd party)

------------------------------------------------------------------------------------------------------------------------

## High level system architecture

![High level system architecture](https://github.com/christianhjelmslund/feedme-iOS/blob/master/thesis_and_images/componentdiagram2.png)

------------------------------------------------------------------------------------------------------------------------
## iOS class diagram

![High level system architecture](https://github.com/christianhjelmslund/feedme-iOS/blob/master/thesis_and_images/classdiagram_mobileapplicaition.png)
------------------------------------------------------------------------------------------------------------------------
## In-app images:

Give feedback        |  Chart of given feedback
:-------------------------:|:-------------------------:
![](https://github.com/christianhjelmslund/feedme-iOS/blob/master/thesis_and_images/givefeedback.png)  |  ![](https://github.com/christianhjelmslund/feedme-iOS/blob/master/thesis_and_images/diagramview.png)

See given feedback        |  Choose different room to see fedback from   | Start scan a new room
:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/christianhjelmslund/feedme-iOS/blob/master/thesis_and_images/seegivenfeedback.png)  |  ![](https://github.com/christianhjelmslund/feedme-iOS/blob/master/thesis_and_images/roomchoser.png) |  ![](https://github.com/christianhjelmslund/feedme-iOS/blob/master/thesis_and_images/startscan.png) 







