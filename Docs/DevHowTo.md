# How-To when you are a developer

## How to access the server.

Assuming that you already have an LDAP account simply ssh to the Bastion host with your personal account. You don't need SSH keys, so use your LDAP password.

## How to read logs

When you need to debug the application, you want to see actual contrainer logs.
Going manually to each container node to read docker logs directly is an unnecessary action wasting time. Instead of that, simply use CloudWatch.
Login to AWS Console, select eu-central-1 and CloudWatch.
Click on 'Logs' on your left and select 'ecs-demo' log group. Click on task definition and you'll see last docker logs.

![Logs Image](https://raw.githubusercontent.com/ThomasSt0rm/VNI/master/img/ecs_logs.png)

## How to debug manually

You still can access ECS node or even a container to debug, go to EC2 Container Service, and click on task to see on which instance it is running.

![Task Image](https://raw.githubusercontent.com/ThomasSt0rm/VNI/master/img/vni-task-dashboard.png)

When you click on EC2 Insrance id you will see private IP address and DNS entry.

![Node Image](https://raw.githubusercontent.com/ThomasSt0rm/VNI/master/img/vni-ecs-node.png)

You can use this IP to access this server from a Bastion host.
From there you do `sudo docker exec ` to do something inside of container.

However this should be used only in case of emergency.