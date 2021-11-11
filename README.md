# ArangoDB Helm Chart

A Helm chart for ArangoDB, A scalable, fully managed graph database, document store and search engine in one place.

This is an alternative option using only kubernetes primitives to deploy a HA cluster. Useful for scenarios where a limited RBAC setup prevents the use of the official [kube-arangodb](https://github.com/arangodb/kube-arangodb) kubernetes operator.

# Prerequisites

To use this chart, [Helm](https://helm.sh/) must be configured for your Kubernetes cluster. Setting up Kubernetes and Helm is outside the scope of this README. Please refer to the Kubernetes and Helm documentation.

The versions required are:

- **Helm 3.7+** - This is the earliest version of Helm tested. It is possible it works with earlier versions but this chart is untested for those versions.

- **Kubernetes 1.20+** - This is the earliest version of Kubernetes tested. It is possible that this chart works with earlier versions but it is untested.
