# Seguridad de la tienda (Fase 8)

| Carpeta / archivo | Qué hace | Cuándo actúa |
|---|---|---|
| `semgrep/tienda.yaml` | SAST con reglas propias (SQL construido con texto, secretos, excepciones silenciadas) | Cada PR (workflow Seguridad) |
| `kyverno/cargas-seguras.yaml` | `ValidatingPolicy`: registro propio, sin `:latest`, requests obligatorios | Al crear pods en los namespaces de la tienda |
| `kyverno/imagenes-firmadas.yaml` | `ImageValidatingPolicy`: firma keyless de nuestro CI y SBOM firmado | Al crear pods con imágenes de la tienda |
| `kyverno/pruebas/` | Casos de prueba de las políticas | Cada PR (`kyverno test`) |
| `falco/reglas-tienda.yaml` | Shell en un contenedor, binarios modificados, conexiones salientes inesperadas | En ejecución |
| `../docs/modelo-amenazas.md` | Modelo de amenazas STRIDE que justifica cada control | Al cambiar la arquitectura |
| `../.github/workflows/image.yml` | Firma la imagen por digest y adjunta su SBOM firmado | Cada imagen publicada |

## Probar en local

```bash
semgrep --test seguridad/semgrep/                                       # reglas propias
semgrep scan --config p/python --config seguridad/semgrep/tienda.yaml api/
docker run --rm -v "$PWD/seguridad/kyverno":/k ghcr.io/kyverno/kyverno-cli:v1.19.2 test /k/pruebas
docker run --rm -v "$PWD/seguridad/falco":/r falcosecurity/falco:0.45.2 \
  falco -V /etc/falco/falco_rules.yaml -V /r/reglas-tienda.yaml
```

## Verificar una imagen publicada

```bash
IMG=ghcr.io/amilcar-steban/tienda-api:0.3.0
cosign verify "$IMG" \
  --certificate-identity https://github.com/Amilcar-Steban/tienda-pipeline/.github/workflows/image.yml@refs/heads/main \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
cosign verify-attestation "$IMG" --type cyclonedx \
  --certificate-identity https://github.com/Amilcar-Steban/tienda-pipeline/.github/workflows/image.yml@refs/heads/main \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com > /dev/null && echo "SBOM firmado por nuestro CI"
gh attestation verify "oci://$IMG" --owner Amilcar-Steban                 # procedencia SLSA
```

## En el clúster

```bash
helm install kyverno kyverno --repo https://kyverno.github.io/kyverno/ --version 3.9.2 -n kyverno --create-namespace
kubectl apply -f seguridad/kyverno/cargas-seguras.yaml -f seguridad/kyverno/imagenes-firmadas.yaml
```

Empieza con `validationActions: [Audit]` y revisa `kubectl get policyreports -A` antes de pasar a `[Deny]`.
