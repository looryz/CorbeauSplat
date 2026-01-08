#!/bin/bash

# Se placer dans le dossier du script
cd "$(dirname "$0")"

# --- Auto Update Check ---
if [ -d ".git" ]; then
    echo "Verification des mises a jour..."
    # Fetch latest changes silently
    git fetch > /dev/null 2>&1
    
    # Check if we have an upstream configured
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
        # Count commits behind
        BEHIND_COUNT=$(git rev-list --count HEAD..@{u})
        
        if [ "$BEHIND_COUNT" -gt 0 ]; then
             echo ">>> Une nouvelle version est disponible ($BEHIND_COUNT commits de retard)."
             read -p ">>> Voulez-vous mettre a jour maintenant ? (o/n) " -n 1 -r
             echo
             if [[ $REPLY =~ ^[OoYy]$ ]]; then
                 echo "Mise a jour en cours..."
                 git pull
                 echo "Mise a jour terminee."
             else
                 echo "Mise a jour ignoree."
             fi
        else
             echo "CorbeauSplat est a jour."
        fi
    fi
fi
# -------------------------

# Nom du dossier d'environnement virtuel
VENV_DIR=".venv"

# Vérifier si l'environnement virtuel existe
if [ ! -d "$VENV_DIR" ]; then
    echo "Creation de l'environnement virtuel..."
    python3 -m venv $VENV_DIR
fi

echo "Activation de l'environnement..."
source $VENV_DIR/bin/activate

# Toujours vérifier/installer les dépendances
if [ -f "requirements.txt" ]; then
    # On redirige la sortie standard vers null pour éviter le spam si tout est déjà là
    # mais on garde les erreurs
    echo "Verification des dependances Python..."
    pip install -r requirements.txt > /dev/null
else
    echo "ERREUR: requirements.txt non trouve!"
    exit 1
fi

# Vérification et Installation des dépendances externes (Brush)
echo "Verification des moteurs..."
python3 -m app.scripts.setup_dependencies

# Lancer l'application
echo "Lancement de CorbeauSplat..."
python3 main.py "$@"
