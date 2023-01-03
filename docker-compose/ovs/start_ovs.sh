#!/usr/bin/env bash
ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
  --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
  --remote=ptcp:6640 \
  --pidfile \
  --detach

ovs-vsctl --no-wait init
ovs-vsctl --no-wait set-manager ptcp:6640
ovs-vsctl --no-wait add-br br-int
ovs-vswitchd --pidfile
