docker run -ti --rm -v "$(pwd)":/app -v "./gradle-cache:/root/.gradle" --network=ai4ind-ufsc_ai4industry -p 3272:3272 -w /app jomifred/jacamo:1.2 wot.jcm
