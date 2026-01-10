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

# Mise a jour de pip
echo "Mise a jour de pip..."
pip install --upgrade pip > /dev/null 2>&1

# Toujours vérifier/installer les dépendances
if [ -f "requirements.lock" ]; then
    DEP_FILE="requirements.lock"
    echo "Utilisation de requirements.lock pour une installation reproductible."
elif [ -f "requirements.txt" ]; then
    DEP_FILE="requirements.txt"
    echo "Utilisation de requirements.txt (requirements.lock manquant)."
else
    echo "ERREUR: Ni requirements.lock ni requirements.txt trouves!"
    exit 1
fi

echo "Verification des dependances Python ($DEP_FILE)..."
# Capture output and exit code
if ! pip install -r $DEP_FILE > /dev/null 2>&1; then
    echo "ERREUR: L'installation des dependances a echoue."
    echo "Tentative de reinstallation avec affichage des erreurs :"
    pip install -r $DEP_FILE
    echo "Veuillez corriger les erreurs ci-dessus avant de relancer."
    exit 1
fi

# Verification specifique pour PyQt6 qui pose souvent probleme
if ! python3 -c "import PyQt6" > /dev/null 2>&1; then
    echo "ERREUR: PyQt6 semble manquant malgre l'installation."
    echo "Tentative d'installation forcee de PyQt6..."
    pip install PyQt6
    
    if ! python3 -c "import PyQt6" > /dev/null 2>&1; then
            echo "ECHEC FATAL: Impossible d'importer PyQt6."
            exit 1
    fi
fi

# Vérification et Installation des dépendances externes (Brush)
echo "Verification des moteurs..."
python3 -m app.scripts.setup_dependencies

# Lancer l'application
echo "Lancement de CorbeauSplat..."
python3 main.py "$@"
