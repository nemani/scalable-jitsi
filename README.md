# How to integrate and scale [Jitsi Video Conferencing](https://jitsi.org/) 

- We created docker images based on [docker-jitsi-meet](https://github.com/jitsi/docker-jitsi-meet)
- Each docker image was modified to suit our specific use case, but no changes were made that majorly affect the scaling. 
- All the things mentioned in this document apply to the official docker images as well, though the code might need some changes to make it work.
- if you are looking for terraform scripts for the entire jitsi architecture you can also refer to [this repo](https://github.com/hermanbanken/jitsi-terraform-scalable). 

# Background
- We have a single tenant deployment scheme for each of our customers
- Customer ABC has the app deployed on abc.my-app.com where we call abc the app_prefix
- App uses Angular and connects to jitsi using [lib-jitsi-meet](https://github.com/jitsi/lib-jitsi-meet)
- This means the app is independent of the jitsi setup.

# Jitsi Architecture 
- This image describes the way jitsi components are setup.
- We focus on the following
  - [Prosody](https://prosody.im/) is an open-source XMPP Server
  - [Jicofo](https://github.com/jitsi/jicofo) is server-side focus component which is responsible for auth, participants, rooms, and also assigning conferences to different video-bridges
  - [Jitsi Videobridge](https://github.com/jitsi/jitsi-videobridge/) is the software videobridge that acts as a SFU (Selective Forwarding Unit) to forward the media streams to other participants in the same conference. It is also responsible for managing the audio/video quality and maintaining the WebRTC protocol.

![](https://jitsi.github.io/handbook/docs/assets/docker-jitsi-meet.png)

- For each customer we have one server running at app_prefix.my-app.com, called the App Server
- Each app server has the following running
  - Main application webserver
  - Prosody 
  - Jicofo
  - Grafana for displaying stats from the cluster
  - InfuxDB for storing stats & time series
  - Telegraf for reporting stats to influxdb
 
 - We then setup a jvb cluster, which are deployed across multiple regions, and multiple cloud providers.
 - We have 2 levels, an autoscaling cluster in GCP and a static-size cluster in other Cloud Providers.
 - The load on each jvb is measured using stress = (Incoming Packet Rate + Outgoing Packet Rate) // (Max Packet Rate that the system can handle)
 - The max packet rate is set by the creators, and they recommend testing to determine it for the machine you run the jvb on, [as mentioned](https://github.com/jitsi/jitsi-videobridge/issues/1364) 
 - Finally we use OCTO configuration which allows us to split conferences among the jvbs. This was extremely important to support conferences > 60 participants.
 - We use a custom bridge stratergy to make sure our conferences have low latency, ad low network egress costs while doing octo. 
 - We enabled all jvb communication to use websockets instead of [SSRC](https://tools.ietf.org/id/draft-westerlund-avtcore-max-ssrc-00.html)
 - Each JVB has a telegraf server that reports machine stats and jvb stats to the influxdb running on the appserver. All communication here is encrypted by HTTPS. 
 - Finally, we setup a grafana dashboard which is quite similar to the [one hosted by FFMUC](https://stats.ffmuc.net/d/U6sKqPuZz/meet-stats?orgId=1&refresh=1m)
 - This allows us to monitor the jvb clusters that we have and how much they are used. 
 - We also profiled the jitsi modules, digging deep into how we can optimize the videobridge using flamegraphs to identify bottlenecks.
 - We are also experimenting with the UDP Buffer Sizes and how to see if we can optimize bandwidth and load that each jvb can handle by increasing the buffer sizes. 
 
 
 # Load Testing
 - To ensure that we can handle the load we use a Selenium Grid to create participants across multiple conferences.
 - More details can be read in this [excellent post on the jitsi forum](https://community.jitsi.org/t/tutorial-loadtesting-jitsi-with-malleusjitsificus-on-a-selenium-grid/33302)
  - We explored multiple ways of creating the selenium grids, but found the cheapest and easiest way to use a grid was delegating it to [AWS Device Farm](https://aws.amazon.com/device-farm/)
  - Other ways we tried: using a fargate autoscaling setup to create the works for us. 
  - We also use [WebRTC's KITE](https://github.com/webrtc/KITE) for a subset of our testings, but found it to be too rigid to work with, and frequent errors in the creation of the workers.
  
# Recording
  - We found that running a separate instance of Jigasi for *each conference* would be too costly for us, and thus have been investigating other ways to achieve recording of the conferences.
  
# Using this folder
  - For each GCP account you can create a clone of the gcp-account-1 folder and change the creds
  - Install Terraform and Teragrunt
  - Use [Terragrunt](https://github.com/gruntwork-io/terragrunt) to apply-all, plan-all and other functions which allow you to manage multiple terraform projects together.

# Credits
 
 - Almost all work was done during my internship at [Enlume Technologies](https://www.enlume.com/)
 - Thanks to the amazing jitsi maintainers and for the wider jitsi community for creating almost all the tooling needed for a large-scale video conferencing solution. 
  
 
