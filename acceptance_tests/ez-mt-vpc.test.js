const tfxjs = require("tfxjs");
const tfx = new tfxjs("../", {
  ibmcloud_api_key: process.env.API_KEY,
  prefix: "ez-iks-test",
  region: "us-south",
});

tfx.plan("Easy Multizone ROKS Network", () => {
  tfx.module(
    "Easy VPC",
    "module.ez_vpc",
    tfx.resource("OpenShift Cluster", "ibm_container_vpc_cluster.cluster", {
      disable_public_service_endpoint: true,
      flavor: "bx2.4x16",
      name: "ez-iks-test-roks-cluster",
      tags: ["ez-vpc", "multizone-vpc"],
      wait_till: "IngressReady",
      worker_count: 2,
      zones: [
        { name: "us-south-1" },
        { name: "us-south-2" },
        { name: "us-south-3" },
      ],
    })
  );
  tfx.module(
    "VPC Module",
    "module.ez_vpc.module.vpc",
    tfx.resource("Development ACL", 'ibm_is_network_acl.network_acl["acl"]', {
      name: "ez-iks-test-acl",
      rules: require("./acl_rules.json"),
    }),
    tfx.resource(
      "Public Gateway Zone 1",
      'ibm_is_public_gateway.gateway["zone-1"]',
      {
        name: "ez-iks-test-public-gateway-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "Public Gateway Zone 2",
      'ibm_is_public_gateway.gateway["zone-2"]',
      {
        name: "ez-iks-test-public-gateway-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "Public Gateway Zone 3",
      'ibm_is_public_gateway.gateway["zone-3"]',
      {
        name: "ez-iks-test-public-gateway-zone-3",
        zone: "us-south-3",
      }
    ),
    tfx.resource(
      "Allow All Inbound Default Rule",
      'ibm_is_security_group_rule.default_vpc_rule["allow-all-inbound"]',
      {
        direction: "inbound",
        icmp: [],
        ip_version: "ipv4",
        remote: "0.0.0.0/0",
        tcp: [],
        udp: [],
      }
    ),
    tfx.resource(
      "VPC Zone 1 Subnet",
      'ibm_is_subnet.subnet["ez-iks-test-subnet-zone-1"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.10.10.0/24",
        name: "ez-iks-test-subnet-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "VPC Zone 2 Subnet",
      'ibm_is_subnet.subnet["ez-iks-test-subnet-zone-2"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.20.10.0/24",
        name: "ez-iks-test-subnet-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "VPC Zone 3 Subnet",
      'ibm_is_subnet.subnet["ez-iks-test-subnet-zone-3"]',
      {
        ip_version: "ipv4",
        ipv4_cidr_block: "10.30.10.0/24",
        name: "ez-iks-test-subnet-zone-3",
        zone: "us-south-3",
      }
    ),
    tfx.resource("VPC", "ibm_is_vpc.vpc", {
      address_prefix_management: "manual",
      classic_access: false,
      name: "ez-iks-test-vpc",
      tags: ["ez-vpc", "multizone-vpc"],
    }),
    tfx.resource(
      "VPC Zone 1 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-iks-test-subnet-zone-1"]',
      {
        cidr: "10.10.10.0/24",
        name: "ez-iks-test-subnet-zone-1",
        zone: "us-south-1",
      }
    ),
    tfx.resource(
      "VPC Zone 2 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-iks-test-subnet-zone-2"]',
      {
        cidr: "10.20.10.0/24",
        name: "ez-iks-test-subnet-zone-2",
        zone: "us-south-2",
      }
    ),
    tfx.resource(
      "VPC Zone 3 Subnet Prefix",
      'ibm_is_vpc_address_prefix.subnet_prefix["ez-iks-test-subnet-zone-3"]',
      {
        cidr: "10.30.10.0/24",
        name: "ez-iks-test-subnet-zone-3",
        zone: "us-south-3",
      }
    ),
  );
});
