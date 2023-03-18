#!/bin/bash

# Paramètres
page=1
page_total=51
image_dl=1
nb_images=1
seed=$RANDOM
endnb=0
dataset_mode=0
search_mode=0

if [[ -f "images" ]]
then
true
else
mkdir -p "images"
fi

if [[ -f "données" ]]
then
true
else
mkdir -p "données"
fi

if [[ -f "datasets" ]]
then
true
else
mkdir -p "datasets"
fi
# Partie 1 : Formulaire
echo "===================================="
echo "======== RISIBANK PARSER V1 ========"
echo "========   PAR  DELAWARDE   ========"
echo -e "====================================\n\n\n"
echo -e "Salut khey ! Bienvenue sur Risibank Parser V1.0.0\nCe petit script te permet de récuperer des images de Risibank en quantité, et ce, sans devoir taper un seule ligne de code ni dévisser ton gros cul de ta chaise."
echo "Si ce n'est pas déja fait, cliques sur le fichier texte 'TUTO INSTALLATION' pour installer Curl, dont le script a besoin pour fonctionner."
echo -e "Sélectionne le mode de ton choix en entrant le nombre correspondant et en appuyant sur Entrée.\n\n- Mode RECHERCHE (Cherche via un ou plusieurs termes de recherche) Mode par défaut : 0\n- Mode HOT (Cherche parmi les stickers tendances du moment) : 1\n- Mode TOP (Cherche parmi les stickers les plus postés sur le forum) : 2\n- Mode NOUVEAU (Cherche parmi les stickers les plus récents) : 3\n- Mode ALEATOIRE (Cherche parmi des stickers aléatoires) : 4"
read search_mode
search_mode=$((search_mode))

if ! [[ "$search_mode" =~ ^[0-9]+$ ]]
then
    search_mode=0
fi

case $search_mode in
0)
echo -e "=== MODE RECHERCHE ===\n\nEntre le nom de ta recherche Risibank (exemple: risitas).\nSi tu souhaites rechercher plusieurs tags en même temps, sépare-les par un espace (exemple : jesus zoom):"
read query
query="${query// /%20}"
;;
1)
query="hot"
echo -e "\n\n=== MODE HOT ==="
;;
2)
query="top"
echo -e "\n\n=== MODE TOP ==="
;;
3)
query="nouveau"
echo -e "\n\n=== MODE NOUVEAU ==="
;;
4)
query="aleatoire"
echo -e "\n\n=== MODE ALEATOIRE ==="
;;
esac

echo -e "\n\nVeux-tu activer le mode dataset?\nA la place de sauvegarder les tags dans le nom de l'image, un fichier .txt de même nom que l'image les contiendra, pratique pour le Machine Learning\n- Pour ne pas l'activer : entrer '0' (valeur par défaut, recommandé pour un usage classique)\n- Pour l'activer : entrer '1'"
read dataset_mode
dataset_mode=$((dataset_mode))

if test -n "$dataset_mode" && ! [[ "$dataset_mode" =~ ^[0-9]+$ ]]
then
    dataset_mode=0
fi

if ((dataset_mode!=1))
then
    dataset_mode=0
fi

if ((dataset_mode==1))
then
    echo "$dataset_mode : Le mode Dataset est activé"
else
    echo "$dataset_mode : Le mode Dataset est désactivé"
fi



echo -e "\nCombien de pages veux-tu parser?\n- Chaque page contient 80 stickers.\n- Le maximum est 51 selon les limites de l'API de Risibank. \n- Si tu entres au delà de 51, je ramènerais le chiffre à 51.\n - Si tu rentres une donnée invalide (exemple: des mots), je ramène alors la valeur à celle par défaut (1 page)"
read page_total
page_total=$((page_total))

if test -n "$page_total" && ! [[ "$page_total" =~ ^[0-9]+$ ]]
then
page_total=1
fi

if ((page_total>51))
then
page_total=51
fi

output_file="données/$query-0.txt"
while [[ -f "$output_file" ]]; do
endnb=$((endnb+1))
output_file="données/$query-$endnb.txt"
done


# Partie 2 : Parsing
echo "Démarrage du scan..."
while ((page <= page_total)); do
  echo "En train de scanner la page $page"
    touch données/cache_url.txt données/slug.txt

  # Requêtes API (une par mode)
  case $search_mode in
  0)
    curl -s "https://risibank.fr/api/v1/medias/search?query=$query&category=sticker&page=$page" -H accept:application/json | grep -o '"cache_url":"[^"]*"' | sed 's/^"cache_url"://' | tr -d '"' > données/cache_url.txt
    curl -s "https://risibank.fr/api/v1/medias/search?query=$query&category=sticker&page=$page" -H accept:application/json | grep -o '"slug":"[^"]*"' | cut -d ':' -f 2 | tr -d '"' > données/slug.txt
    ;;
  1)
    curl -s "https://risibank.fr/api/v1/medias/hot?page=$page" -H accept:application/json | grep -o '"cache_url":"[^"]*"' | sed 's/^"cache_url"://' | tr -d '"' > données/cache_url.txt
    curl -s "https://risibank.fr/api/v1/medias/hot?page=$page" -H accept:application/json | grep -o '"slug":"[^"]*"' | cut -d ':' -f 2 | tr -d '"' > données/slug.txt
    ;;
  2)
    curl -s "https://risibank.fr/api/v1/medias/top?page=$page" -H accept:application/json | grep -o '"cache_url":"[^"]*"' | sed 's/^"cache_url"://' | tr -d '"' > données/cache_url.txt
    curl -s "https://risibank.fr/api/v1/medias/top?page=$page" -H accept:application/json | grep -o '"slug":"[^"]*"' | cut -d ':' -f 2 | tr -d '"' > données/slug.txt
    ;;
  3)
    curl -s "https://risibank.fr/api/v1/medias/new?page=$page" -H accept:application/json | grep -o '"cache_url":"[^"]*"' | sed 's/^"cache_url"://' | tr -d '"' > données/cache_url.txt
    curl -s "https://risibank.fr/api/v1/medias/new?page=$page" -H accept:application/json | grep -o '"slug":"[^"]*"' | cut -d ':' -f 2 | tr -d '"' > données/slug.txt
    ;;
  4)
    curl -s "https://risibank.fr/api/v1/medias/random?only_one=false&page=$page" -H accept:application/json | grep -o '"cache_url":"[^"]*"' | sed 's/^"cache_url"://' | tr -d '"' > données/cache_url.txt
    curl -s "https://risibank.fr/api/v1/medias/random?only_one=false&page=$page" -H accept:application/json | grep -o '"slug":"[^"]*"' | cut -d ':' -f 2 | tr -d '"' > données/slug.txt
    ;;
  esac

  # Normalisation des tags
sed -i 's/-/, /g' données/slug.txt

  # Création du fichier de données
  paste -d '|' données/cache_url.txt données/slug.txt >> "$output_file"

  echo "Page $page scannée avec succès!"
  page=$((page+1))

done
# Correction temporaire pour le bug des images randomisées
sed -i 's/| /, /g' "$output_file"

# On dégage les anciens fichiers
rm données/cache_url.txt données/slug.txt

echo "Tags et liens agencés avec succès !"

# Création des sous-dossiers
output_dir="$query-$endnb"
case $dataset_mode in
0)
mkdir -p "images/$output_dir"
;;
1)
mkdir -p "datasets/$output_dir"
;;
esac


echo "Dossier au nom de $output_dir créé avec succès!"

num_lines=$(wc -l "données/$query-$endnb.txt" | awk '{print $1}')

# Partie 3 : Sauvegarde
while read -r line; do
  # On sépare les liens de stags
  link=$(echo $line | cut -d '|' -f 1)
  tags=$(echo $line | cut -d '|' -f 2)


  extension=$(echo "$link" | awk -F . '{print $NF}')
  identifier=$(echo "$link" | awk -F / '{print $(NF-1)}')

  # Téléchargement de l'image
  curl -s "$link" > image."$extension"

  if ((dataset_mode==0)) 
  then
    # Image sauvegardée avec son identifiant unique, ses tags et son extension
    mv image."$extension" "images/$output_dir/$identifier, $tags.$extension"
    echo "$image_dl|$num_lines\nL'image N°$image_dl a été sauvegardée au format .$extension avec les tags suivants : $tags"
    image_dl=$((image_dl+1))
    nb_images=$((nb_images+1))
  else
    # Image suavegardée avec son identifiant unique et son extension
    mv image."$extension" "datasets/$output_dir/$identifier.$extension"
    echo -e "$image_dl|$num_lines\nL'image N°$image_dl a été sauvegardée au format .$extension avec le nom suivant : $identifier.$extension"

    # On créé les fichiers .txt pour le dataset
    touch "datasets/$output_dir/$identifier.txt"
    # DOn emt les tags dans le fichier .txt
    echo "$tags" > "datasets/$output_dir/$identifier.txt"
    echo "Le fichier N°$image_dl a été créé au nom $identifier.txt, avec les tags suivants : $tags"
    image_dl=$((image_dl+1))
    nb_images=$((nb_images+1))
  fi
done < "données/$query-$endnb.txt"


echo "Terminé !"
