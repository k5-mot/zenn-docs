---
title: "Appendix"
---

# minikube

```bash

```

# 基本操作

```bash
# deploymentのyamlを生成
kubectl create deployment nginx --image nginx:latest -o yaml --dry-run=client > deployment.yaml
# deploymentリソースを作成
kubectl apply -f deployment.yaml
# deploymentから作成されたpodを確認できる
kubectl get pods
# deploymentを確認できる
kubectl get deployment
# podを詳細に確認できる
kubectl describe pods nginx-XXXXXXXXXXX[リソース名]

# yaml編集(replica:1⇒2)後、apply
kubectl apply -f deployment.yaml
# podが増えている
kubectl get pods

#
kubectl delete pods nginx-XXXXXX[リソース名]
#
kubectl delete -f deployment.yaml

```

# デバッグ操作

```bash
kubectl apply -f deployment.yaml
kubectl get pods
kubectl logs nginx-XXXXXXXXXX
kubectl exec -it nginx-XXXXXXXXXXX -- /bin/sh
ls
kubectl port-forward nginx-XXXXXXXXXXX 8080:80
# http://localhost:8080/をブラウザで開く

```


# kubectlの設定

- kubectlの設定
  - kubernetes環境が服すある場合に、どうやって操作対象の環境を切り替えるか？
  - kubectlでは、contextという単位で、kubernetes環境を管理している
  - contextは、cluster(kubernetes環境)とuser(認証情報)という情報を持つ
  - kubectlで、contextを切り替えることで、操作対象のkbuernetes環境を切り替えることができる
- namespaceについて
  - namespaceは、kubernetes環境を仮想的に分離する機能である
  - 各kubernetesリソースに対して、namespaceを付与することができ、namespaceを境界として権限設定が可能になる
  - 使いこなすのは難しい機能だが、kubernetesを利用していくと頻繁に表れる機能なので覚えておく必要がある。
  - namespaceを意識しないと、思わぬミスにつながる


```bash
# kubectxをインストール
# kubernete環境が一覧表示
kubectx
# 環境切り替え
kubectx minikube
# namespacer一覧表示
kubens
# namespace作成
kubectl create namespace development
# yamlでは、metadataでnamespace指定を行う
kubectl apply -f deployment.yaml
kubectl get pods -n development
kubens
# namespace切り替え
kubens devlopment
kubectl get pods

# 全namespaceのリソースを表示
kubectl get pods --all-namespaces

# ~/.kube/configにnamesspace情報が格納されている
```

# Horizontal Pod Autoscalerをマニフェストで設定

```bash
kubectl apply -f nginx.yaml
kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=10
kubectl get hpa
kubectl get hpa nginx -o yaml > nginx-hpa.html
# annotation, creationTimestamp, resourceVersion,uid, statusを削除
kubectl delete -f nginx-hpa.yaml
kubectl apply -f nginx-hpa.yaml
kubectl get hpa
kubectl get hpa.v2beta2.autoscaling nginx -o yaml > nginx-hpa-v2.yaml
# annotation, creationTimestamp, resourceVersion,uid, statusを削除
kubectl delete -f nginx-hpa-v2.yaml
kubectl apply -f nginx-hpa-v2.yaml
kubectl get hpa
```
