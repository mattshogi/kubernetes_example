apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: {{ .Cluster.CertData }}
    server: https://{{ .Node.PublicIP }}:6443
  name: k3s-cluster
contexts:
- context:
    cluster: k3s-cluster
    user: admin
  name: k3s-context
current-context: k3s-context
kind: Config
preferences: {}
users:
- name: admin
  user:
    token: {{ .Cluster.Token }}
