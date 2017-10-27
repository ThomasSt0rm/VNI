# VNI
## Why do you read this

If you don't know what is Venerable Inertia, please close this page. If you do, please continue

## Prerequites

In addition to context and tasks I assume:

* Directory Service is used by Dev/Ops to access servers
* AppServers must use 1 IP Address to access outside world
* Technically 2 AppServers are just something which runs Docker containers ;)


## Software requirements

To run playbooks and python scripts it is required that you have python installed on your machine with following modules:
* ansible
* boto
* boto3
* pycrypto

Because of few boto issues, playbooks only work with ansible 2.4.1.
To setup your environment it is advised to use virtualenv.
Install virtualenv, if you don't have it followed by this command:

` pip install virtualenv `

Setup your virtualenv by doing:

` virtualenv VNI `

` cd VNI `

` source bin/activate `

You can install all necessary Python packages by doing:

` pip install -r requirements.txt `


## Links
* [Here](https://github.com/ThomasSt0rm/VNI/blob/master/Docs/DesignOverview.md) is design overview.
* [Here](https://github.com/ThomasSt0rm/VNI/blob/master/Docs/StepsTaken.md) I explain steps taken to accomplish the task.
* [Here](https://github.com/ThomasSt0rm/VNI/blob/master/Docs/Why.md) I explain why.
* [Here](https://github.com/ThomasSt0rm/VNI/blob/master/Docs/DevHowTo.md) is a short Dev How-To.
