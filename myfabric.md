```yaml

# ---------------------------------------------------------------------------
# "OrdererOrgs" - Definition of organizations managing orderer nodes
# ---------------------------------------------------------------------------
OrdererOrgs:
  # ---------------------------------------------------------------------------
  # Orderer
  # ---------------------------------------------------------------------------
  - Name: Orderer
    Domain: qbgoo.com

    # ---------------------------------------------------------------------------
    # "Specs" - See PeerOrgs below for complete description
    # ---------------------------------------------------------------------------
    Specs:
      - Hostname: orderer

# ---------------------------------------------------------------------------
# "PeerOrgs" - Definition of organizations managing peer nodes
# ---------------------------------------------------------------------------
PeerOrgs:
  # ---------------------------------------------------------------------------
  # Org1
  # ---------------------------------------------------------------------------
  - Name: OrgA
    Domain: orga.qbgoo.com
    EnableNodeOUs: false

    # ---------------------------------------------------------------------------
    # "CA"
    # ---------------------------------------------------------------------------
    # Uncomment this section to enable the explicit definition of the CA for this
    # organization.  This entry is a Spec.  See "Specs" section below for details.
    # ---------------------------------------------------------------------------
    # CA:
    #    Hostname: ca # implicitly ca.org1.example.com
    #    Country: US
    #    Province: California
    #    Locality: San Francisco
    #    OrganizationalUnit: Hyperledger Fabric
    #    StreetAddress: address for org # default nil
    #    PostalCode: postalCode for org # default nil

    # ---------------------------------------------------------------------------
    # "Specs"
    # ---------------------------------------------------------------------------
    # Uncomment this section to enable the explicit definition of hosts in your
    # configuration.  Most users will want to use Template, below
    #
    # Specs is an array of Spec entries.  Each Spec entry consists of two fields:
    #   - Hostname:   (Required) The desired hostname, sans the domain.
    #   - CommonName: (Optional) Specifies the template or explicit override for
    #                 the CN.  By default, this is the template:
    #
    #                              "{{.Hostname}}.{{.Domain}}"
    #
    #                 which obtains its values from the Spec.Hostname and
    #                 Org.Domain, respectively.
    #   - SANS:       (Optional) Specifies one or more Subject Alternative Names
    #                 to be set in the resulting x509. Accepts template
    #                 variables {{.Hostname}}, {{.Domain}}, {{.CommonName}}. IP
    #                 addresses provided here will be properly recognized. Other
    #                 values will be taken as DNS names.
    #                 NOTE: Two implicit entries are created for you:
    #                     - {{ .CommonName }}
    #                     - {{ .Hostname }}
    # ---------------------------------------------------------------------------
    # Specs:
    #   - Hostname: foo # implicitly "foo.org1.example.com"
    #     CommonName: foo27.org5.example.com # overrides Hostname-based FQDN set above
    #     SANS:
    #       - "bar.{{.Domain}}"
    #       - "altfoo.{{.Domain}}"
    #       - "{{.Hostname}}.org6.net"
    #       - 172.16.10.31
    #   - Hostname: bar
    #   - Hostname: baz

    # ---------------------------------------------------------------------------
    # "Template"
    # ---------------------------------------------------------------------------
    # Allows for the definition of 1 or more hosts that are created sequentially
    # from a template. By default, this looks like "peer%d" from 0 to Count-1.
    # You may override the number of nodes (Count), the starting index (Start)
    # or the template used to construct the name (Hostname).
    #
    # Note: Template and Specs are not mutually exclusive.  You may define both
    # sections and the aggregate nodes will be created for you.  Take care with
    # name collisions
    # ---------------------------------------------------------------------------
    Template:
      Count: 2
      # Start: 5
      # Hostname: {{.Prefix}}{{.Index}} # default
      # SANS:
      #   - "{{.Hostname}}.alt.{{.Domain}}"

    # ---------------------------------------------------------------------------
    # "Users"
    # ---------------------------------------------------------------------------
    # Count: The number of user accounts _in addition_ to Admin
    # ---------------------------------------------------------------------------
    Users:
      Count: 2

  # ---------------------------------------------------------------------------
  # Org2: See "Org1" for full specification
  # ---------------------------------------------------------------------------
  - Name: OrgB
    Domain: orgb.qbgoo.com
    EnableNodeOUs: false
    Template:
      Count: 2 
    Users:
      Count: 1 

```







| orderer | orderer.qbgoo.com | 排序节点                      |
| ------- | ----------------- | ----------------------------- |
| OrgA    | orga.qbgoo.com    | 组织A                         |
|         | peer0             |                               |
|         | peer1             |                               |
|         | admin,user1,user2 | 默认一个admin, 另定义两个user |
| OrgB    | orgb.qbgoo.com    | 组织B                         |
|         | peer0             |                               |
|         | peer1             |                               |
|         | admin,user1       | 默认一个admin, 另定义一个user |
|         |                   |                               |



```shell
$ cryptogen generate --config=./crypto-config.yaml
orga.qbgoo.com
orgb.qbgoo.com
```



```shell
$ tree crypto-config
crypto-config
├── ordererOrganizations
│   └── qbgoo.com
│       ├── ca
│       │   ├── 25ab40b3d7bcf7188ee4b5e2c3b1f6cc4b7f6b4a7575145377a41fb94658d572_sk
│       │   └── ca.qbgoo.com-cert.pem
│       ├── msp
│       │   ├── admincerts
│       │   │   └── Admin@qbgoo.com-cert.pem
│       │   ├── cacerts
│       │   │   └── ca.qbgoo.com-cert.pem
│       │   └── tlscacerts
│       │       └── tlsca.qbgoo.com-cert.pem
│       ├── orderers
│       │   └── orderer.qbgoo.com
│       │       ├── msp
│       │       │   ├── admincerts
│       │       │   │   └── Admin@qbgoo.com-cert.pem
│       │       │   ├── cacerts
│       │       │   │   └── ca.qbgoo.com-cert.pem
│       │       │   ├── keystore
│       │       │   │   └── 6bd4658f675d72c2ef649707a742df29f45a93a0dfd6ad11e1a7a5aa0696cfd8_sk
│       │       │   ├── signcerts
│       │       │   │   └── orderer.qbgoo.com-cert.pem
│       │       │   └── tlscacerts
│       │       │       └── tlsca.qbgoo.com-cert.pem
│       │       └── tls
│       │           ├── ca.crt
│       │           ├── server.crt
│       │           └── server.key
│       ├── tlsca
│       │   ├── fd21cd49e451f9c8df063ef71ba6d1549c88b5970b5dcddbd12039943ec0a818_sk
│       │   └── tlsca.qbgoo.com-cert.pem
│       └── users
│           └── Admin@qbgoo.com
│               ├── msp
│               │   ├── admincerts
│               │   │   └── Admin@qbgoo.com-cert.pem
│               │   ├── cacerts
│               │   │   └── ca.qbgoo.com-cert.pem
│               │   ├── keystore
│               │   │   └── 812e3a642c9c17496f7e426ba2f80fee49df2292c4e8f3d829ff7918f7b80210_sk
│               │   ├── signcerts
│               │   │   └── Admin@qbgoo.com-cert.pem
│               │   └── tlscacerts
│               │       └── tlsca.qbgoo.com-cert.pem
│               └── tls
│                   ├── ca.crt
│                   ├── client.crt
│                   └── client.key
└── peerOrganizations
    ├── orga.qbgoo.com
    │   ├── ca
    │   │   ├── 6b6414987eeceb2a34c203c89eb4831bd7bcd59d6d103a7c15c466051a01cf58_sk
    │   │   └── ca.orga.qbgoo.com-cert.pem
    │   ├── msp
    │   │   ├── admincerts
    │   │   │   └── Admin@orga.qbgoo.com-cert.pem
    │   │   ├── cacerts
    │   │   │   └── ca.orga.qbgoo.com-cert.pem
    │   │   └── tlscacerts
    │   │       └── tlsca.orga.qbgoo.com-cert.pem
    │   ├── peers
    │   │   ├── peer0.orga.qbgoo.com
    │   │   │   ├── msp
    │   │   │   │   ├── admincerts
    │   │   │   │   │   └── Admin@orga.qbgoo.com-cert.pem
    │   │   │   │   ├── cacerts
    │   │   │   │   │   └── ca.orga.qbgoo.com-cert.pem
    │   │   │   │   ├── keystore
    │   │   │   │   │   └── 05adfec62bf31725fd965e1f9505ec061c4af6ff57989dcb80d85c1bc1903a52_sk
    │   │   │   │   ├── signcerts
    │   │   │   │   │   └── peer0.orga.qbgoo.com-cert.pem
    │   │   │   │   └── tlscacerts
    │   │   │   │       └── tlsca.orga.qbgoo.com-cert.pem
    │   │   │   └── tls
    │   │   │       ├── ca.crt
    │   │   │       ├── server.crt
    │   │   │       └── server.key
    │   │   └── peer1.orga.qbgoo.com
    │   │       ├── msp
    │   │       │   ├── admincerts
    │   │       │   │   └── Admin@orga.qbgoo.com-cert.pem
    │   │       │   ├── cacerts
    │   │       │   │   └── ca.orga.qbgoo.com-cert.pem
    │   │       │   ├── keystore
    │   │       │   │   └── 9500df3f494b83b7f456f25fec64949eca49fa697834673d062ca639e9f1359c_sk
    │   │       │   ├── signcerts
    │   │       │   │   └── peer1.orga.qbgoo.com-cert.pem
    │   │       │   └── tlscacerts
    │   │       │       └── tlsca.orga.qbgoo.com-cert.pem
    │   │       └── tls
    │   │           ├── ca.crt
    │   │           ├── server.crt
    │   │           └── server.key
    │   ├── tlsca
    │   │   ├── 650cf66da69d1efd456654f34fab9c84b8bb714d3433a3f81e54676694df3762_sk
    │   │   └── tlsca.orga.qbgoo.com-cert.pem
    │   └── users
    │       ├── Admin@orga.qbgoo.com
    │       │   ├── msp
    │       │   │   ├── admincerts
    │       │   │   │   └── Admin@orga.qbgoo.com-cert.pem
    │       │   │   ├── cacerts
    │       │   │   │   └── ca.orga.qbgoo.com-cert.pem
    │       │   │   ├── keystore
    │       │   │   │   └── 7520e10b046979d988ca6d8c5541a1030fe3a48091ecd900f875820531168813_sk
    │       │   │   ├── signcerts
    │       │   │   │   └── Admin@orga.qbgoo.com-cert.pem
    │       │   │   └── tlscacerts
    │       │   │       └── tlsca.orga.qbgoo.com-cert.pem
    │       │   └── tls
    │       │       ├── ca.crt
    │       │       ├── client.crt
    │       │       └── client.key
    │       ├── User1@orga.qbgoo.com
    │       │   ├── msp
    │       │   │   ├── admincerts
    │       │   │   │   └── User1@orga.qbgoo.com-cert.pem
    │       │   │   ├── cacerts
    │       │   │   │   └── ca.orga.qbgoo.com-cert.pem
    │       │   │   ├── keystore
    │       │   │   │   └── 016f0aa420660af5d4cf979a1844cb04bb9e9fa050b42b3982d1c6667ab488b7_sk
    │       │   │   ├── signcerts
    │       │   │   │   └── User1@orga.qbgoo.com-cert.pem
    │       │   │   └── tlscacerts
    │       │   │       └── tlsca.orga.qbgoo.com-cert.pem
    │       │   └── tls
    │       │       ├── ca.crt
    │       │       ├── client.crt
    │       │       └── client.key
    │       └── User2@orga.qbgoo.com
    │           ├── msp
    │           │   ├── admincerts
    │           │   │   └── User2@orga.qbgoo.com-cert.pem
    │           │   ├── cacerts
    │           │   │   └── ca.orga.qbgoo.com-cert.pem
    │           │   ├── keystore
    │           │   │   └── 4da62c44dab6e1fc90498d93445f5f91901aa53549f4bc25e9451cc4faf3e318_sk
    │           │   ├── signcerts
    │           │   │   └── User2@orga.qbgoo.com-cert.pem
    │           │   └── tlscacerts
    │           │       └── tlsca.orga.qbgoo.com-cert.pem
    │           └── tls
    │               ├── ca.crt
    │               ├── client.crt
    │               └── client.key
    └── orgb.qbgoo.com
        ├── ca
        │   ├── ca.orgb.qbgoo.com-cert.pem
        │   └── e97aae2b98506b3619a13ee9f4bbd867fbac7f123911179056e9a8d33f46a872_sk
        ├── msp
        │   ├── admincerts
        │   │   └── Admin@orgb.qbgoo.com-cert.pem
        │   ├── cacerts
        │   │   └── ca.orgb.qbgoo.com-cert.pem
        │   └── tlscacerts
        │       └── tlsca.orgb.qbgoo.com-cert.pem
        ├── peers
        │   ├── peer0.orgb.qbgoo.com
        │   │   ├── msp
        │   │   │   ├── admincerts
        │   │   │   │   └── Admin@orgb.qbgoo.com-cert.pem
        │   │   │   ├── cacerts
        │   │   │   │   └── ca.orgb.qbgoo.com-cert.pem
        │   │   │   ├── keystore
        │   │   │   │   └── e97dca3ef72a78fbc08726766d0e70ee809bac8d43a81a4cef97500dba5337ad_sk
        │   │   │   ├── signcerts
        │   │   │   │   └── peer0.orgb.qbgoo.com-cert.pem
        │   │   │   └── tlscacerts
        │   │   │       └── tlsca.orgb.qbgoo.com-cert.pem
        │   │   └── tls
        │   │       ├── ca.crt
        │   │       ├── server.crt
        │   │       └── server.key
        │   └── peer1.orgb.qbgoo.com
        │       ├── msp
        │       │   ├── admincerts
        │       │   │   └── Admin@orgb.qbgoo.com-cert.pem
        │       │   ├── cacerts
        │       │   │   └── ca.orgb.qbgoo.com-cert.pem
        │       │   ├── keystore
        │       │   │   └── 981298045e38d8b2e39e296aebd4a1c5998a25fae628030b1b3e57e6b0c39614_sk
        │       │   ├── signcerts
        │       │   │   └── peer1.orgb.qbgoo.com-cert.pem
        │       │   └── tlscacerts
        │       │       └── tlsca.orgb.qbgoo.com-cert.pem
        │       └── tls
        │           ├── ca.crt
        │           ├── server.crt
        │           └── server.key
        ├── tlsca
        │   ├── 821140f470f3996088dda243ba0ded5de746116dbcb2e3adb37d24e5a1ce3d11_sk
        │   └── tlsca.orgb.qbgoo.com-cert.pem
        └── users
            ├── Admin@orgb.qbgoo.com
            │   ├── msp
            │   │   ├── admincerts
            │   │   │   └── Admin@orgb.qbgoo.com-cert.pem
            │   │   ├── cacerts
            │   │   │   └── ca.orgb.qbgoo.com-cert.pem
            │   │   ├── keystore
            │   │   │   └── f81c3aedf25e0418adcb52999b9513aad5a1bd99835ec5914a3dfe4c5898de61_sk
            │   │   ├── signcerts
            │   │   │   └── Admin@orgb.qbgoo.com-cert.pem
            │   │   └── tlscacerts
            │   │       └── tlsca.orgb.qbgoo.com-cert.pem
            │   └── tls
            │       ├── ca.crt
            │       ├── client.crt
            │       └── client.key
            └── User1@orgb.qbgoo.com
                ├── msp
                │   ├── admincerts
                │   │   └── User1@orgb.qbgoo.com-cert.pem
                │   ├── cacerts
                │   │   └── ca.orgb.qbgoo.com-cert.pem
                │   ├── keystore
                │   │   └── f315880c1ddc1260fb0ca6463bd317775af4136817c378cc84434118dd36a6c0_sk
                │   ├── signcerts
                │   │   └── User1@orgb.qbgoo.com-cert.pem
                │   └── tlscacerts
                │       └── tlsca.orgb.qbgoo.com-cert.pem
                └── tls
                    ├── ca.crt
                    ├── client.crt
                    └── client.key

117 directories, 109 files
```


```shell
# 创建通道
# peer channel create -o orderer.qbgoo.com:7050 -c qbgoochannel -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/qbgoo.com/orderers/orderer.qbgoo.com/msp/tlscacerts/tlsca.qbgoo.com-cert.pem
2019-01-14 09:15:15.250 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2019-01-14 09:15:15.338 UTC [cli/common] readBlock -> INFO 002 Received block: 0
```