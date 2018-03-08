minikube start \
	--extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
	--extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key" \
	--extra-config=apiserver.Admission.PluginNames=NamespaceLifecycle,LimitRanger,ServiceAccount \
	--extra-config=apiserver.Admission.PluginNames=PersistentVolumeLabel,DefaultStorageClass \
	--extra-config=apiserver.Admission.PluginNames=DefaultTolerationSeconds,ResourceQuota \
	--extra-config=apiserver.Admission.PluginNames=MutatingAdmissionWebhook,ValidatingAdmissionWebhook \
	--kubernetes-version=v1.9.0
