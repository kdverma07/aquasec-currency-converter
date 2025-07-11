# Currency Converter Helm Chart

## Usage

```bash
helm install currency-converter ./helm/currency-converter \
  --set image.repository=yourdockerhubusername/currency-converter \
  --set image.tag=latest

