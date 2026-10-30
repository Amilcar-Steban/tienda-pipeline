# Changelog

## [0.6.0](https://github.com/Amilcar-Steban/tienda-pipeline/compare/v0.5.0...v0.6.0) (2026-10-30)


### Features

* **api:** migraciones separadas para usar credenciales de mínimo privilegio ([bd1cace](https://github.com/Amilcar-Steban/tienda-pipeline/commit/bd1cacef3211ea777e39c0fed54e0dfae2af1b0d))
* **ci:** el PR de producción solo para las releases ([c2ea8c4](https://github.com/Amilcar-Steban/tienda-pipeline/commit/c2ea8c434b2f8658055593e42fb3ceecf1b6368b))


### Bug Fixes

* **k8s:** Calico en el laboratorio de kind y sonda de salida ([e4c3cbc](https://github.com/Amilcar-Steban/tienda-pipeline/commit/e4c3cbc54fddda3b0e3ecc32a5eda1572cb8b72f))

## [0.5.0](https://github.com/Amilcar-Steban/tienda-pipeline/compare/v0.4.0...v0.5.0) (2026-10-30)


### Features

* **ci:** promoción a GitOps y releases con la GitHub App ([412125e](https://github.com/Amilcar-Steban/tienda-pipeline/commit/412125e0b773358d5139bbaa692ff912562edf52))
* **k8s:** observabilidad en Kubernetes con el OpenTelemetry Operator ([efcf752](https://github.com/Amilcar-Steban/tienda-pipeline/commit/efcf752ecaad803642387225a5b4862e76e29b32))


### Bug Fixes

* **aws:** el despliegue parte de la task definition del servicio y sube todo el frontend ([baa77d1](https://github.com/Amilcar-Steban/tienda-pipeline/commit/baa77d1fc0f3e8d7db812b59e0a5ea2942d62a8b))
* **seg:** cabeceras de seguridad en el proxy y CSS/JS fuera del HTML ([cebbf59](https://github.com/Amilcar-Steban/tienda-pipeline/commit/cebbf59446d03a6b49584f719dd7d8d972fdc6a9))
* **seg:** Falco sin excepción por puertos y OpenBao para la base de datos ([47b499c](https://github.com/Amilcar-Steban/tienda-pipeline/commit/47b499c269c4ad0af3816d37a9769de8bceffe5f))

## [0.4.0](https://github.com/Amilcar-Steban/tienda-pipeline/compare/v0.3.0...v0.4.0) (2026-10-30)


### Features

* **plataforma:** catálogo de Backstage, TechDocs, Crossplane y alta de equipos (Fase 9) ([ac77cbd](https://github.com/Amilcar-Steban/tienda-pipeline/commit/ac77cbd8f0a964127b232f4d9caed566abeb7630))

## [0.3.0](https://github.com/Amilcar-Steban/tienda-pipeline/compare/v0.2.0...v0.3.0) (2026-10-30)


### Features

* **k8s:** chart de Helm, laboratorio en kind y capa EKS (Fase 5) ([042c6ea](https://github.com/Amilcar-Steban/tienda-pipeline/commit/042c6ea107d08cb2435779a0d559b2c0b1ad3d8d))
* **obs:** la tienda observable con OpenTelemetry (Fase 7) ([7fd5930](https://github.com/Amilcar-Steban/tienda-pipeline/commit/7fd59303569800b9a0c750765bdd6dbb4dcf8e05))
* **seg:** firma keyless, SAST y políticas de admisión (Fase 8) ([ba2b0e0](https://github.com/Amilcar-Steban/tienda-pipeline/commit/ba2b0e0297a5aa5dde670453fec6601b09869d77))

## [0.2.0](https://github.com/Amilcar-Steban/tienda-pipeline/compare/tienda-v0.1.0...tienda-v0.2.0) (2026-10-29)


### Features

* **aws:** despliegue en AWS de la Fase 3 ([04bc618](https://github.com/Amilcar-Steban/tienda-pipeline/commit/04bc618ad0df72aca6abe39f787040ea307b0a94))
* tienda en contenedores con pipeline CI/CD completo ([158a4d3](https://github.com/Amilcar-Steban/tienda-pipeline/commit/158a4d3c2b042a8ffd91e87db78a09eb71c37f20))


### Bug Fixes

* **frontend:** parchear la imagen base con apk upgrade y pasar a nginx 1.30 ([e7a0903](https://github.com/Amilcar-Steban/tienda-pipeline/commit/e7a0903d75c3b960994b5ffdf62d699089af720d))
