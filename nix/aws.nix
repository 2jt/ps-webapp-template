let

  region = "eu-west-1";
  accessKeyId = "2jt";

  ec2 = { resources, ... }: {
    deployment.targetEnv = "ec2";
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = resources.ec2KeyPairs.my-key-pair;
    deployment.ec2.ebsInitialRootDiskSize = 40;
    deployment.ec2.elasticIPv4 = resources.elasticIPs.ip;
    deployment.ec2.associatePublicIpAddress = true;

    deployment.ec2.securityGroups =
      [ resources.ec2SecurityGroups.openPorts.name ];
  };

in {
  webserver = ec2;

  resources.ec2KeyPairs.my-key-pair = { inherit region accessKeyId; };

  resources.elasticIPs.ip = {
    inherit region;
    accessKeyId = accessKeyId;
  };

  resources.ec2SecurityGroups.openPorts = { resources, lib, ... }: {
    accessKeyId = accessKeyId;
    inherit region;
    description = "open ssh, http, https, postgresql ports";
    rules = [
      {
        toPort = 22;
        fromPort = 22;
        sourceIp = "0.0.0.0/0";
      }
      {
        toPort = 80;
        fromPort = 80;
        sourceIp = "0.0.0.0/0";
      }
      {
        toPort = 443;
        fromPort = 443;
        sourceIp = "0.0.0.0/0";
      }
      {
        toPort = 5432;
        fromPort = 5432;
        sourceIp = "0.0.0.0/0";
      }
    ];
  };
}
