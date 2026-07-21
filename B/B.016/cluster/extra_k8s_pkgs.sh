#!/usr/bin/env bash
# (intentionally empty)
#
# MetalLB is no longer applied during CP provisioning. On a tainted single CP node the MetalLB
# controller cannot be scheduled (Pending), so a synchronous apply here would time out waiting for
# the controller to be Ready, the IPAddressPool apply would fail, and the whole provisioning would
# abort (before the workers are even created). MetalLB application is therefore moved to up.sh and
# runs after all nodes are Ready (= the controller can be scheduled on a worker). See metallb.sh.

exit 0
