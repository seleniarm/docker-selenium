# Change Log

All notable changes to this helm chart will be documented in this file.

## :heavy_check_mark: 0.24.0

### Added

- Update tag in docs and files [skip ci] :: Selenium CI Bot
- Bumping chart version :: Diego Molina
- Fix minor issues after PR #1881 and #1981 (#1983) :: Viet Nguyen Duc
- Improve default value for videoRecorder in chart (#1984) :: Viet Nguyen Duc
- Improve chart templates in the section videoRecorder (#1987) :: Viet Nguyen Duc
- Update to Selenium 4.15.0 (#1990) :: Luis Correia
- feat(autoscaling): Unified parameters to set scaled options for browser nodes (#1989) :: Viet Nguyen Duc
- Add chart parameter ingress.paths to configure custom paths (#1994) :: Viet Nguyen Duc
- feat: Adding port to nodes service (#1196) :: Viet Nguyen Duc

### Changed
- Update image tag to 4.15.0-20231110

## :heavy_check_mark: 0.23.0

### Added

- Update tag in docs and files [skip ci] :: Selenium CI Bot
- feat: video recording with pluggable upload container (#1881) :: Mårten Svantesson
- Update Video/Dockerfile with based image ffmpeg:6.0-alpine (#1981) :: Viet Nguyen Duc

### Changed
- Update image tag to 4.14.1-20231025

## :heavy_check_mark: 0.22.0

### Added
-  feat(keda): bumped up keda 2.12.0 (#1960) :: Amar Deep Singh
-  Add missing Ingress namespace field (#1966) :: Cody Lent

### Changed
- Update image tag to 4.13.0-20231004

## :heavy_check_mark: 0.21.3

### Changed
- Update image tag to  4.13.0-20230926

## :heavy_check_mark: 0.21.2

### Changed
- Update image tag to 4.12.1-20230920

## :heavy_check_mark: 0.21.1

### Changed
- Update image tag to 4.12.1-20230912

## :heavy_check_mark: 0.21.0

### Added
- feat: Add option to inject sidecars into Node Pods (#1938) 
- Add minReplicaCount, remove replicas if autoscaling is enabled (#1932) 

## :heavy_check_mark: 0.20.1

### Changed
- Update image tag to 4.12.1-20230904

## :heavy_check_mark: 0.20.0

### Added
- fix missing securityContext in nodes (#1907) :: balazs92117
- Support to nodes livenessProbe into the Helm Chart (#1897) :: Bruno Brito
- helm chart VolumeMounts & Volumes for Selenium hub (#1893) :: Yoga Yu

### Changed
- Update image tag to 4.11.0-20230801

## :heavy_check_mark: 0.19.0

### Added
-  Autoscaling selenium grid on kubernetes with scaledjobs (#1854) 

## :heavy_check_mark: 0.18.1

### Changed
- Update image tag to 4.10.0-20230607

## :heavy_check_mark: 0.18.0

### Added
- Add affinity to helm charts (#1851) 

## :heavy_check_mark: 0.17.0

### Added
- Make deployment securityContext configurable via values.yaml (#1845) 

## :heavy_check_mark: 0.16.1

### Changed
- Update image tag to  4.9.1-20230508

## :heavy_check_mark: 0.16.0

### Added
- Custom Ingress Path for Helm Chart (#1834) 

## :heavy_check_mark: 0.15.8

### Changed
- Update image tag to 4.9.0-20230421

## :heavy_check_mark: 0.15.7

### Changed
- Update image tag to 4.8.3-20230328

## :heavy_check_mark: 0.15.6

### Changed
- Update image tag to 4.8.3-20230328

## :heavy_check_mark: 0.15.5

### Changed
- Update image tag to 4.8.2-20230325

## :heavy_check_mark: 0.15.4

### Changed
- Update image tag to 4.8.1-20230306

## :heavy_check_mark: 0.15.3

### Changed
- Make ingress compatible with format prior to 1.19-0 k8s version

## :heavy_check_mark: 0.15.2

### Changed
- Update image tag to 4.8.1-20230221

## :heavy_check_mark: 0.15.1

### Changed
- Update image tag to 4.8.0-20230210

## :heavy_check_mark: 0.15.0

### Changed
- Update image tag to 4.8.0-20230123

## :heavy_check_mark: 0.14.3

### Changed
- Update image tag to 4.7.2-20221219

## :heavy_check_mark: 0.14.2

### Changed
- Update image tag to 4.7.2-20221217

## :heavy_check_mark: 0.14.1

### Changed
- Update image tag to 4.7.1-20221208

## :heavy_check_mark: 0.14.0

### Changed
- Update image tag to 4.7.0-20221202

## :heavy_check_mark: 0.13.1

### Changed
- Update image tag to  4.6.0-20221104

## :heavy_check_mark: 0.13.0

### Added
- Added support to disable Chrome, Edge, and Firefox Deployment using `deploymentEnabled`

## :heavy_check_mark: 0.12.2

### Changed
- Update image tag to  4.6.0-20221024

## :heavy_check_mark: 0.12.1

### Changed
- Update image tag to  4.5.0-20221017

## :heavy_check_mark: 0.12.0

### Changed
- Remove EventBus from SessionQueue environment variables

## :heavy_check_mark: 0.11.0

### Added
- Adds helm-chart releaseName to all selectors in resources

### Changed
- Update image tag to 4.5.0-20221004

## :heavy_check_mark: 0.10.0

### Changed
- Bump version chart

## :heavy_check_mark: 0.9.0

### Added
- Add lifecycle preStop hook & startupProbe, fix port number

## :heavy_check_mark: 0.8.1

### Changed
- Update image tag to 4.4.0-20220831

## :heavy_check_mark: 0.8.0

### Added
- Added support of loadBalancerIP for hub and router services

## :heavy_check_mark: 0.7.0

### Added
- Added ability to specify image pull secrets

## :heavy_check_mark: 0.6.2

### Added
- Pod PriorityClasses

## :heavy_check_mark: 0.6.1

### Changed
- Update image tag to 4.3.0-20220706

## :heavy_check_mark: 0.6.0

### Added
- Added ability to set hostAliases on browser node deployments

## :heavy_check_mark: 0.5.0

### Added
- Added ability to mount arbitrary volumes into browser nodes

## :heavy_check_mark: 0.4.2

### Changed
- Update image tag to 4.3.0-20220624

## :heavy_check_mark: 0.4.1

### Changed
- Update image tag to 4.2.1-20220608

## :heavy_check_mark: 0.4.0

### Added
- Expose the Hub or the Router by default with ingress resource.

### Changed
- Set the default serviceType of the Hub and the Router to ClusterIP

## :heavy_check_mark: 0.3.1

### Added
- Helm charts repo to GitHub Pages - https://www.selenium.dev/docker-selenium

### Changed
- Update image tag to 4.2.1-20220531

## :heavy_check_mark: 0.3.0

### Added
- Support for Edge nodes.
- Support for `nodeSelector`.
- Support for `tolerations`.
- Allow to add additional labels to the hub, edge, firefox and chrome nodes.
- Fix queue component name (#1290)

### Changed
- Update image tag to 4.1.4-20220427

### Removed
- Opera nodes

## :heavy_check_mark: 0.2.0

### Added
- `CHANGELOG.md`

### Changed
- Added `global` block to be able to specify component's image tag globally.
- DSHM's volume size customizable.
- Service type and service annotations are now customizable.

### Fixed
- Services won't be created if nodes are disabled.

## :heavy_check_mark: 0.1.0

### Added
- Selenium grid components separated.
- Selenium Hub server.
- Chrome, Opera and Firefox nodes.
