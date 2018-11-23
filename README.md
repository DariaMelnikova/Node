## Node

[![buddy pipeline](https://buddy.enecuum.com/enecuum/node/pipelines/pipeline/19/badge.svg?token=c35be458f2d393a30001acf59f086401a00713eb057ab070050e9855280788bf "buddy pipeline")](https://buddy.enecuum.com/enecuum/node/pipelines/pipeline/19)

Node is the project that allows to build network actors and blockchain protocols. It contains:

  - Enecuum.Framework;
  - main enecuum blockchain protocol and nodes;
  - sample nodes;
  - testing environment for nodes.

The goal of the Enecuum.Framework is to make writing of blockchain algorithms and behavior simple.
The framework provides such possibilities:

  - TCP, UDP, JSON-RPC for client and server side;
  - parallel network requests processing;
  - safe and robust concurrent state;
  - parallel computations;
  - concurrent in-memory data graph of arbitrary structure;
  - KV-database support;
  - embeddable console client;
  - arbitrary configs for nodes;
  - basic cryptography;
  - logging;
  - and other features.


Node
====

Project structure
-----------------

Source code located in [./src/](./src/)

Test code located in [./test/](./test/)

Config files located in [./configs/](./configs/)

### Config for test nodes:

1.  GraphNode:
    [./configs/GraphNodeTransmitter.json](./configs/GraphNodeTransmitter.json)
    [./configs/GraphNodeReceiver.json](./configs/GraphNodeReceiver.json)
2.  Fake PoW node [./configs/tst\_pow.json](./configs/tst_pow.json)
3.  Fake PoA node [./configs/tst\_poa.json](./configs/tst_poa.json)

### Config for production nodes:

1.  GraphNode:

-   Boot node [./configs/BN.json](./configs/BN.json)
-   GraphNode [./configs/GN\_0.json](./configs/GN_0.json)
    [./configs/GN\_1.json](./configs/GN_1.json)
    [./configs/GN\_2.json](./configs/GN_2.json)
    [./configs/GN\_3.json](./configs/GN_3.json)

1.  Fake PoW node [./configs/pow.json](./configs/pow.json)
2.  Fake PoA node [./configs/poa.json](./configs/poa.json)

Possibilities
-------------

### Test nodes

GraphNode

-   Works with blockchain graph and ledger.
-   Accepts K-blocks and microblocks, has a wide API.
-   Can act as a transmitter and receiver. Implements a basic
    synchronisation scenario.

PoW node

-   Generates K-blocks.

PoA node

-   Accepts K-blocks and transactions.
-   Generates microblocks.

### Production nodes

Production nodes have the the same functionality as test nodes and also
support routing. Nodes can locate each other via routing, for
bootstraping boot node needs to be run. After bootstraping there is no
need for boot node. Every node dynamically updates list of connetcs, detects "dead"
nodes, accepts new nodes and improves routing map constantly.

Build and Install
=================

Install Haskell Stack
---------------------

1.  Install Haskell stack

\`curl -sSL <https://get.haskellstack.org/> | sh\`

1.  If needed, add the path to your profile

\`sudo nano \~/.profile\` and append \`export
PATH=\$PATH:\$HOME/.local/bin\` at the end.

Install RocksDB
---------------

\`sudo apt install librocksdb-dev\`

Install libs for the client
---------------------------

`sudo apt install libtinfo-dev` `sudo apt install libgd-dev`

Clone and Build Node
--------------------

1.  Choose the appropriate local folder, clone the repo and change to
    the cloned repository folder

`git clone <https://github.com/Enecuum/Node.git> && cd Node`

1.  Build & install

`stack build --fast`

1.  Run tests (optional)

Run all tests: `stack build --fast --test`

Run fast tests: `stack build --fast --test --test-arguments "-m Fast"`

Run slow and unreliable tests: `stack build --fast --test
--test-arguments "-m Slow"`

### Node executable

`enq-node-haskell` is a single executable for nodes. `./configs`
contains several configs for different nodes.

Running sample nodes
====================

Run console client
------------------

`stack exec enq-node-haskell initialize ./configs/Client.json`

Run test nodes
--------------

### GraphNode Transmitter

`stack exec enq-node-haskell initialize
./configs/GraphNodeTransmitter.json`

### GraphNode Receiver

`stack exec enq-node-haskell initialize
./configs/GraphNodeReceiver.json`

### Fake PoW

`stack exec enq-node-haskell initialize ./configs/tst~pow~.json`

### Fake PoA

`stack exec enq-node-haskell initialize ./configs/tst~poa~.json`

Run routing nodes
-----------------

### Boot node

`stack exec enq-node-haskell initialize ./configs/BN.json`

### GraphNode

`stack exec enq-node-haskell initialize ./configs/GN_0.json`

`stack exec enq-node-haskell initialize ./configs/GN_1.json`

`stack exec enq-node-haskell initialize ./configs/GN_2.json`

`stack exec enq-node-haskell initialize ./configs/GN_3.json`

### Fake PoW

`stack exec enq-node-haskell initialize ./configs/pow.json`

### Fake PoA

`stack exec enq-node-haskell initialize ./configs/poa.json`