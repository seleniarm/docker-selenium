# Selenium-Grid Helm Chart

This chart enables the creation of a Selenium Grid Server in Kubernetes.

## Installing the chart

If you want to install the latest master version of Selenium Grid onto your cluster you can do that by using the helm charts repository located at https://www.selenium.dev/docker-selenium.

```bash
# Add docker-selenium helm repository
helm repo add docker-selenium https://www.selenium.dev/docker-selenium

# Update charts from docker-selenium repo
helm repo update

# List all versions present in the docker-selenium repo
helm search repo docker-selenium --versions

# Install basic grid latest version
helm install selenium-grid docker-selenium/selenium-grid

# Or install full grid (Router, Distributor, EventBus, SessionMap and SessionQueue components separated)
helm install selenium-grid docker-selenium/selenium-grid --set isolateComponents=true

# Or install specified version
helm install selenium-grid docker-selenium/selenium-grid --version <version>

# In both cases grid exposed by default using ingress. You may want to set hostname for the grid. Default hostname is selenium-grid.local.
helm install selenium-grid --set ingress.hostname=selenium-grid.k8s.local docker-selenium/chart/selenium-grid/.
# Verify ingress configuration via kubectl get ingress
# Notes: In case you want to set hostname is selenium-grid.local. You need to add the IP and hostname to the local host file in `/etc/hosts`
```

## Enable Selenium Grid Autoscaling

Selenium Grid has the ability to autoscaling browser nodes up/down based on the pending requests in the 
session queue.

To do this [KEDA](https://keda.sh/docs/latest/scalers/selenium-grid-scaler/) is used. When enabling
autoscaling using `autoscaling.enabling` KEDA is installed automatically. To instead use an existing
installation of KEDA you can enable autoscaling with `autoscaling.enableWithExistingKEDA` instead.

KEDA can scale either with
[deployments](https://keda.sh/docs/latest/concepts/scaling-deployments/#scaling-of-deployments-and-statefulsets)
or [jobs](https://keda.sh/docs/latest/concepts/scaling-jobs/) and the charts support both types. This
chart support both modes.  It is controlled with `autoscaling.scalingType` that can be set to either
job (default) or deployment.

### Settings when scaling with deployments 

The `terminationGracePeriodSeconds` is set to 30 seconds by default. When scaling using deployments
the HPA choose pods to terminate randomly. If the chosen pod is currently executing a test rather
than being idle, then there is 30 seconds before the test is expected to complete. If your test is
still executing after 30 seconds, it would result in failure as the pod will be killed. If you want
to give more time for your tests to complete, you may set `terminationGracePeriodSeconds` to value
upto 3600 seconds.

## Updating Selenium-Grid release

Once you have a new chart version, you can update your selenium-grid running:

```bash
helm upgrade selenium-grid docker-selenium/selenium-grid
```

If needed, you can add sidecars for your browser nodes by running:

```bash
helm upgrade selenium-grid docker-selenium/selenium-grid --set 'firefoxNode.enabled=true' --set-json 'firefoxNode.sidecars=[{"name":"my-sidecar","image":"my-sidecar:latest","imagePullPolicy":"IfNotPresent","ports":[{"containerPort":8080, "protocol":"TCP"}],"resources":{"limits":{"memory": "128Mi"},"requests":{"cpu": "100m"}}}]'
```

Note: the parameter used for --set-json is just an example, please refer to [Container Spec](https://www.devspace.sh/component-chart/docs/configuration/containers) for an overview of usable parameters.

## Uninstalling Selenium Grid release

To uninstall:

```bash
helm uninstall selenium-grid
```

## Ingress Configuration

By default, ingress is enabled without annotations set. If NGINX ingress controller is used, you need to set few annotations to override the default timeout values to avoid 504 errors (see [#1808](https://github.com/SeleniumHQ/docker-selenium/issues/1808)). Since in Selenium Grid the default of `SE_NODE_SESSION_TIMEOUT` and `SE_SESSION_REQUEST_TIMEOUT` is `300` seconds.

In order to make user experience better, there are few annotations will be set by default if NGINX ingress controller is used. Mostly relates to timeouts and buffer sizes.

If you are not using NGINX ingress controller, you can disable these default annotations by setting `ingress.nginx` to `nil` (aka null) via Helm CLI `--set ingress.nginx=null`) or via an override-values.yaml as below:

```yaml
ingress:
  nginx:
  # nginx: null (alternative way)
```

Similarly, if you want to disable a sub-config of `ingress.nginx`. For example: `--set ingress.nginx.proxyBuffer=null`)

You are also able to combine using both default annotations and your own annotations in `ingress.annotations`. Duplicated keys will be merged strategy overwrite with your own annotations in `ingress.annotations` take precedence.

```yaml
ingress:
  nginx:
    proxyTimeout: 3600
  annotations:
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "7200" # This key will take 7200 instead of 3600
```

List mapping of chart values and default annotation(s)

```markdown
# `ingress.nginx.proxyTimeout` pass value to annotation(s)
nginx.ingress.kubernetes.io/proxy-connect-timeout
nginx.ingress.kubernetes.io/proxy-send-timeout
nginx.ingress.kubernetes.io/proxy-read-timeout
nginx.ingress.kubernetes.io/proxy-next-upstream-timeout
nginx.ingress.kubernetes.io/auth-keepalive-timeout

# `ingress.nginx.proxyBuffer` pass value to to annotation(s)
nginx.ingress.kubernetes.io/proxy-request-buffering: "on"
nginx.ingress.kubernetes.io/proxy-buffering: "on"

# `ingress.nginx.proxyBuffer.size` pass value to to annotation(s)
nginx.ingress.kubernetes.io/proxy-buffer-size
nginx.ingress.kubernetes.io/client-body-buffer-size

# `ingress.nginx.proxyBuffer.number` pass value to annotation(s)
nginx.ingress.kubernetes.io/proxy-buffers-number
```

## Configuration

For now, global configuration supported is:

| Parameter                             | Default               | Description                           |
|---------------------------------------|-----------------------|---------------------------------------|
| `global.seleniumGrid.imageRegistry`   | `selenium`            | Distribution registry to pull images  |
| `global.seleniumGrid.imageTag`        | `4.16.1-20231212`     | Image tag for all selenium components |
| `global.seleniumGrid.nodesImageTag`   | `4.16.1-20231212`     | Image tag for browser's nodes         |
| `global.seleniumGrid.videoImageTag`   | `ffmpeg-6.1-20231212` | Image tag for browser's video recoder |
| `global.seleniumGrid.imagePullSecret` | `""`                  | Pull secret to be used for all images |
| `global.seleniumGrid.imagePullSecret` | `""`                  | Pull secret to be used for all images |
| `global.seleniumGrid.affinity`        | `{}`                  | Affinity assigned globally            |

This table contains the configuration parameters of the chart and their default values:

| Parameter                                     | Default                                     | Description                                                                                                                |
|-----------------------------------------------|---------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
| `basicAuth.enabled`                           | `true`                                      | Enable or disable basic auth for Selenium Grid                                                                             |
| `basicAuth.username`                          | `admin`                                     | Username of basic auth for Selenium Grid                                                                                   |
| `basicAuth.password`                          | `admin`                                     | Password of basic auth for Selenium Grid                                                                                   |
| `isolateComponents`                           | `false`                                     | Deploy Router, Distributor, EventBus, SessionMap and Nodes separately                                                      |
| `serviceAccount.create`                       | `true`                                      | Enable or disable creation of service account (if `false`, `serviceAccount.name` MUST be specified                         |
| `serviceAccount.name`                         | `""`                                        | Name of the service account to be made or existing service account to use for all deployments and jobs                     |
| `serviceAccount.annotations`                  | `{}`                                        | Custom annotations for service account                                                                                     |
| `busConfigMap.name`                           | `selenium-event-bus-config`                 | Name of the configmap that contains SE_EVENT_BUS_HOST, SE_EVENT_BUS_PUBLISH_PORT and SE_EVENT_BUS_SUBSCRIBE_PORT variables |
| `busConfigMap.annotations`                    | `{}`                                        | Custom annotations for configmap                                                                                           |
| `nodeConfigMap.name`                          | `selenium-node-config`                      | Name of the configmap that contains common environment variables for browser nodes                                         |
| `nodeConfigMap.annotations`                   | `{}`                                        | Custom annotations for configmap                                                                                           |
| `ingress.enabled`                             | `true`                                      | Enable or disable ingress resource                                                                                         |
| `ingress.className`                           | `""`                                        | Name of ingress class to select which controller will implement ingress resource                                           |
| `ingress.annotations`                         | `{}`                                        | Custom annotations for ingress resource                                                                                    |
| `ingress.nginx.proxyTimeout`                  | `3600`                                      | Value is used to set for NGINX ingress annotations related to proxy timeout                                                |
| `ingress.nginx.proxyBuffer.size`              | `512M`                                      | Value is used to set for NGINX ingress annotations on size of the buffer proxy_buffer_size used for reading                |
| `ingress.nginx.proxyBuffer.number`            | `4`                                         | Value is used to set for NGINX ingress annotations on number of the buffers in proxy_buffers used for reading              |
| `ingress.hostname`                            | ``                                          | Default host for the ingress resource                                                                                      |
| `ingress.path`                                | `/`                                         | Default host path for the ingress resource                                                                                 |
| `ingress.pathType`                            | `Prefix`                                    | Default path type for the ingress resource                                                                                 |
| `ingress.paths`                               | `[]`                                        | List of paths config for the ingress resource. This will override the default path                                         |
| `ingress.tls`                                 | `[]`                                        | TLS backend configuration for ingress resource                                                                             |
| `autoscaling.enableWithExistingKEDA`          | `false`                                     | Enable autoscaling of browser nodes.                                                                                       |
| `autoscaling.enabled`                         | `false`                                     | Same as above plus installation of KEDA                                                                                    |
| `autoscaling.scalingType`                     | `job`                                       | Which typ of KEDA scaling to use: `job` or `deployment`                                                                    |
| `autoscaling.scaledOptions`                   | See `values.yaml`                           | Common options for KEDA scaled resources (both ScaledJobs and ScaledObjects)                                               |
| `autoscaling.scaledOptions.minReplicaCount`   | `0`                                         | Min number of replicas that each browser nodes has when autoscaling                                                        |
| `autoscaling.scaledOptions.maxReplicaCount`   | `8`                                         | Max number of replicas that each browser nodes can auto scale up to                                                        |
| `autoscaling.scaledOptions.pollingInterval`   | `10`                                        | The interval to check each trigger on                                                                                      |
| `autoscaling.scaledJobOptions`                | See `values.yaml`                           | Options for KEDA ScaledJobs (when `scalingType` is set to `job`)                                                           |
| `autoscaling.scaledObjectOptions`             | See `values.yaml`                           | Options for KEDA ScaledObjects (when `scalingType` is set to `deployment`)                                                 |
| `autoscaling.deregisterLifecycle`             | See `values.yaml`                           | Lifecycle applied to pods of deployments controlled by KEDA. Makes the node deregister from selenium hub                   |
| `chromeNode.enabled`                          | `true`                                      | Enable chrome nodes                                                                                                        |
| `chromeNode.deploymentEnabled`                | `true`                                      | Enable creation of Deployment for chrome nodes                                                                             |
| `chromeNode.replicas`                         | `1`                                         | Number of chrome nodes. Disabled if autoscaling is enabled.                                                                |
| `chromeNode.imageRegistry`                    | `nil`                                       | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                       |
| `chromeNode.imageName`                        | `node-chrome`                               | Image of chrome nodes                                                                                                      |
| `chromeNode.imageTag`                         | `4.16.1-20231212`                           | Image of chrome nodes                                                                                                      |
| `chromeNode.imagePullPolicy`                  | `IfNotPresent`                              | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                             |
| `chromeNode.imagePullSecret`                  | `""`                                        | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)               |
| `chromeNode.ports`                            | `[5555]`                                    | Port list to enable on container                                                                                           |
| `chromeNode.seleniumPort`                     | `5900`                                      | Selenium port (spec.ports[0].targetPort in kubernetes service)                                                             |
| `chromeNode.seleniumServicePort`              | `6900`                                      | Selenium port exposed in service (spec.ports[0].port in kubernetes service)                                                |
| `chromeNode.annotations`                      | `{}`                                        | Annotations for chrome-node pods                                                                                           |
| `chromeNode.labels`                           | `{}`                                        | Labels for chrome-node pods                                                                                                |
| `chromeNode.resources`                        | `See values.yaml`                           | Resources for chrome-node pods                                                                                             |
| `chromeNode.securityContext`                  | `See values.yaml`                           | Security context for chrome-node pods                                                                                      |
| `chromeNode.tolerations`                      | `[]`                                        | Tolerations for chrome-node pods                                                                                           |
| `chromeNode.nodeSelector`                     | `{}`                                        | Node Selector for chrome-node pods                                                                                         |
| `chromeNode.affinity`                         | `{}`                                        | Affinity for chrome-node pods                                                                                              |
| `chromeNode.hostAliases`                      | `nil`                                       | Custom host aliases for chrome nodes                                                                                       |
| `chromeNode.priorityClassName`                | `""`                                        | Priority class name for chrome-node pods                                                                                   |
| `chromeNode.extraEnvironmentVariables`        | `nil`                                       | Custom environment variables for chrome nodes                                                                              |
| `chromeNode.extraEnvFrom`                     | `nil`                                       | Custom environment taken from `configMap` or `secret` variables for chrome nodes                                           |
| `chromeNode.service.enabled`                  | `true`                                      | Create a service for node                                                                                                  |
| `chromeNode.service.type`                     | `ClusterIP`                                 | Service type                                                                                                               |
| `chromeNode.service.loadBalancerIP`           | ``                                          | Set specific loadBalancerIP when serviceType is LoadBalancer                                                               |
| `chromeNode.service.ports`                    | `[]`                                        | Extra ports exposed in node service                                                                                        |
| `chromeNode.service.annotations`              | `{}`                                        | Custom annotations for service                                                                                             |
| `chromeNode.dshmVolumeSizeLimit`              | `1Gi`                                       | Size limit for DSH volume mounted in container (if not set, default is "1Gi")                                              |
| `chromeNode.startupProbe`                     | `{}`                                        | Probe to check pod is started successfully                                                                                 |
| `chromeNode.livenessProbe`                    | `{}`                                        | Liveness probe settings                                                                                                    |
| `chromeNode.terminationGracePeriodSeconds`    | `30`                                        | Time to graceful terminate container (default: 30s)                                                                        |
| `chromeNode.lifecycle`                        | `{}`                                        | hooks to make pod correctly shutdown or started                                                                            |
| `chromeNode.extraVolumeMounts`                | `[]`                                        | Extra mounts of declared ExtraVolumes into pod                                                                             |
| `chromeNode.extraVolumes`                     | `[]`                                        | Extra Volumes declarations to be used in the pod (can be any supported volume type: ConfigMap, Secret, PVC, NFS, etc.)     |
| `chromeNode.hpa.url`                          | `{{ include "seleniumGrid.graphqlURL" . }}` | Graphql Url of the hub or the router                                                                                       |
| `chromeNode.hpa.browserName`                  | `chrome`                                    | BrowserName from the capability                                                                                            |
| `chromeNode.hpa.browserVersion`               | ``                                          | BrowserVersion from the capability                                                                                         |
| `chromeNode.scaledOptions`                    | See `values.yaml`                           | Override the global `autoscaling.scaledOptions` with specific scaled options for chrome nodes                              |
| `chromeNode.scaledJobOptions`                 | See `values.yaml`                           | Override the global `autoscaling.scaledJobOptions` with specific scaled options for chrome nodes                           |
| `chromeNode.scaledObjectOptions`              | See `values.yaml`                           | Override the global `autoscaling.scaledObjectOptions` with specific scaled options for chrome nodes                        |
| `firefoxNode.enabled`                         | `true`                                      | Enable firefox nodes                                                                                                       |
| `firefoxNode.deploymentEnabled`               | `true`                                      | Enable creation of Deployment for firefox nodes                                                                            |
| `firefoxNode.replicas`                        | `1`                                         | Number of firefox nodes. Disabled if autoscaling is enabled.                                                               |
| `firefoxNode.imageRegistry`                   | `nil`                                       | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                       |
| `firefoxNode.imageName`                       | `node-firefox`                              | Image of firefox nodes                                                                                                     |
| `firefoxNode.imageTag`                        | `4.16.1-20231212`                           | Image of firefox nodes                                                                                                     |
| `firefoxNode.imagePullPolicy`                 | `IfNotPresent`                              | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                             |
| `firefoxNode.imagePullSecret`                 | `""`                                        | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)               |
| `firefoxNode.ports`                           | `[5555]`                                    | Port list to enable on container                                                                                           |
| `firefoxNode.seleniumPort`                    | `5900`                                      | Selenium port (spec.ports[0].targetPort in kubernetes service)                                                             |
| `firefoxNode.seleniumServicePort`             | `6900`                                      | Selenium port exposed in service (spec.ports[0].port in kubernetes service)                                                |
| `firefoxNode.annotations`                     | `{}`                                        | Annotations for firefox-node pods                                                                                          |
| `firefoxNode.labels`                          | `{}`                                        | Labels for firefox-node pods                                                                                               |
| `firefoxNode.resources`                       | `See values.yaml`                           | Resources for firefox-node pods                                                                                            |
| `firefoxNode.securityContext`                 | `See values.yaml`                           | Security context for firefox-node pods                                                                                     |
| `firefoxNode.tolerations`                     | `[]`                                        | Tolerations for firefox-node pods                                                                                          |
| `firefoxNode.nodeSelector`                    | `{}`                                        | Node Selector for firefox-node pods                                                                                        |
| `firefoxNode.affinity`                        | `{}`                                        | Affinity for firefox-node pods                                                                                             |
| `firefoxNode.hostAliases`                     | `nil`                                       | Custom host aliases for firefox nodes                                                                                      |
| `firefoxNode.priorityClassName`               | `""`                                        | Priority class name for firefox-node pods                                                                                  |
| `firefoxNode.extraEnvironmentVariables`       | `nil`                                       | Custom environment variables for firefox nodes                                                                             |
| `firefoxNode.extraEnvFrom`                    | `nil`                                       | Custom environment variables taken from `configMap` or `secret` for firefox nodes                                          |
| `firefoxNode.service.enabled`                 | `true`                                      | Create a service for node                                                                                                  |
| `firefoxNode.service.type`                    | `ClusterIP`                                 | Service type                                                                                                               |
| `firefoxNode.service.loadBalancerIP`          | ``                                          | Set specific loadBalancerIP when serviceType is LoadBalancer                                                               |
| `firefoxNode.service.ports`                   | `[]`                                        | Extra ports exposed in node service                                                                                        |
| `firefoxNode.service.annotations`             | `{}`                                        | Custom annotations for service                                                                                             |
| `firefoxNode.dshmVolumeSizeLimit`             | `1Gi`                                       | Size limit for DSH volume mounted in container (if not set, default is "1Gi")                                              |
| `firefoxNode.startupProbe`                    | `{}`                                        | Probe to check pod is started successfully                                                                                 |
| `firefoxNode.livenessProbe`                   | `{}`                                        | Liveness probe settings                                                                                                    |
| `firefoxNode.terminationGracePeriodSeconds`   | `30`                                        | Time to graceful terminate container (default: 30s)                                                                        |
| `firefoxNode.lifecycle`                       | `{}`                                        | hooks to make pod correctly shutdown or started                                                                            |
| `firefoxNode.extraVolumeMounts`               | `[]`                                        | Extra mounts of declared ExtraVolumes into pod                                                                             |
| `firefoxNode.extraVolumes`                    | `[]`                                        | Extra Volumes declarations to be used in the pod (can be any supported volume type: ConfigMap, Secret, PVC, NFS, etc.)     |
| `firefoxNode.hpa.url`                         | `{{ include "seleniumGrid.graphqlURL" . }}` | Graphql Url of the hub or the router                                                                                       |
| `firefoxNode.hpa.browserName`                 | `firefox`                                   | BrowserName from the capability                                                                                            |
| `firefoxNode.hpa.browserVersion`              | ``                                          | BrowserVersion from the capability                                                                                         |
| `firefoxNode.scaledOptions`                   | See `values.yaml`                           | Override the global `autoscaling.scaledOptions` with specific scaled options for firefox nodes                             |
| `firefoxNode.scaledJobOptions`                | See `values.yaml`                           | Override the global `autoscaling.scaledJobOptions` with specific scaled options for firefox nodes                          |
| `firefoxNode.scaledObjectOptions`             | See `values.yaml`                           | Override the global `autoscaling.scaledObjectOptions` with specific scaled options for firefox nodes                       |
| `edgeNode.enabled`                            | `true`                                      | Enable edge nodes                                                                                                          |
| `edgeNode.deploymentEnabled`                  | `true`                                      | Enable creation of Deployment for edge nodes                                                                               |
| `edgeNode.replicas`                           | `1`                                         | Number of edge nodes. Disabled if autoscaling is enabled.                                                                  |
| `edgeNode.imageRegistry`                      | `nil`                                       | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                       |
| `edgeNode.imageName`                          | `node-edge`                                 | Image of edge nodes                                                                                                        |
| `edgeNode.imageTag`                           | `4.16.1-20231212`                           | Image of edge nodes                                                                                                        |
| `edgeNode.imagePullPolicy`                    | `IfNotPresent`                              | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                             |
| `edgeNode.imagePullSecret`                    | `""`                                        | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)               |
| `edgeNode.ports`                              | `[5555]`                                    | Port list to enable on container                                                                                           |
| `edgeNode.seleniumPort`                       | `5900`                                      | Selenium port (spec.ports[0].targetPort in kubernetes service)                                                             |
| `edgeNode.seleniumServicePort`                | `6900`                                      | Selenium port exposed in service (spec.ports[0].port in kubernetes service)                                                |
| `edgeNode.annotations`                        | `{}`                                        | Annotations for edge-node pods                                                                                             |
| `edgeNode.labels`                             | `{}`                                        | Labels for edge-node pods                                                                                                  |
| `edgeNode.resources`                          | `See values.yaml`                           | Resources for edge-node pods                                                                                               |
| `edgeNode.securityContext`                    | `See values.yaml`                           | Security context for edge-node pods                                                                                        |
| `edgeNode.tolerations`                        | `[]`                                        | Tolerations for edge-node pods                                                                                             |
| `edgeNode.nodeSelector`                       | `{}`                                        | Node Selector for edge-node pods                                                                                           |
| `edgeNode.affinity`                           | `{}`                                        | Affinity for edge-node pods                                                                                                |
| `edgeNode.hostAliases`                        | `nil`                                       | Custom host aliases for edge nodes                                                                                         |
| `edgeNode.priorityClassName`                  | `""`                                        | Priority class name for edge-node pods                                                                                     |
| `edgeNode.extraEnvironmentVariables`          | `nil`                                       | Custom environment variables for firefox nodes                                                                             |
| `edgeNode.extraEnvFrom`                       | `nil`                                       | Custom environment taken from `configMap` or `secret` variables for firefox nodes                                          |
| `edgeNode.service.enabled`                    | `true`                                      | Create a service for node                                                                                                  |
| `edgeNode.service.type`                       | `ClusterIP`                                 | Service type                                                                                                               |
| `edgeNode.service.loadBalancerIP`             | ``                                          | Set specific loadBalancerIP when serviceType is LoadBalancer                                                               |
| `edgeNode.service.ports`                      | `[]`                                        | Extra ports exposed in node service                                                                                        |
| `edgeNode.service.annotations`                | `{}`                                        | Custom annotations for service                                                                                             |
| `edgeNode.dshmVolumeSizeLimit`                | `1Gi`                                       | Size limit for DSH volume mounted in container (if not set, default is "1Gi")                                              |
| `edgeNode.startupProbe`                       | `{}`                                        | Probe to check pod is started successfully                                                                                 |
| `edgeNode.livenessProbe`                      | `{}`                                        | Liveness probe settings                                                                                                    |
| `edgeNode.terminationGracePeriodSeconds`      | `30`                                        | Time to graceful terminate container (default: 30s)                                                                        |
| `edgeNode.lifecycle`                          | `{}`                                        | hooks to make pod correctly shutdown or started                                                                            |
| `edgeNode.extraVolumeMounts`                  | `[]`                                        | Extra mounts of declared ExtraVolumes into pod                                                                             |
| `edgeNode.extraVolumes`                       | `[]`                                        | Extra Volumes declarations to be used in the pod (can be any supported volume type: ConfigMap, Secret, PVC, NFS, etc.)     |
| `edgeNode.hpa.url`                            | `{{ include "seleniumGrid.graphqlURL" . }}` | Graphql Url of the hub or the router                                                                                       |
| `edgeNode.hpa.browserName`                    | `edge`                                      | BrowserName from the capability                                                                                            |
| `edgeNode.hpa.browserVersion`                 | ``                                          | BrowserVersion from the capability                                                                                         |
| `edgeNode.scaledOptions`                      | See `values.yaml`                           | Override the global `autoscaling.scaledOptions` with specific scaled options for edge nodes                                |
| `edgeNode.scaledJobOptions`                   | See `values.yaml`                           | Override the global `autoscaling.scaledJobOptions` with specific scaled options for edge nodes                             |
| `edgeNode.scaledObjectOptions`                | See `values.yaml`                           | Override the global `autoscaling.scaledObjectOptions` with specific scaled options for edge nodes                          |
| `videoRecorder.enabled`                       | `false`                                     | Enable video recorder for node                                                                                             |
| `videoRecorder.imageRegistry`                 | `nil`                                       | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                       |
| `videoRecorder.imageName`                     | `video`                                     | Selenium video recoder image name                                                                                          |
| `videoRecorder.imageTag`                      | `ffmpeg-6.1-20231212`                       | Image tag of video recorder                                                                                                |
| `videoRecorder.imagePullPolicy`               | `IfNotPresent`                              | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                             |
| `videoRecorder.uploader`                      | `false`                                     | Name of the uploader to use. The value `false` is used to disable uploader. Supported default `s3`                         |
| `videoRecorder.uploadDestinationPrefix`       | `false`                                     | Destination URL for uploading video file. The value `false` is used to disable the uploading                               |
| `videoRecorder.ports`                         | `[9000]`                                    | Port list to enable on video recorder container                                                                            |
| `videoRecorder.resources`                     | `See values.yaml`                           | Resources for video recorder                                                                                               |
| `videoRecorder.extraEnvironmentVariables`     | `nil`                                       | Custom environment variables for video recorder                                                                            |
| `videoRecorder.extraEnvFrom`                  | `nil`                                       | Custom environment taken from `configMap` or `secret` variables for video recorder                                         |
| `videoRecorder.terminationGracePeriodSeconds` | `30`                                        | Time to graceful terminate container (default: 30s)                                                                        |
| `videoRecorder.startupProbe`                  | `{}`                                        | Probe to check pod is started successfully                                                                                 |
| `videoRecorder.livenessProbe`                 | `{}`                                        | Liveness probe settings                                                                                                    |
| `videoRecorder.volume.name.folder`            | `video`                                     | Name is used to set for the volume to persist and share output video folder in container                                   |
| `videoRecorder.volume.name.scripts`           | `video-scripts`                             | Name is used to set for the volume to persist and share video recorder scripts in container                                |
| `videoRecorder.extraVolumeMounts`             | `[]`                                        | Extra mounts of declared ExtraVolumes into pod                                                                             |
| `videoRecorder.extraVolumes`                  | `[]`                                        | Extra Volumes declarations to be used in the pod (can be any supported volume type: ConfigMap, Secret, PVC, NFS, etc.)     |
| `videoRecorder.s3`                            | `See values.yaml`                           | Container spec for the uploader if `videoRecorder.uploader` is `s3`. Similarly, create for your new uploader               |
| `videoRecorder.s3.resources`                  | `See values.yaml`                           | Resources for video uploader                                                                                               |
| `videoRecorder.s3.extraEnvironmentVariables`  | ``                                          | Custom environment variables for video uploader container                                                                  |
| `videoRecorder.s3.extraEnvFrom`               | ``                                          | Custom environment taken from `configMap` or `secret` variables for video uploader                                         |
| `videoRecorder.s3.extraVolumeMounts`          | `[]`                                        | Extra mounts of declared ExtraVolumes into pod of video uploader                                                           |
| `customLabels`                                | `{}`                                        | Custom labels for k8s resources                                                                                            |


### Configuration of KEDA

If you are setting `autoscaling.enabled` to `true` KEDA is installed and can be configured with
values with the prefix `keda`. So you can for example set `keda.prometheus.metricServer.enabled` to
`true` to enable the metrics server for KEDA.  See
https://github.com/kedacore/charts/blob/main/keda/README.md for more details.

### Configuration for Selenium-Hub

You can configure the Selenium Hub with these values:

| Parameter                       | Default           | Description                                                                                                                                      |
|---------------------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| `hub.imageRegistry`             | `nil`             | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                                             |
| `hub.imageName`                 | `hub`             | Selenium Hub image name                                                                                                                          |
| `hub.imageTag`                  | `nil`             | Selenium Hub image tag (this overwrites `.global.seleniumGrid.imageTag` value)                                                                   |
| `hub.imagePullPolicy`           | `IfNotPresent`    | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                                                   |
| `hub.imagePullSecret`           | `""`              | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)                                     |
| `hub.annotations`               | `{}`              | Custom annotations for Selenium Hub pod                                                                                                          |
| `hub.labels`                    | `{}`              | Custom labels for Selenium Hub pod                                                                                                               |
| `hub.publishPort`               | `4442`            | Port where events are published                                                                                                                  |
| `hub.subscribePort`             | `4443`            | Port where to subscribe for events                                                                                                               |
| `hub.port`                      | `4444`            | Selenium Hub port                                                                                                                                |
| `hub.livenessProbe`             | `See values.yaml` | Liveness probe settings                                                                                                                          |
| `hub.readinessProbe`            | `See values.yaml` | Readiness probe settings                                                                                                                         |
| `hub.tolerations`               | `[]`              | Tolerations for selenium-hub pods                                                                                                                |
| `hub.nodeSelector`              | `{}`              | Node Selector for selenium-hub pods                                                                                                              |
| `hub.affinity`                  | `{}`              | Affinity for selenium-hub pods                                                                                                                   |
| `hub.priorityClassName`         | `""`              | Priority class name for selenium-hub pods                                                                                                        |
| `hub.subPath`                   | `/`               | Custom sub path for the hub deployment                                                                                                           |
| `hub.extraEnvironmentVariables` | `nil`             | Custom environment variables for selenium-hub                                                                                                    |
| `hub.extraEnvFrom`              | `nil`             | Custom environment variables for selenium taken from `configMap` or `secret`-hub                                                                 |
| `hub.extraVolumeMounts`         | `[]`              | Extra mounts of declared ExtraVolumes into pod                                                                                                   |
| `hub.extraVolumes`              | `[]`              | Extra Volumes declarations to be used in the pod (can be any supported volume type: ConfigMap, Secret, PVC, NFS, etc.)                           |
| `hub.resources`                 | `{}`              | Resources for selenium-hub container                                                                                                             |
| `hub.securityContext`           | `See values.yaml` | Security context for selenium-hub container                                                                                                      |
| `hub.serviceType`               | `ClusterIP`       | Kubernetes service type (see https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)                 |
| `hub.loadBalancerIP`            | `nil`             | Set specific loadBalancerIP when serviceType is LoadBalancer (see https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer) |
| `hub.serviceAnnotations`        | `{}`              | Custom annotations for Selenium Hub service                                                                                                      |


### Configuration for isolated components

If you implement selenium-grid with separate components (`isolateComponents: true`), you can configure all components via the following values:

| Parameter                                    | Default           | Description                                                                                                                                      |
|----------------------------------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| `components.router.imageRegistry`            | `nil`             | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                                             |
| `components.router.imageName`                | `router`          | Router image name                                                                                                                                |
| `components.router.imageTag`                 | `nil`             | Router image tag (this overwrites `.global.seleniumGrid.imageTag` value)                                                                         |
| `components.router.imagePullPolicy`          | `IfNotPresent`    | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                                                   |
| `components.router.imagePullSecret`          | `""`              | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)                                     |
| `components.router.annotations`              | `{}`              | Custom annotations for router pod                                                                                                                |
| `components.router.port`                     | `4444`            | Router port                                                                                                                                      |
| `components.router.livenessProbe`            | `See values.yaml` | Liveness probe settings                                                                                                                          |
| `components.router.readinessProbe`           | `See values.yaml` | Readiness probe settings                                                                                                                         |
| `components.router.resources`                | `{}`              | Resources for router pod                                                                                                                         |
| `components.router.securityContext`          | `See values.yaml` | Security context for router pod                                                                                                                  |
| `components.router.serviceType`              | `ClusterIP`       | Kubernetes service type (see https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)                 |
| `components.router.loadBalancerIP`           | `nil`             | Set specific loadBalancerIP when serviceType is LoadBalancer (see https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer) |
| `components.router.serviceAnnotations`       | `{}`              | Custom annotations for router service                                                                                                            |
| `components.router.tolerations`              | `[]`              | Tolerations for router pods                                                                                                                      |
| `components.router.nodeSelector`             | `{}`              | Node Selector for router pods                                                                                                                    |
| `components.router.affinity`                 | `{}`              | Affinity for router pods                                                                                                                         |
| `components.router.priorityClassName`        | `""`              | Priority class name for router pods                                                                                                              |
| `components.distributor.imageRegistry`       | `nil`             | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                                             |
| `components.distributor.imageName`           | `distributor`     | Distributor image name                                                                                                                           |
| `components.distributor.imageTag`            | `nil`             | Distributor image tag  (this overwrites `.global.seleniumGrid.imageTag` value)                                                                   |
| `components.distributor.imagePullPolicy`     | `IfNotPresent`    | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                                                   |
| `components.distributor.imagePullSecret`     | `""`              | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)                                     |
| `components.distributor.annotations`         | `{}`              | Custom annotations for Distributor pod                                                                                                           |
| `components.distributor.port`                | `5553`            | Distributor port                                                                                                                                 |
| `components.distributor.resources`           | `{}`              | Resources for Distributor pod                                                                                                                    |
| `components.distributor.securityContext`     | `See values.yaml` | Security context for Distributor pod                                                                                                             |
| `components.distributor.serviceType`         | `ClusterIP`       | Kubernetes service type (see https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)                 |
| `components.distributor.serviceAnnotations`  | `{}`              | Custom annotations for Distributor service                                                                                                       |
| `components.distributor.tolerations`         | `[]`              | Tolerations for Distributor pods                                                                                                                 |
| `components.distributor.nodeSelector`        | `{}`              | Node Selector for Distributor pods                                                                                                               |
| `components.distributor.affinity`            | `{}`              | Affinity for Distributor pods                                                                                                                    |
| `components.distributor.priorityClassName`   | `""`              | Priority class name for Distributor pods                                                                                                         |
| `components.eventBus.imageRegistry`          | `nil`             | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                                             |
| `components.eventBus.imageName`              | `event-bus`       | Event Bus image name                                                                                                                             |
| `components.eventBus.imageTag`               | `nil`             | Event Bus image tag  (this overwrites `.global.seleniumGrid.imageTag` value)                                                                     |
| `components.eventBus.imagePullPolicy`        | `IfNotPresent`    | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                                                   |
| `components.eventBus.imagePullSecret`        | `""`              | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)                                     |
| `components.eventBus.annotations`            | `{}`              | Custom annotations for Event Bus pod                                                                                                             |
| `components.eventBus.port`                   | `5557`            | Event Bus port                                                                                                                                   |
| `components.eventBus.publishPort`            | `4442`            | Port where events are published                                                                                                                  |
| `components.eventBus.subscribePort`          | `4443`            | Port where to subscribe for events                                                                                                               |
| `components.eventBus.resources`              | `{}`              | Resources for event-bus pod                                                                                                                      |
| `components.eventBus.securityContext`        | `See values.yaml` | Security context for event-bus pod                                                                                                               |
| `components.eventBus.serviceType`            | `ClusterIP`       | Kubernetes service type (see https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)                 |
| `components.eventBus.serviceAnnotations`     | `{}`              | Custom annotations for Event Bus service                                                                                                         |
| `components.eventBus.tolerations`            | `[]`              | Tolerations for Event Bus pods                                                                                                                   |
| `components.eventBus.nodeSelector`           | `{}`              | Node Selector for Event Bus pods                                                                                                                 |
| `components.eventBus.affinity`               | `{}`              | Affinity for Event Bus pods                                                                                                                      |
| `components.eventBus.priorityClassName`      | `""`              | Priority class name for Event Bus pods                                                                                                           |
| `components.sessionMap.imageRegistry`        | `nil`             | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                                             |
| `components.sessionMap.imageName`            | `sessions`        | Session Map image name                                                                                                                           |
| `components.sessionMap.imageTag`             | `nil`             | Session Map image tag  (this overwrites `.global.seleniumGrid.imageTag` value)                                                                   |
| `components.sessionMap.imagePullPolicy`      | `IfNotPresent`    | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                                                   |
| `components.sessionMap.imagePullSecret`      | `""`              | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)                                     |
| `components.sessionMap.annotations`          | `{}`              | Custom annotations for Session Map pod                                                                                                           |
| `components.sessionMap.resources`            | `{}`              | Resources for Session Map pod                                                                                                                    |
| `components.sessionMap.securityContext`      | `See values.yaml` | Security context for Session Map pod                                                                                                             |
| `components.sessionMap.serviceType`          | `ClusterIP`       | Kubernetes service type (see https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)                 |
| `components.sessionMap.serviceAnnotations`   | `{}`              | Custom annotations for Session Map service                                                                                                       |
| `components.sessionMap.tolerations`          | `[]`              | Tolerations for Session Map pods                                                                                                                 |
| `components.sessionMap.nodeSelector`         | `{}`              | Node Selector for Session Map pods                                                                                                               |
| `components.sessionMap.affinity`             | `{}`              | Affinity for Session Map pods                                                                                                                    |
| `components.sessionMap.priorityClassName`    | `""`              | Priority class name for Session Map pods                                                                                                         |
| `components.sessionQueue.imageRegistry`      | `nil`             | Distribution registry to pull the image (this overwrites `.global.seleniumGrid.imageRegistry` value)                                             |
| `components.sessionQueue.imageName`          | `session-queue`   | Session Queue image name                                                                                                                         |
| `components.sessionQueue.imageTag`           | `nil`             | Session Queue image tag  (this overwrites `.global.seleniumGrid.imageTag` value)                                                                 |
| `components.sessionQueue.imagePullPolicy`    | `IfNotPresent`    | Image pull policy (see https://kubernetes.io/docs/concepts/containers/images/#updating-images)                                                   |
| `components.sessionQueue.imagePullSecret`    | `""`              | Image pull secret (see https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry)                                     |
| `components.sessionQueue.annotations`        | `{}`              | Custom annotations for Session Queue pod                                                                                                         |
| `components.sessionQueue.port`               | `5559`            | Session Queue Port                                                                                                                               |
| `components.sessionQueue.resources`          | `{}`              | Resources for Session Queue pod                                                                                                                  |
| `components.sessionQueue.securityContext`    | `See values.yaml` | Security context for Session Queue pod                                                                                                           |
| `components.sessionQueue.serviceType`        | `ClusterIP`       | Kubernetes service type (see https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)                 |
| `components.sessionQueue.serviceAnnotations` | `{}`              | Custom annotations for Session Queue service                                                                                                     |
| `components.sessionQueue.tolerations`        | `[]`              | Tolerations for Session Queue pods                                                                                                               |
| `components.sessionQueue.nodeSelector`       | `{}`              | Node Selector for Session Queue pods                                                                                                             |
| `components.sessionQueue.affinity`           | `{}`              | Affinity for Session Queue pods                                                                                                                  |
| `components.sessionQueue.priorityClassName`  | `""`              | Priority class name for Session Queue pods                                                                                                       |
| `components.subPath`                         | `/`               | Custom sub path for all components                                                                                                               |
| `components.extraEnvironmentVariables`       | `nil`             | Custom environment variables for all components                                                                                                  |
| `components.extraEnvFrom`                    | `nil`             | Custom environment variables taken from `configMap` or `secret` for all components                                                               |

See how to customize a helm chart installation in the [Helm Docs](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing) for more information.
