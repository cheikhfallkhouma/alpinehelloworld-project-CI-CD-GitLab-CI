#!/bin/bash

# Variables attendues (à fournir via GitLab CI ou exportées dans l'environnement)
TAG="review_env"

# Config AWS (assume que aws configure est déjà fait ou que les variables d'env sont exportées)
echo "🔍 Recherche de l'instance EC2 avec le tag: $TAG"

# Récupération de l'ID de l'instance
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$TAG" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

# Vérification de la présence d'une instance
if [ -z "$INSTANCE_ID" ]; then
  echo "❌ Aucune instance EC2 trouvée avec le tag '$TAG'."
  exit 0  # Pas d'erreur, rien à supprimer
fi

echo "🛑 Arrêt et suppression de l'instance EC2: $INSTANCE_ID"

# Arrêt (optionnel mais propre)
aws ec2 stop-instances --instance-ids "$INSTANCE_ID" > /dev/null
aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID"

# Suppression
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"

echo "✅ Instance EC2 supprimée avec succès! ID: $INSTANCE_ID"
