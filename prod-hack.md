1. sts/geth: rm livenessProbe:
```$xslt
        livenessProbe:
          failureThreshold: 3
          initialDelaySeconds: 3
          periodSeconds: 3
          successThreshold: 1
          tcpSocket:
            port: 8545
          timeoutSeconds: 1
```