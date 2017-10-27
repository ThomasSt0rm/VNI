# Design overview

![Design](https://raw.githubusercontent.com/ThomasSt0rm/VNI/master/img/VNI%20-%20Page%201.png)

Solution runs in a single VPC in 4 subnets.
ECS is used to provision container cluster, services and tasks.
ECS is based on IAM role, Launch Configuration and AutoScaling Group. This configuration allows cluster to be selfmaintained and increased in the amount of instances based on demand.

Directory Service runs on a single EC2 instance from custom build AMI. To ensure it can be easily access without manual setup, it always has the same IP address, even if terminated and launched again.

All necessary configurations are stored in Ansible playbooks (for AWS network and EC2) and userdata (LDAP client setup)

Container orchestration is done via ECS task definitions and container images are stored in ECR.

To automate deployment of new images there is a pipeline setup in AWS CodePipeline. The image build is executed during CodeBuild job as a step. Since CodeDeploy doesn't support ECS rollout, the change of Docker version image still has to be done manually.